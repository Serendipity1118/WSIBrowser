// plugin.json model and validator (要件定義「プラグイン形式 v2 / 検証ルール」).
// Mirrors packages/wsi_plugin_tools/src/manifest.js so the CLI and the host
// accept exactly the same files.

const List<String> kAllPermissions = [
  'storage', 'fetch', 'credentials', 'device', 'share', 'files', 'clipboard',
  'wakeLock', 'pip', 'blockResources', 'tabs', 'pages', 'menu', 'navigation', 'policy',
];

/// Permissions that need explicit user consent at import (F-02-2).
const List<String> kSensitivePermissions = ['credentials', 'files', 'device', 'clipboard', 'tabs', 'navigation'];

const List<String> kRunAt = ['document_start', 'document_end', 'document_idle'];
const List<String> kPageDisplay = ['fullscreen', 'sheet'];
const List<String> kMenuTypes = ['page', 'action', 'toggle', 'separator'];
const List<String> kSettingTypes = ['string', 'number', 'boolean', 'select'];

final RegExp _idRe = RegExp(r'^[a-zA-Z0-9-]+$');
final RegExp _semverRe = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$');
final RegExp _domainRe = RegExp(r'^(\*|(\*\.)?[a-z0-9]([a-z0-9-]*[a-z0-9])?(\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)+)$', caseSensitive: false);

class PluginPage {
  const PluginPage({required this.name, required this.file, this.display = 'fullscreen'});
  final String name;
  final String file;
  final String display;
}

class PluginMenuItem {
  const PluginMenuItem({required this.type, this.id, this.label, this.icon, this.page, this.checked});
  final String type;
  final String? id;
  final String? label;
  final String? icon;
  final String? page;
  final bool? checked;
}

class PluginSetting {
  const PluginSetting({required this.key, required this.type, this.label, this.description, this.defaultValue, this.options});
  final String key;
  final String type;
  final String? label;
  final String? description;
  final Object? defaultValue;
  final List<Object?>? options;
}

class PluginPolicy {
  const PluginPolicy({required this.url, this.ttlSeconds = 3600, this.defaults = const {}});
  final String url;
  final int ttlSeconds;
  final Map<String, Object?> defaults;
}

/// Parsed plugin.json. Construct with [PluginManifest.parse] after [validateManifest].
class PluginManifest {
  PluginManifest({
    required this.raw,
    required this.formatVersion,
    required this.id,
    required this.name,
    required this.version,
    required this.description,
    required this.author,
    required this.domains,
    required this.paths,
    required this.main,
    required this.runAt,
    required this.styles,
    required this.background,
    required this.pages,
    required this.menu,
    required this.permissions,
    required this.settingsSchema,
    required this.policy,
    required this.updateUrl,
    required this.config,
  });

  final Map<String, Object?> raw;
  final int formatVersion;
  final String id;
  final String name;
  final String version;
  final String description;
  final String author;
  final List<String> domains;
  final List<String> paths;
  final String main;
  final String runAt;
  final List<String> styles;
  final String? background;
  final List<PluginPage> pages;
  final List<PluginMenuItem> menu;

  /// Effective permissions: v1 plugins get storage + fetch, v2 what they declare (+ storage).
  final List<String> permissions;
  final List<PluginSetting> settingsSchema;
  final PluginPolicy? policy;
  final String? updateUrl;
  final Map<String, Object?> config;

  bool get isV2 => formatVersion == 2;
  bool has(String permission) => permissions.contains(permission);
  List<String> get sensitivePermissions => permissions.where(kSensitivePermissions.contains).toList();

  /// Files the manifest references (relative paths inside the ZIP).
  List<String> get referencedFiles => [
        'plugin.json',
        main,
        ...styles,
        ?background,
        ...pages.map((p) => p.file),
      ];

  static PluginManifest parse(Map<String, Object?> json) {
    final errors = validateManifest(json);
    if (errors.isNotEmpty) {
      throw ManifestException(errors);
    }
    final fv = (json['formatVersion'] as num?)?.toInt() ?? 1;
    final scripts = json['scripts'] as Map<String, Object?>;
    final declared = (json['permissions'] as List?)?.cast<String>();
    final permissions = <String>{'storage', ...(declared ?? const ['storage', 'fetch'])}.toList();
    final pagesJson = json['pages'] as Map<String, Object?>? ?? const {};
    final policyJson = json['policy'] as Map<String, Object?>?;
    return PluginManifest(
      raw: json,
      formatVersion: fv,
      id: json['id'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      description: json['description'] as String? ?? '',
      author: json['author'] as String? ?? '',
      domains: (json['domains'] as List).cast<String>(),
      paths: (json['paths'] as List?)?.cast<String>() ?? const [],
      main: scripts['main'] as String,
      runAt: scripts['runAt'] as String? ?? 'document_idle',
      styles: (json['styles'] as List?)?.cast<String>() ?? const [],
      background: json['background'] as String?,
      pages: [
        for (final e in pagesJson.entries)
          PluginPage(
            name: e.key,
            file: (e.value as Map)['file'] as String,
            display: (e.value as Map)['display'] as String? ?? 'fullscreen',
          ),
      ],
      menu: [
        for (final m in (json['menu'] as List?) ?? const [])
          PluginMenuItem(
            type: (m as Map)['type'] as String,
            id: m['id'] as String?,
            label: m['label'] as String?,
            icon: m['icon'] as String?,
            page: m['page'] as String?,
            checked: m['checked'] as bool?,
          ),
      ],
      permissions: permissions,
      settingsSchema: [
        for (final s in (json['settingsSchema'] as List?) ?? const [])
          PluginSetting(
            key: (s as Map)['key'] as String,
            type: s['type'] as String,
            label: s['label'] as String?,
            description: s['description'] as String?,
            defaultValue: s['default'],
            options: (s['options'] as List?)?.cast<Object?>(),
          ),
      ],
      policy: policyJson == null
          ? null
          : PluginPolicy(
              url: policyJson['url'] as String,
              ttlSeconds: (policyJson['ttlSeconds'] as num?)?.toInt() ?? 3600,
              defaults: (policyJson['defaults'] as Map?)?.cast<String, Object?>() ?? const {},
            ),
      updateUrl: json['updateUrl'] as String?,
      config: (json['config'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}

class ManifestException implements Exception {
  ManifestException(this.errors);
  final List<String> errors;
  @override
  String toString() => 'Invalid plugin.json:\n  - ${errors.join('\n  - ')}';
}

bool _isHttps(Object? url) {
  if (url is! String) return false;
  final u = Uri.tryParse(url);
  return u != null && u.scheme == 'https' && u.host.isNotEmpty;
}

/// Returns the list of problems; empty means valid. [fileExists] answers
/// whether a referenced path exists in the ZIP (default: assume it does).
List<String> validateManifest(Object? def, {bool Function(String path)? fileExists}) {
  final exists = fileExists ?? (_) => true;
  final errors = <String>[];
  void err(String m) => errors.add(m);
  if (def is! Map) return ['plugin.json must be a JSON object'];

  final fvRaw = def['formatVersion'];
  final fv = fvRaw == null ? 1 : (fvRaw is num ? fvRaw.toInt() : -1);
  if (fv != 1 && fv != 2) err('formatVersion must be 1 or 2');

  final id = def['id'];
  if (id is! String || id.isEmpty) {
    err('id is required');
  } else if (!_idRe.hasMatch(id)) {
    err('id must match ^[a-zA-Z0-9-]+\$');
  }

  final name = def['name'];
  if (name is! String || name.isEmpty) err('name is required');

  final version = def['version'];
  if (version is! String || version.isEmpty) {
    err('version is required');
  } else if (!_semverRe.hasMatch(version)) {
    err('version must be semantic (x.y.z): $version');
  }

  for (final k in ['description', 'author']) {
    if (def[k] != null && def[k] is! String) err('$k must be a string');
  }

  final domains = def['domains'];
  if (domains is! List || domains.isEmpty) {
    err('domains must be a non-empty array');
  } else {
    for (var i = 0; i < domains.length; i++) {
      final d = domains[i];
      if (d is! String || !_domainRe.hasMatch(d)) err('domains[$i] is not a valid domain pattern: $d');
    }
  }

  final paths = def['paths'];
  if (paths != null) {
    if (paths is! List) {
      err('paths must be an array of glob strings');
    } else {
      for (var i = 0; i < paths.length; i++) {
        final p = paths[i];
        if (p is! String || !p.startsWith('/')) err('paths[$i] must be a glob starting with "/": $p');
      }
    }
  }

  final scripts = def['scripts'];
  if (scripts is! Map || scripts['main'] is! String || (scripts['main'] as String).isEmpty) {
    err('scripts.main is required');
  } else {
    if (!exists(scripts['main'] as String)) err('scripts.main not found: ${scripts['main']}');
    final runAt = scripts['runAt'];
    if (runAt != null && !kRunAt.contains(runAt)) err('scripts.runAt must be one of ${kRunAt.join(' / ')}');
  }

  final styles = def['styles'];
  if (styles != null) {
    if (styles is! List) {
      err('styles must be an array');
    } else {
      for (var i = 0; i < styles.length; i++) {
        final s = styles[i];
        if (s is! String) {
          err('styles[$i] must be a string');
        } else if (!exists(s)) {
          err('styles[$i] not found: $s');
        }
      }
    }
  }

  final permissionsRaw = def['permissions'];
  final permissions = permissionsRaw is List ? permissionsRaw : const [];
  if (permissionsRaw != null) {
    if (permissionsRaw is! List) {
      err('permissions must be an array');
    } else {
      for (var i = 0; i < permissionsRaw.length; i++) {
        if (!kAllPermissions.contains(permissionsRaw[i])) err('permissions[$i] is unknown: ${permissionsRaw[i]}');
      }
    }
  }

  final background = def['background'];
  if (background != null) {
    if (background is! String || background.isEmpty) {
      err('background must be a file path');
    } else if (!exists(background)) {
      err('background not found: $background');
    }
  }

  final pageNames = <String>{};
  final pages = def['pages'];
  if (pages != null) {
    if (pages is! Map) {
      err('pages must be an object');
    } else {
      for (final e in pages.entries) {
        final n = e.key.toString();
        pageNames.add(n);
        final page = e.value;
        if (page is! Map || page['file'] is! String) {
          err('pages.$n.file is required');
          continue;
        }
        if (!exists(page['file'] as String)) err('pages.$n.file not found: ${page['file']}');
        final display = page['display'];
        if (display != null && !kPageDisplay.contains(display)) err('pages.$n.display must be fullscreen / sheet');
      }
      if (pageNames.isNotEmpty && !permissions.contains('pages')) err('pages requires the "pages" permission');
    }
  }

  final menu = def['menu'];
  if (menu != null) {
    if (menu is! List) {
      err('menu must be an array');
    } else {
      for (var i = 0; i < menu.length; i++) {
        final item = menu[i];
        if (item is! Map) {
          err('menu[$i] must be an object');
          continue;
        }
        final type = item['type'];
        if (!kMenuTypes.contains(type)) err('menu[$i].type must be one of ${kMenuTypes.join(' / ')}');
        if (type != 'separator') {
          if (item['id'] is! String || (item['id'] as String).isEmpty) err('menu[$i].id is required');
          if (item['label'] is! String || (item['label'] as String).isEmpty) err('menu[$i].label is required');
        }
        if (type == 'page' && !pageNames.contains(item['page'])) err('menu[$i].page refers to an unknown page: ${item['page']}');
      }
      if (menu.isNotEmpty && !permissions.contains('menu')) err('menu requires the "menu" permission');
    }
  }

  final schema = def['settingsSchema'];
  if (schema != null) {
    if (schema is! List) {
      err('settingsSchema must be an array');
    } else {
      for (var i = 0; i < schema.length; i++) {
        final s = schema[i];
        if (s is! Map) {
          err('settingsSchema[$i] must be an object');
          continue;
        }
        if (s['key'] is! String || (s['key'] as String).isEmpty) err('settingsSchema[$i].key is required');
        if (!kSettingTypes.contains(s['type'])) err('settingsSchema[$i].type must be one of ${kSettingTypes.join(' / ')}');
        if (s['type'] == 'select' && s['options'] is! List) err('settingsSchema[$i].options is required for select');
      }
    }
  }

  final policy = def['policy'];
  if (policy != null) {
    if (policy is! Map) {
      err('policy must be an object');
    } else {
      if (!_isHttps(policy['url'])) err('policy.url must be an https URL');
      final ttl = policy['ttlSeconds'];
      if (ttl != null && !(ttl is num && ttl >= 60)) err('policy.ttlSeconds must be a number >= 60');
      if (policy['defaults'] != null && policy['defaults'] is! Map) err('policy.defaults must be an object');
      if (!permissions.contains('policy')) err('policy requires the "policy" permission');
    }
  }

  if (def['updateUrl'] != null && !_isHttps(def['updateUrl'])) err('updateUrl must be an https URL');

  if (def['config'] != null && def['config'] is! Map) err('config must be an object');

  if (fv == 1) {
    for (final k in ['paths', 'background', 'pages', 'menu', 'permissions', 'settingsSchema', 'policy', 'updateUrl']) {
      if (def[k] != null) err('$k requires formatVersion 2');
    }
  }

  return errors;
}
