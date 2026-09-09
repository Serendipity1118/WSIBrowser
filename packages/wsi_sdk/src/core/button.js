// WSI.addButton: floating, draggable button.
//
// Compatible with WSI 1.x (class name, positions, return value, drag persistence)
// with the changes required by WSI Browser:
//   - Pointer Events instead of mouse events (touch + mouse + pen)
//   - tap target of at least 44 x 44 CSS px
//   - default offsets respect the safe area (notch / home indicator)
//
// The button lives in the light DOM on purpose: sample plugins style
// `.wsi-floating-button` from their own style.css, and that must keep working.

const MIN_TAP = 44;
const EDGE = 20;
const DRAG_THRESHOLD = 4;

const POSITIONS = {
  'bottom-right': { bottom: `calc(${EDGE}px + env(safe-area-inset-bottom, 0px))`, right: `calc(${EDGE}px + env(safe-area-inset-right, 0px))` },
  'bottom-left': { bottom: `calc(${EDGE}px + env(safe-area-inset-bottom, 0px))`, left: `calc(${EDGE}px + env(safe-area-inset-left, 0px))` },
  'top-right': { top: `calc(${EDGE}px + env(safe-area-inset-top, 0px))`, right: `calc(${EDGE}px + env(safe-area-inset-right, 0px))` },
  'top-left': { top: `calc(${EDGE}px + env(safe-area-inset-top, 0px))`, left: `calc(${EDGE}px + env(safe-area-inset-left, 0px))` },
};

function clampToViewport(btn, left, top) {
  const maxLeft = Math.max(0, window.innerWidth - btn.offsetWidth);
  const maxTop = Math.max(0, window.innerHeight - btn.offsetHeight);
  return {
    left: Math.round(Math.max(0, Math.min(maxLeft, left))),
    top: Math.round(Math.max(0, Math.min(maxTop, top))),
  };
}

function applyAbsolute(btn, left, top) {
  btn.style.left = `${left}px`;
  btn.style.top = `${top}px`;
  btn.style.right = 'auto';
  btn.style.bottom = 'auto';
}

/**
 * @param {object} host  { adapter, log }
 * @param {number} buttonIndex  index of this button within the plugin (persistence key)
 * @param {object} options  { text, icon, position, onClick }
 */
export function createButton(host, buttonIndex, options = {}) {
  const btn = document.createElement('button');
  btn.type = 'button';
  btn.textContent = options.icon
    ? `${options.icon} ${options.text || ''}`
    : options.text || '';
  btn.className = 'wsi-floating-button';
  btn.dataset.wsiButtonIndex = String(buttonIndex);

  const pos = options.position || 'bottom-right';
  Object.assign(btn.style, {
    position: 'fixed',
    zIndex: '2147483647',
    minWidth: `${MIN_TAP}px`,
    minHeight: `${MIN_TAP}px`,
    padding: '10px 16px',
    border: 'none',
    borderRadius: '8px',
    background: '#4688F1',
    color: '#fff',
    fontSize: '14px',
    lineHeight: '1.2',
    cursor: 'grab',
    boxShadow: '0 2px 8px rgba(0,0,0,0.2)',
    userSelect: 'none',
    webkitUserSelect: 'none',
    touchAction: 'none',
    webkitTapHighlightColor: 'transparent',
    ...(POSITIONS[pos] || POSITIONS['bottom-right']),
  });
  btn.title = (options.text || '') + '（ドラッグで移動）';
  (document.body || document.documentElement).appendChild(btn);

  // Restore persisted position (clamped so it never ends up off-screen).
  host.adapter.buttonPos.get(buttonIndex).then((saved) => {
    if (!saved) return;
    const { left, top } = clampToViewport(
      btn,
      parseInt(saved.left, 10) || 0,
      parseInt(saved.top, 10) || 0,
    );
    applyAbsolute(btn, left, top);
  }).catch(() => {});

  let dragging = false;
  let moved = false;
  let pointerId = null;
  let startX = 0;
  let startY = 0;
  let offsetX = 0;
  let offsetY = 0;

  btn.addEventListener('pointerdown', (e) => {
    if (e.pointerType === 'mouse' && e.button !== 0) return;
    dragging = true;
    moved = false;
    pointerId = e.pointerId;
    startX = e.clientX;
    startY = e.clientY;
    const rect = btn.getBoundingClientRect();
    offsetX = e.clientX - rect.left;
    offsetY = e.clientY - rect.top;
    btn.style.cursor = 'grabbing';
    try { btn.setPointerCapture(e.pointerId); } catch { /* ignore */ }
    e.preventDefault();
  });

  // Keep the page's text selection (plugins read window.getSelection() in onClick)
  // and do not move focus away from the page.
  btn.addEventListener('mousedown', (e) => e.preventDefault());

  btn.addEventListener('pointermove', (e) => {
    if (!dragging || e.pointerId !== pointerId) return;
    if (!moved) {
      const dx = Math.abs(e.clientX - startX);
      const dy = Math.abs(e.clientY - startY);
      if (dx + dy > DRAG_THRESHOLD) moved = true;
    }
    if (moved) {
      const { left, top } = clampToViewport(btn, e.clientX - offsetX, e.clientY - offsetY);
      applyAbsolute(btn, left, top);
    }
  });

  const endDrag = (e) => {
    if (!dragging || (e && e.pointerId !== pointerId)) return;
    dragging = false;
    pointerId = null;
    btn.style.cursor = 'grab';
    if (moved) {
      host.adapter.buttonPos
        .set(buttonIndex, { left: btn.style.left, top: btn.style.top })
        .catch(() => {});
    }
  };
  btn.addEventListener('pointerup', endDrag);
  btn.addEventListener('pointercancel', endDrag);

  // A click right after a drag is suppressed (accidental activation).
  btn.addEventListener('click', (e) => {
    if (moved) {
      e.preventDefault();
      e.stopImmediatePropagation();
      moved = false;
      return;
    }
    if (typeof options.onClick === 'function') options.onClick(e);
  });

  host.log('Button added');
  return btn;
}
