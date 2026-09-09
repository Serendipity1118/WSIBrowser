// Settings page: reads / writes WSI.settings; the banner on the site page
// updates live through settings.onChange. `WSI` is on window here (plugin page).
(async function () {
  const $ = (id) => document.getElementById(id);
  const status = (t) => { $('status').textContent = t; };

  const all = await WSI.settings.getAll();
  $('text').value = all.text || '';
  $('color').value = all.color || 'blue';
  $('visible').checked = all.visible !== false;

  $('text').addEventListener('change', () => WSI.settings.set('text', $('text').value).then(() => status('文言を保存しました')));
  $('color').addEventListener('change', () => WSI.settings.set('color', $('color').value).then(() => status('色を保存しました')));
  $('visible').addEventListener('change', () => WSI.settings.set('visible', $('visible').checked).then(() => status('表示を保存しました')));

  $('ping').addEventListener('click', async () => {
    const r = await WSI.runtime.sendMessage({ type: 'ping' });
    status(r && r.reply ? `pong: ${r.reply.text} (${r.delivered} 件に配信)` : `応答なし (${r ? r.delivered : 0} 件に配信)`);
  });
  $('close').addEventListener('click', () => WSI.ui.closePage());

  WSI.log('settings page opened');
})();
