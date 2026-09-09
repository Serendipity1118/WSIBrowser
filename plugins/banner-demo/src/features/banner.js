// Banner at the top of every matching page. Text / color / visibility come
// from WSI.settings (editable from the settings page and the menu toggle);
// changes arrive live through WSI.settings.onChange.
export const name = 'banner';

export function matches() {
  return true;
}

export async function run(WSI, ctx) {
  const el = document.createElement('div');
  el.className = 'banner-demo';
  el.setAttribute('data-banner-demo', '1');
  document.body.appendChild(el);

  const state = { text: '', color: 'blue', visible: true };

  function apply() {
    el.textContent = state.text;
    el.className = `banner-demo banner-demo--${state.color}${state.visible ? '' : ' banner-demo--hidden'}`;
  }

  const all = await WSI.settings.getAll();
  Object.assign(state, all);
  apply();

  WSI.settings.onChange(({ key, value }) => {
    state[key] = value;
    apply();
    WSI.log(`setting ${key} = ${JSON.stringify(value)}`);
  });

  // menu (page-registered: lives as long as this page)
  WSI.menu.register([
    { id: 'settings', label: 'バナー設定', type: 'page', page: 'settings' },
    {
      id: 'visible', label: 'バナーを表示', type: 'toggle', checked: state.visible,
      onChange: (checked) => WSI.settings.set('visible', checked),
    },
    { type: 'separator' },
    { id: 'diagnose', label: '自己診断をログに出す', type: 'action', onSelect: diagnose },
  ]);

  // messages from the settings page (WSI.runtime.sendMessage)
  WSI.runtime.onMessage((message, sender) => {
    if (message && message.type === 'ping') {
      WSI.log(`ping from ${sender && sender.context}`);
      return { type: 'pong', text: state.text };
    }
    return undefined;
  });

  function diagnose() {
    const r = el.getBoundingClientRect();
    const style = getComputedStyle(el);
    const visible = style.display !== 'none' && style.visibility !== 'hidden' && r.height > 0 && r.bottom > 0;
    WSI.log(`banner: ${Math.round(r.left)},${Math.round(r.top)} ${Math.round(r.width)}x${Math.round(r.height)} visible=${visible} viewport=${window.innerWidth}x${window.innerHeight}`);
    WSI.toast(visible ? 'バナーは表示されています' : 'バナーが見えません');
  }

  diagnose();
  WSI.log(`${name} ready on ${ctx.path}`);
}
