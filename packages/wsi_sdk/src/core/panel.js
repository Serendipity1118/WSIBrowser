// WSI.addPanel: side panel (desktop) / bottom sheet (narrow screens).
//
// DOM contract kept from WSI 1.x because sample plugins rely on it:
//   panel.className === 'wsi-panel'
//   panel.children[0] === header (title + close button)
//   panel.children[1] === body   (options.content as innerHTML)
//   panel is appended to document.body and removed by the close button
//
// Below BOTTOM_SHEET_MAX_WIDTH the panel becomes a full-width bottom sheet.

export const BOTTOM_SHEET_MAX_WIDTH = 600;

function isNarrow() {
  return window.innerWidth < BOTTOM_SHEET_MAX_WIDTH;
}

/**
 * @param {object} host { log }
 * @param {object} options { title, width, position: 'right'|'left', content, onOpen, onClose }
 */
export function createPanel(host, options = {}) {
  const panel = document.createElement('div');
  panel.className = 'wsi-panel';
  const position = options.position === 'left' ? 'left' : 'right';

  const base = {
    position: 'fixed',
    zIndex: '2147483646',
    background: '#fff',
    display: 'flex',
    flexDirection: 'column',
    boxSizing: 'border-box',
    color: '#222',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", sans-serif',
  };

  const applyLayout = () => {
    if (isNarrow()) {
      panel.dataset.wsiLayout = 'sheet';
      Object.assign(panel.style, base, {
        top: 'auto',
        left: '0',
        right: '0',
        bottom: '0',
        width: '100%',
        height: 'auto',
        maxHeight: '70vh',
        borderRadius: '12px 12px 0 0',
        boxShadow: '0 -2px 12px rgba(0,0,0,0.2)',
        paddingBottom: 'env(safe-area-inset-bottom, 0px)',
      });
    } else {
      panel.dataset.wsiLayout = 'side';
      Object.assign(panel.style, base, {
        top: '0',
        bottom: 'auto',
        left: position === 'left' ? '0' : 'auto',
        right: position === 'right' ? '0' : 'auto',
        width: options.width || '300px',
        maxHeight: 'none',
        height: '100vh',
        borderRadius: '0',
        boxShadow: position === 'right' ? '-2px 0 8px rgba(0,0,0,0.15)' : '2px 0 8px rgba(0,0,0,0.15)',
        paddingBottom: '0',
      });
    }
  };
  applyLayout();

  const header = document.createElement('div');
  Object.assign(header.style, {
    padding: '12px 16px',
    borderBottom: '1px solid #e0e0e0',
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    fontWeight: 'bold',
    flexShrink: '0',
  });
  header.textContent = options.title || '';

  const closeBtn = document.createElement('button');
  closeBtn.type = 'button';
  closeBtn.textContent = '×';
  closeBtn.setAttribute('aria-label', 'close');
  Object.assign(closeBtn.style, {
    border: 'none',
    background: 'none',
    fontSize: '20px',
    minWidth: '44px',
    minHeight: '44px',
    cursor: 'pointer',
    color: 'inherit',
  });

  const onResize = () => applyLayout();
  window.addEventListener('resize', onResize);

  const close = () => {
    window.removeEventListener('resize', onResize);
    panel.remove();
    if (typeof options.onClose === 'function') options.onClose();
  };
  closeBtn.addEventListener('click', close);
  header.appendChild(closeBtn);

  const body = document.createElement('div');
  Object.assign(body.style, {
    flex: '1',
    overflow: 'auto',
    padding: '16px',
    WebkitOverflowScrolling: 'touch',
  });
  body.innerHTML = options.content || '';

  panel.appendChild(header);
  panel.appendChild(body);
  (document.body || document.documentElement).appendChild(panel);

  if (typeof options.onOpen === 'function') options.onOpen();
  host.log('Panel added');
  return panel;
}
