// Copy plugins/_template (source of truth) into this package's template/.
import { cpSync, rmSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const src = join(here, '..', '..', '..', 'plugins', '_template');
const dest = join(here, '..', 'template');
if (!existsSync(src)) {
  console.error(`template source not found: ${src}`);
  process.exit(1);
}
rmSync(dest, { recursive: true, force: true });
cpSync(src, dest, { recursive: true });
console.log(`synced ${src} -> ${dest}`);
