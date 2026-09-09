// WSI.onPageLoad: SPA navigation detection.
//
// Sources, in order of preference:
//   1. 'wsi:urlchange' CustomEvent dispatched by the host (WSI Browser wires
//      onUpdateVisitedHistory to it; see F-03-5)
//   2. popstate
//   3. MutationObserver fallback (WSI 1.x behaviour), kept because
//      pushState-driven SPAs do not fire popstate and not every host
//      dispatches the custom event.
//
// The callback receives the new URL and is only called when location.href
// actually changed since the last notification.

export const URL_CHANGE_EVENT = 'wsi:urlchange';

export function onPageLoad(callback) {
  if (typeof callback !== 'function') return () => {};

  let lastUrl = location.href;
  const notify = () => {
    if (location.href === lastUrl) return;
    lastUrl = location.href;
    try {
      callback(lastUrl);
    } catch (e) {
      console.error('[WSI] onPageLoad callback error:', e);
    }
  };

  window.addEventListener(URL_CHANGE_EVENT, notify);
  window.addEventListener('popstate', notify);

  let observer = null;
  const target = document.body || document.documentElement;
  if (target && typeof MutationObserver === 'function') {
    observer = new MutationObserver(notify);
    observer.observe(target, { childList: true, subtree: true });
  }

  return () => {
    window.removeEventListener(URL_CHANGE_EVENT, notify);
    window.removeEventListener('popstate', notify);
    if (observer) observer.disconnect();
  };
}
