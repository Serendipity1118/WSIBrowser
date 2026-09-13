// System Info Demo worker (context 'worker').
//
// Registers the menu and, while the "notify" toggle is on, listens to
// WSI.network.onChange / WSI.battery.onChange and shows a toast for every
// change, so the host's watch / unwatch path can be checked from a worker.
// The toggle state survives restarts through WSI.storage.
const NOTIFY_KEY = 'notify';
let unsubscribe = null;

function describeNetwork(s) {
  return s.online ? `接続: ${s.types.join(', ')}` : '接続: オフライン';
}

function describeBattery(s) {
  return `電池: ${s.level ?? '?'}% ${s.state}${s.lowPowerMode ? ' (省電力)' : ''}`;
}

function setNotify(on) {
  if (on && !unsubscribe) {
    const offNetwork = WSI.network.onChange((s) => {
      WSI.toast(describeNetwork(s));
      WSI.log(`network.change ${JSON.stringify(s)}`);
    });
    const offBattery = WSI.battery.onChange((s) => {
      WSI.toast(describeBattery(s));
      WSI.log(`battery.change ${JSON.stringify(s)}`);
    });
    unsubscribe = () => { offNetwork(); offBattery(); };
  } else if (!on && unsubscribe) {
    unsubscribe();
    unsubscribe = null;
  }
}

(async () => {
  const on = (await WSI.storage.get(NOTIFY_KEY)) === true;
  await WSI.menu.register([
    { id: 'info', label: '端末とアプリの情報', type: 'page', page: 'info' },
    {
      id: 'notify', label: '接続と充電の変化を通知', type: 'toggle', checked: on,
      onChange: async (checked) => {
        await WSI.storage.set(NOTIFY_KEY, checked === true);
        setNotify(checked === true);
        WSI.toast(checked ? '変化の通知を開始しました' : '変化の通知を止めました');
      },
    },
  ]);
  setNotify(on);
  const info = await WSI.app.info();
  WSI.log(`system-info-demo worker started on ${info.name} ${info.version} (${info.buildNumber})`);
})();
