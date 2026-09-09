// Example feature: adds a floating button on every page of the plugin's domains.
// Delete this file (and its import in src/main.js) once you have real features.

export const name = 'example';

/** @param {string} path location.pathname */
export function matches(path) {
  return true;
}

/** @param {object} WSI the SDK  @param {{url: string, path: string, config: object}} ctx */
export function run(WSI, ctx) {
  WSI.addButton({
    text: 'Hi',
    position: 'bottom-right',
    onClick: () => WSI.log(`clicked on ${ctx.path}`),
  });
  WSI.log(`${name} feature ready`);
}
