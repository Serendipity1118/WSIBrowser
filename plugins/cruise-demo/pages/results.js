// Results page: reads the worker's state from WSI.storage (same plugin, same store).
(async function () {
  const $ = (id) => document.getElementById(id);
  async function render() {
    const state = (await WSI.storage.get('cruise')) || { urls: [], index: 0, results: [], running: false };
    $('status').textContent = state.running ? `巡回中 ${state.index}/${state.urls.length}` : `完了 ${state.results.length} 件`;
    $('list').innerHTML = '';
    for (const r of state.results) {
      const li = document.createElement('li');
      li.textContent = `${r.heading} — ${r.url}`;
      $('list').appendChild(li);
    }
  }
  $('start').addEventListener('click', async () => { await WSI.runtime.sendMessage({ type: 'start' }); setTimeout(render, 500); });
  $('refresh').addEventListener('click', render);
  await render();
})();
