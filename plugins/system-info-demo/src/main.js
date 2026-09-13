// System Info Demo - site page part (example.com). A floating button opens
// the info page, and device.key is also read here to check the page context.
WSI.addButton({
  text: '端末情報',
  position: 'bottom-right',
  onClick: () => WSI.ui.openPage('info'),
});

WSI.device.key()
  .then((key) => WSI.log(`device.key from page context: ${key.slice(0, 12)}…`))
  .catch((e) => WSI.log(`device.key from page context failed: ${e.message}`));
