// plugin.json validation (要件定義「プラグイン形式 v2 / 検証ルール」).
// Pure: takes the parsed manifest and a `fileExists(relPath)` callback.

export const PERMISSIONS = Object.freeze([
  'storage', 'fetch', 'credentials', 'device', 'share', 'files', 'clipboard',
  'wakeLock', 'pip', 'blockResources', 'tabs', 'pages', 'menu', 'navigation', 'policy',
]);

export const RUN_AT = Object.freeze(['document_start', 'document_end', 'document_idle']);
export const PAGE_DISPLAY = Object.freeze(['fullscreen', 'sheet']);
export const MENU_TYPES = Object.freeze(['page', 'action', 'toggle', 'separator']);
export const SETTING_TYPES = Object.freeze(['string', 'number', 'boolean', 'select']);

const ID_RE = /^[a-zA-Z0-9-]+$/;
// semver 2.0.0 (major.minor.patch with optional prerelease / build)
const SEMVER_RE = /^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$/;
const DOMAIN_RE = /^(\*|(\*\.)?[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+)$/i;

function isObject(v) {
  return v !== null && typeof v === 'object' && !Array.isArray(v);
}

function isHttps(url) {
  try {
    return new URL(url).protocol === 'https:';
  } catch {
    return false;
  }
}

/**
 * @param {unknown} def parsed plugin.json
 * @param {(relPath: string) => boolean} fileExists
 * @returns {string[]} errors (empty when valid)
 */
export function validateManifest(def, fileExists = () => true) {
  const errors = [];
  const err = (m) => errors.push(m);
  if (!isObject(def)) return ['plugin.json must be a JSON object'];

  const fv = def.formatVersion === undefined ? 1 : def.formatVersion;
  if (fv !== 1 && fv !== 2) err('formatVersion must be 1 or 2');

  if (typeof def.id !== 'string' || !def.id) err('id is required');
  else if (!ID_RE.test(def.id)) err('id must match ^[a-zA-Z0-9-]+$');

  if (typeof def.name !== 'string' || !def.name) err('name is required');

  if (typeof def.version !== 'string' || !def.version) err('version is required');
  else if (!SEMVER_RE.test(def.version)) err(`version must be semantic (x.y.z): ${def.version}`);

  for (const k of ['description', 'author']) {
    if (def[k] !== undefined && typeof def[k] !== 'string') err(`${k} must be a string`);
  }

  if (!Array.isArray(def.domains) || def.domains.length === 0) err('domains must be a non-empty array');
  else {
    def.domains.forEach((d, i) => {
      if (typeof d !== 'string' || !DOMAIN_RE.test(d)) err(`domains[${i}] is not a valid domain pattern: ${d}`);
    });
  }

  if (def.paths !== undefined) {
    if (!Array.isArray(def.paths)) err('paths must be an array of glob strings');
    else def.paths.forEach((p, i) => {
      if (typeof p !== 'string' || !p.startsWith('/')) err(`paths[${i}] must be a glob starting with "/": ${p}`);
    });
  }

  if (!isObject(def.scripts) || typeof def.scripts.main !== 'string' || !def.scripts.main) err('scripts.main is required');
  else {
    if (!fileExists(def.scripts.main)) err(`scripts.main not found: ${def.scripts.main}`);
    if (def.scripts.runAt !== undefined && !RUN_AT.includes(def.scripts.runAt)) err(`scripts.runAt must be one of ${RUN_AT.join(' / ')}`);
  }

  if (def.styles !== undefined) {
    if (!Array.isArray(def.styles)) err('styles must be an array');
    else def.styles.forEach((s, i) => {
      if (typeof s !== 'string') err(`styles[${i}] must be a string`);
      else if (!fileExists(s)) err(`styles[${i}] not found: ${s}`);
    });
  }

  const permissions = Array.isArray(def.permissions) ? def.permissions : [];
  if (def.permissions !== undefined) {
    if (!Array.isArray(def.permissions)) err('permissions must be an array');
    else def.permissions.forEach((p, i) => {
      if (!PERMISSIONS.includes(p)) err(`permissions[${i}] is unknown: ${p}`);
    });
  }

  if (def.background !== undefined) {
    if (typeof def.background !== 'string' || !def.background) err('background must be a file path');
    else if (!fileExists(def.background)) err(`background not found: ${def.background}`);
  }

  const pageNames = new Set();
  if (def.pages !== undefined) {
    if (!isObject(def.pages)) err('pages must be an object');
    else {
      for (const [name, page] of Object.entries(def.pages)) {
        pageNames.add(name);
        if (!isObject(page) || typeof page.file !== 'string') { err(`pages.${name}.file is required`); continue; }
        if (!fileExists(page.file)) err(`pages.${name}.file not found: ${page.file}`);
        if (page.display !== undefined && !PAGE_DISPLAY.includes(page.display)) err(`pages.${name}.display must be fullscreen / sheet`);
      }
      if (pageNames.size > 0 && !permissions.includes('pages')) err('pages requires the "pages" permission');
    }
  }

  if (def.menu !== undefined) {
    if (!Array.isArray(def.menu)) err('menu must be an array');
    else {
      def.menu.forEach((item, i) => {
        if (!isObject(item)) { err(`menu[${i}] must be an object`); return; }
        if (!MENU_TYPES.includes(item.type)) err(`menu[${i}].type must be one of ${MENU_TYPES.join(' / ')}`);
        if (item.type !== 'separator' && (typeof item.id !== 'string' || !item.id)) err(`menu[${i}].id is required`);
        if (item.type !== 'separator' && (typeof item.label !== 'string' || !item.label)) err(`menu[${i}].label is required`);
        if (item.type === 'page' && !pageNames.has(item.page)) err(`menu[${i}].page refers to an unknown page: ${item.page}`);
      });
      if (def.menu.length > 0 && !permissions.includes('menu')) err('menu requires the "menu" permission');
    }
  }

  if (def.settingsSchema !== undefined) {
    if (!Array.isArray(def.settingsSchema)) err('settingsSchema must be an array');
    else def.settingsSchema.forEach((s, i) => {
      if (!isObject(s)) { err(`settingsSchema[${i}] must be an object`); return; }
      if (typeof s.key !== 'string' || !s.key) err(`settingsSchema[${i}].key is required`);
      if (!SETTING_TYPES.includes(s.type)) err(`settingsSchema[${i}].type must be one of ${SETTING_TYPES.join(' / ')}`);
      if (s.type === 'select' && !Array.isArray(s.options)) err(`settingsSchema[${i}].options is required for select`);
    });
  }

  if (def.policy !== undefined) {
    if (!isObject(def.policy)) err('policy must be an object');
    else {
      if (typeof def.policy.url !== 'string' || !isHttps(def.policy.url)) err('policy.url must be an https URL');
      if (def.policy.ttlSeconds !== undefined && !(Number.isFinite(def.policy.ttlSeconds) && def.policy.ttlSeconds >= 60)) err('policy.ttlSeconds must be a number >= 60');
      if (def.policy.defaults !== undefined && !isObject(def.policy.defaults)) err('policy.defaults must be an object');
      if (!permissions.includes('policy')) err('policy requires the "policy" permission');
    }
  }

  if (def.updateUrl !== undefined && (typeof def.updateUrl !== 'string' || !isHttps(def.updateUrl))) err('updateUrl must be an https URL');

  if (def.config !== undefined && !isObject(def.config)) err('config must be an object');

  if (fv === 1) {
    for (const k of ['paths', 'background', 'pages', 'menu', 'permissions', 'settingsSchema', 'policy', 'updateUrl']) {
      if (def[k] !== undefined) err(`${k} requires formatVersion 2`);
    }
  }

  return errors;
}

/** Files the manifest references, relative to the plugin directory (used by pack). */
export function referencedFiles(def) {
  const files = new Set(['plugin.json']);
  if (def.scripts && def.scripts.main) files.add(def.scripts.main);
  for (const s of def.styles || []) files.add(s);
  if (def.background) files.add(def.background);
  for (const p of Object.values(def.pages || {})) if (p && p.file) files.add(p.file);
  return Array.from(files);
}
