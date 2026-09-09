// __NAME__ - entry point injected into matching pages.
//
// Keep this file a dispatcher: it only maps the current path to a feature.
// Put the actual behaviour in src/features/<name>.js (one feature per file).
import * as example from './features/example.js';

const features = [example];

const ctx = {
  url: location.href,
  path: location.pathname,
  config: WSI.getConfig(),
};

for (const feature of features) {
  if (!feature.matches(ctx.path)) continue;
  try {
    feature.run(WSI, ctx);
  } catch (e) {
    WSI.log(`feature ${feature.name} failed: ${e && e.message ? e.message : e}`);
  }
}
