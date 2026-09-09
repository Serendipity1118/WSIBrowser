// Cruise Demo worker (runs in a HeadlessInAppWebView, context 'worker').
//
// Visits config.urls one by one in a hidden tab, reads the <h1> of each page
// and stores the results in WSI.storage after every step, so a suspend
// (app to background) or a worker restart resumes from the next page.
// alert / confirm on the visited pages are answered automatically through
// WSI.tabs.onDialog. Links to '/blocked' are denied through
// WSI.navigation.intercept.
const STATE_KEY = 'cruise';
const config = WSI.getConfig();
const stepDelay = Number(config.stepDelayMs) || 300;

let paused = false;
let stopRequested = false;
let running = null; // Promise of the current cruise
let tabId = null;
const loaded = new Map();  // tabId -> { url, seq } of the last load event
const waiters = new Map(); // tabId -> resolve of the pending navigation
let loadSeq = 0;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function loadState() {
  return (await WSI.storage.get(STATE_KEY)) || { urls: [], index: 0, results: [], running: false };
}

async function saveState(state) {
  await WSI.storage.set(STATE_KEY, state);
}

WSI.tabs.onLoad((id, url) => {
  loaded.set(id, { url, seq: ++loadSeq });
  const resolve = waiters.get(id);
  if (resolve) {
    waiters.delete(id);
    resolve(url);
  }
});

/** Resolve when a load event newer than [afterSeq] arrives for the tab (or already did). */
function waitLoad(id, afterSeq) {
  const last = loaded.get(id);
  if (last && last.seq > afterSeq) return Promise.resolve(last.url);
  return new Promise((resolve) => waiters.set(id, resolve));
}

WSI.tabs.onDialog(({ tabId: id, type, message }) => {
  WSI.log(`dialog on ${id}: ${type} "${message}" -> accept`);
  return { action: 'accept' };
});

WSI.navigation.intercept((url) => (url.includes('/blocked') ? 'deny' : undefined));

async function openOrNavigate(url) {
  if (tabId) {
    const open = await WSI.tabs.list();
    if (!open.some((t) => t.tabId === tabId)) tabId = null;
  }
  const before = loadSeq;
  if (!tabId) {
    tabId = await WSI.tabs.open(url, { hidden: true });
  } else {
    await WSI.tabs.navigate(tabId, url);
  }
  await waitLoad(tabId, before);
}

async function step(state) {
  const url = state.urls[state.index];
  await openOrNavigate(url);
  const heading = await WSI.tabs.run(tabId, "(document.querySelector('h1') || {}).textContent || document.title");
  state.results.push({ url, heading: String(heading || '').trim(), at: new Date().toISOString() });
  state.index += 1;
  await saveState(state);
  WSI.log(`step ${state.index}/${state.urls.length}: ${heading}`);
}

async function cruise() {
  const state = await loadState();
  while (state.index < state.urls.length) {
    if (stopRequested) { state.running = false; await saveState(state); WSI.log('stopped'); return; }
    if (paused) { WSI.log('paused at index ' + state.index); return; }
    await step(state);
    await sleep(stepDelay);
  }
  state.running = false;
  await saveState(state);
  if (tabId) { try { await WSI.tabs.close(tabId); } catch (e) { /* ignore */ } tabId = null; }
  WSI.log(`cruise done: ${state.results.length} pages`);
  WSI.toast(`巡回完了: ${state.results.length} ページ`);
}

function run() {
  if (running) return running;
  running = cruise().catch((e) => WSI.log(`cruise failed: ${e && e.message ? e.message : e}`)).finally(() => { running = null; });
  return running;
}

async function start(urls) {
  stopRequested = false;
  await saveState({ urls: urls && urls.length ? urls : config.urls, index: 0, results: [], running: true });
  return run();
}

WSI.runtime.onMessage(async (message) => {
  if (!message || typeof message !== 'object') return undefined;
  if (message.type === 'start') { start(message.urls); return { started: true }; }
  if (message.type === 'stop') { stopRequested = true; return { stopping: true }; }
  if (message.type === 'status') return await loadState();
  return undefined;
});

WSI.runtime.onSuspend(async () => {
  paused = true;
  const state = await loadState();
  WSI.log(`suspend: index=${state.index} running=${state.running}`);
});

WSI.runtime.onResume(async () => {
  paused = false;
  const state = await loadState();
  WSI.log(`resume: index=${state.index} running=${state.running}`);
  if (state.running && state.index < state.urls.length) run();
});

WSI.menu.register([
  { id: 'start', label: '巡回を開始', type: 'action', onSelect: () => start() },
  { id: 'stop', label: '巡回を停止', type: 'action', onSelect: () => { stopRequested = true; } },
  { type: 'separator' },
  { id: 'results', label: '巡回結果', type: 'page', page: 'results' },
]);

// resume an interrupted cruise after a restart
loadState().then((state) => {
  if (state.running && state.index < state.urls.length) {
    WSI.log(`restart: continuing from index ${state.index}`);
    run();
  }
});

WSI.log('cruise worker ready');
