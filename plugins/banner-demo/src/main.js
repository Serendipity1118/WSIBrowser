// Banner Demo - entry point. Dispatches to features by path.
import * as banner from './features/banner.js';

const features = [banner];
const ctx = { url: location.href, path: location.pathname, config: WSI.getConfig() };

for (const feature of features) {
  if (!feature.matches(ctx.path)) continue;
  Promise.resolve(feature.run(WSI, ctx)).catch((e) => WSI.log(`feature ${feature.name} failed: ${e && e.message ? e.message : e}`));
}
