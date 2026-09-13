// Info page: every button calls one WSI API and prints what came back.
// `WSI` is on window here (plugin page context).
(function () {
  const $ = (id) => document.getElementById(id);
  const time = () => new Date().toLocaleTimeString();
  const num = (id) => Number($(id).value) || 0;

  const calls = {
    'device.id': () => WSI.device.id(),
    'device.info': () => WSI.device.info(),
    'device.key': () => WSI.device.key(),
    'app.info': () => WSI.app.info(),
    'locale.get': () => WSI.locale.get(),
    'location.permission': () => WSI.location.permission(),
    'location.request': () => WSI.location.request(),
    'location.getCurrent': () => WSI.location.getCurrent({ accuracy: $('accuracy').value, timeout: num('timeout'), maxAge: num('maxAge') }),
    'network.status': () => WSI.network.status(),
    'battery.status': () => WSI.battery.status(),
    'biometrics.status': () => WSI.biometrics.status(),
    'biometrics.authenticate': () => WSI.biometrics.authenticate({ reason: $('reason').value, biometricOnly: $('biometricOnly').checked }),
  };

  // Calls that never show an OS dialog; used by the "run all" button.
  const quiet = ['device.id', 'device.info', 'device.key', 'app.info', 'locale.get', 'location.permission', 'network.status', 'battery.status', 'biometrics.status'];

  function print(family, label, value, isError) {
    const pre = $(`out-${family}`);
    const text = typeof value === 'string' ? value : JSON.stringify(value, null, 2);
    const entry = `[${time()}] ${label}${isError ? ' ERROR' : ''}\n${text}\n`;
    pre.textContent = entry + (pre.textContent ? '\n' + pre.textContent : '');
    pre.classList.toggle('error', !!isError);
  }

  function outputFor(op) {
    const family = op.split('.')[0];
    return family === 'app' || family === 'locale' ? 'app' : family;
  }

  async function run(op) {
    const family = outputFor(op);
    try {
      const value = await calls[op]();
      print(family, op, value === undefined ? '(undefined)' : value, false);
      if (op === 'location.getCurrent' && value && typeof value.timestamp === 'number') {
        print(family, 'timestamp', new Date(value.timestamp).toLocaleString(), false);
      }
    } catch (e) {
      print(family, op, e && e.message ? e.message : String(e), true);
    }
  }

  document.querySelectorAll('[data-run]').forEach((button) => {
    button.addEventListener('click', async () => {
      button.disabled = true;
      try { await run(button.dataset.run); } finally { button.disabled = false; }
    });
  });

  $('all').addEventListener('click', async () => {
    for (const op of quiet) await run(op);
  });
  $('close').addEventListener('click', () => WSI.ui.closePage());

  function watchToggle(id, family, subscribe) {
    let off = null;
    $(id).addEventListener('change', () => {
      if ($(id).checked) {
        off = subscribe((s) => print(family, `${family}.change`, s, false));
        print(family, `${family}.onChange`, '監視を開始しました', false);
      } else if (off) {
        off();
        off = null;
        print(family, `${family}.onChange`, '監視を止めました', false);
      }
    });
  }
  watchToggle('watch-network', 'network', (cb) => WSI.network.onChange(cb));
  watchToggle('watch-battery', 'battery', (cb) => WSI.battery.onChange(cb));

  $('out-permissions').textContent = WSI.permissions.list().join(', ');
  WSI.log('info page opened');
})();
