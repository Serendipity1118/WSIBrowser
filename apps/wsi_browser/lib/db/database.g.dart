// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PluginsTable extends Plugins with TableInfo<$PluginsTable, Plugin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PluginsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> manifest =
      GeneratedColumn<String>(
        'manifest',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($PluginsTable.$convertermanifest);
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<DateTime> installedAt = GeneratedColumn<DateTime>(
    'installed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latestVersionMeta = const VerificationMeta(
    'latestVersion',
  );
  @override
  late final GeneratedColumn<String> latestVersion = GeneratedColumn<String>(
    'latest_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _latestCheckedAtMeta = const VerificationMeta(
    'latestCheckedAt',
  );
  @override
  late final GeneratedColumn<DateTime> latestCheckedAt =
      GeneratedColumn<DateTime>(
        'latest_checked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    version,
    manifest,
    enabled,
    installedAt,
    updatedAt,
    latestVersion,
    latestCheckedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plugins';
  @override
  VerificationContext validateIntegrity(
    Insertable<Plugin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('latest_version')) {
      context.handle(
        _latestVersionMeta,
        latestVersion.isAcceptableOrUnknown(
          data['latest_version']!,
          _latestVersionMeta,
        ),
      );
    }
    if (data.containsKey('latest_checked_at')) {
      context.handle(
        _latestCheckedAtMeta,
        latestCheckedAt.isAcceptableOrUnknown(
          data['latest_checked_at']!,
          _latestCheckedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Plugin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Plugin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      manifest: $PluginsTable.$convertermanifest.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}manifest'],
        )!,
      ),
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}installed_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      latestVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latest_version'],
      ),
      latestCheckedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}latest_checked_at'],
      ),
    );
  }

  @override
  $PluginsTable createAlias(String alias) {
    return $PluginsTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertermanifest =
      const JsonConverter();
}

class Plugin extends DataClass implements Insertable<Plugin> {
  final String id;
  final String name;
  final String version;

  /// The full plugin.json.
  final Object? manifest;
  final bool enabled;
  final DateTime installedAt;
  final DateTime updatedAt;
  final String? latestVersion;
  final DateTime? latestCheckedAt;
  const Plugin({
    required this.id,
    required this.name,
    required this.version,
    this.manifest,
    required this.enabled,
    required this.installedAt,
    required this.updatedAt,
    this.latestVersion,
    this.latestCheckedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || manifest != null) {
      map['manifest'] = Variable<String>(
        $PluginsTable.$convertermanifest.toSql(manifest),
      );
    }
    map['enabled'] = Variable<bool>(enabled);
    map['installed_at'] = Variable<DateTime>(installedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || latestVersion != null) {
      map['latest_version'] = Variable<String>(latestVersion);
    }
    if (!nullToAbsent || latestCheckedAt != null) {
      map['latest_checked_at'] = Variable<DateTime>(latestCheckedAt);
    }
    return map;
  }

  PluginsCompanion toCompanion(bool nullToAbsent) {
    return PluginsCompanion(
      id: Value(id),
      name: Value(name),
      version: Value(version),
      manifest: manifest == null && nullToAbsent
          ? const Value.absent()
          : Value(manifest),
      enabled: Value(enabled),
      installedAt: Value(installedAt),
      updatedAt: Value(updatedAt),
      latestVersion: latestVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(latestVersion),
      latestCheckedAt: latestCheckedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(latestCheckedAt),
    );
  }

  factory Plugin.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Plugin(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      version: serializer.fromJson<String>(json['version']),
      manifest: serializer.fromJson<Object?>(json['manifest']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      installedAt: serializer.fromJson<DateTime>(json['installedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      latestVersion: serializer.fromJson<String?>(json['latestVersion']),
      latestCheckedAt: serializer.fromJson<DateTime?>(json['latestCheckedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'version': serializer.toJson<String>(version),
      'manifest': serializer.toJson<Object?>(manifest),
      'enabled': serializer.toJson<bool>(enabled),
      'installedAt': serializer.toJson<DateTime>(installedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'latestVersion': serializer.toJson<String?>(latestVersion),
      'latestCheckedAt': serializer.toJson<DateTime?>(latestCheckedAt),
    };
  }

  Plugin copyWith({
    String? id,
    String? name,
    String? version,
    Value<Object?> manifest = const Value.absent(),
    bool? enabled,
    DateTime? installedAt,
    DateTime? updatedAt,
    Value<String?> latestVersion = const Value.absent(),
    Value<DateTime?> latestCheckedAt = const Value.absent(),
  }) => Plugin(
    id: id ?? this.id,
    name: name ?? this.name,
    version: version ?? this.version,
    manifest: manifest.present ? manifest.value : this.manifest,
    enabled: enabled ?? this.enabled,
    installedAt: installedAt ?? this.installedAt,
    updatedAt: updatedAt ?? this.updatedAt,
    latestVersion: latestVersion.present
        ? latestVersion.value
        : this.latestVersion,
    latestCheckedAt: latestCheckedAt.present
        ? latestCheckedAt.value
        : this.latestCheckedAt,
  );
  Plugin copyWithCompanion(PluginsCompanion data) {
    return Plugin(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      version: data.version.present ? data.version.value : this.version,
      manifest: data.manifest.present ? data.manifest.value : this.manifest,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      latestVersion: data.latestVersion.present
          ? data.latestVersion.value
          : this.latestVersion,
      latestCheckedAt: data.latestCheckedAt.present
          ? data.latestCheckedAt.value
          : this.latestCheckedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Plugin(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('manifest: $manifest, ')
          ..write('enabled: $enabled, ')
          ..write('installedAt: $installedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('latestVersion: $latestVersion, ')
          ..write('latestCheckedAt: $latestCheckedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    version,
    manifest,
    enabled,
    installedAt,
    updatedAt,
    latestVersion,
    latestCheckedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Plugin &&
          other.id == this.id &&
          other.name == this.name &&
          other.version == this.version &&
          other.manifest == this.manifest &&
          other.enabled == this.enabled &&
          other.installedAt == this.installedAt &&
          other.updatedAt == this.updatedAt &&
          other.latestVersion == this.latestVersion &&
          other.latestCheckedAt == this.latestCheckedAt);
}

class PluginsCompanion extends UpdateCompanion<Plugin> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> version;
  final Value<Object?> manifest;
  final Value<bool> enabled;
  final Value<DateTime> installedAt;
  final Value<DateTime> updatedAt;
  final Value<String?> latestVersion;
  final Value<DateTime?> latestCheckedAt;
  final Value<int> rowid;
  const PluginsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.version = const Value.absent(),
    this.manifest = const Value.absent(),
    this.enabled = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.latestVersion = const Value.absent(),
    this.latestCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PluginsCompanion.insert({
    required String id,
    required String name,
    required String version,
    required Object? manifest,
    this.enabled = const Value.absent(),
    required DateTime installedAt,
    required DateTime updatedAt,
    this.latestVersion = const Value.absent(),
    this.latestCheckedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       version = Value(version),
       manifest = Value(manifest),
       installedAt = Value(installedAt),
       updatedAt = Value(updatedAt);
  static Insertable<Plugin> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? version,
    Expression<String>? manifest,
    Expression<bool>? enabled,
    Expression<DateTime>? installedAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? latestVersion,
    Expression<DateTime>? latestCheckedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (version != null) 'version': version,
      if (manifest != null) 'manifest': manifest,
      if (enabled != null) 'enabled': enabled,
      if (installedAt != null) 'installed_at': installedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (latestVersion != null) 'latest_version': latestVersion,
      if (latestCheckedAt != null) 'latest_checked_at': latestCheckedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PluginsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? version,
    Value<Object?>? manifest,
    Value<bool>? enabled,
    Value<DateTime>? installedAt,
    Value<DateTime>? updatedAt,
    Value<String?>? latestVersion,
    Value<DateTime?>? latestCheckedAt,
    Value<int>? rowid,
  }) {
    return PluginsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      manifest: manifest ?? this.manifest,
      enabled: enabled ?? this.enabled,
      installedAt: installedAt ?? this.installedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      latestVersion: latestVersion ?? this.latestVersion,
      latestCheckedAt: latestCheckedAt ?? this.latestCheckedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (manifest.present) {
      map['manifest'] = Variable<String>(
        $PluginsTable.$convertermanifest.toSql(manifest.value),
      );
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<DateTime>(installedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (latestVersion.present) {
      map['latest_version'] = Variable<String>(latestVersion.value);
    }
    if (latestCheckedAt.present) {
      map['latest_checked_at'] = Variable<DateTime>(latestCheckedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PluginsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('version: $version, ')
          ..write('manifest: $manifest, ')
          ..write('enabled: $enabled, ')
          ..write('installedAt: $installedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('latestVersion: $latestVersion, ')
          ..write('latestCheckedAt: $latestCheckedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PluginFilesTable extends PluginFiles
    with TableInfo<$PluginFilesTable, PluginFile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PluginFilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plugins (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<Uint8List> content = GeneratedColumn<Uint8List>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('application/octet-stream'),
  );
  @override
  List<GeneratedColumn> get $columns => [pluginId, path, content, mime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plugin_files';
  @override
  VerificationContext validateIntegrity(
    Insertable<PluginFile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pluginIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginId, path};
  @override
  PluginFile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PluginFile(
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}content'],
      )!,
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
    );
  }

  @override
  $PluginFilesTable createAlias(String alias) {
    return $PluginFilesTable(attachedDatabase, alias);
  }
}

class PluginFile extends DataClass implements Insertable<PluginFile> {
  final String pluginId;
  final String path;
  final Uint8List content;
  final String mime;
  const PluginFile({
    required this.pluginId,
    required this.path,
    required this.content,
    required this.mime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_id'] = Variable<String>(pluginId);
    map['path'] = Variable<String>(path);
    map['content'] = Variable<Uint8List>(content);
    map['mime'] = Variable<String>(mime);
    return map;
  }

  PluginFilesCompanion toCompanion(bool nullToAbsent) {
    return PluginFilesCompanion(
      pluginId: Value(pluginId),
      path: Value(path),
      content: Value(content),
      mime: Value(mime),
    );
  }

  factory PluginFile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PluginFile(
      pluginId: serializer.fromJson<String>(json['pluginId']),
      path: serializer.fromJson<String>(json['path']),
      content: serializer.fromJson<Uint8List>(json['content']),
      mime: serializer.fromJson<String>(json['mime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginId': serializer.toJson<String>(pluginId),
      'path': serializer.toJson<String>(path),
      'content': serializer.toJson<Uint8List>(content),
      'mime': serializer.toJson<String>(mime),
    };
  }

  PluginFile copyWith({
    String? pluginId,
    String? path,
    Uint8List? content,
    String? mime,
  }) => PluginFile(
    pluginId: pluginId ?? this.pluginId,
    path: path ?? this.path,
    content: content ?? this.content,
    mime: mime ?? this.mime,
  );
  PluginFile copyWithCompanion(PluginFilesCompanion data) {
    return PluginFile(
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      path: data.path.present ? data.path.value : this.path,
      content: data.content.present ? data.content.value : this.content,
      mime: data.mime.present ? data.mime.value : this.mime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PluginFile(')
          ..write('pluginId: $pluginId, ')
          ..write('path: $path, ')
          ..write('content: $content, ')
          ..write('mime: $mime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pluginId, path, $driftBlobEquality.hash(content), mime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PluginFile &&
          other.pluginId == this.pluginId &&
          other.path == this.path &&
          $driftBlobEquality.equals(other.content, this.content) &&
          other.mime == this.mime);
}

class PluginFilesCompanion extends UpdateCompanion<PluginFile> {
  final Value<String> pluginId;
  final Value<String> path;
  final Value<Uint8List> content;
  final Value<String> mime;
  final Value<int> rowid;
  const PluginFilesCompanion({
    this.pluginId = const Value.absent(),
    this.path = const Value.absent(),
    this.content = const Value.absent(),
    this.mime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PluginFilesCompanion.insert({
    required String pluginId,
    required String path,
    required Uint8List content,
    this.mime = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pluginId = Value(pluginId),
       path = Value(path),
       content = Value(content);
  static Insertable<PluginFile> custom({
    Expression<String>? pluginId,
    Expression<String>? path,
    Expression<Uint8List>? content,
    Expression<String>? mime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginId != null) 'plugin_id': pluginId,
      if (path != null) 'path': path,
      if (content != null) 'content': content,
      if (mime != null) 'mime': mime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PluginFilesCompanion copyWith({
    Value<String>? pluginId,
    Value<String>? path,
    Value<Uint8List>? content,
    Value<String>? mime,
    Value<int>? rowid,
  }) {
    return PluginFilesCompanion(
      pluginId: pluginId ?? this.pluginId,
      path: path ?? this.path,
      content: content ?? this.content,
      mime: mime ?? this.mime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (content.present) {
      map['content'] = Variable<Uint8List>(content.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PluginFilesCompanion(')
          ..write('pluginId: $pluginId, ')
          ..write('path: $path, ')
          ..write('content: $content, ')
          ..write('mime: $mime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PluginDataTable extends PluginData
    with TableInfo<$PluginDataTable, PluginDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PluginDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plugins (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($PluginDataTable.$convertervalue);
  @override
  List<GeneratedColumn> get $columns => [pluginId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plugin_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<PluginDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pluginIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginId, key};
  @override
  PluginDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PluginDataData(
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: $PluginDataTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
    );
  }

  @override
  $PluginDataTable createAlias(String alias) {
    return $PluginDataTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalue = const JsonConverter();
}

class PluginDataData extends DataClass implements Insertable<PluginDataData> {
  final String pluginId;
  final String key;
  final Object? value;
  const PluginDataData({required this.pluginId, required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_id'] = Variable<String>(pluginId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(
        $PluginDataTable.$convertervalue.toSql(value),
      );
    }
    return map;
  }

  PluginDataCompanion toCompanion(bool nullToAbsent) {
    return PluginDataCompanion(
      pluginId: Value(pluginId),
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory PluginDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PluginDataData(
      pluginId: serializer.fromJson<String>(json['pluginId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Object?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginId': serializer.toJson<String>(pluginId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Object?>(value),
    };
  }

  PluginDataData copyWith({
    String? pluginId,
    String? key,
    Value<Object?> value = const Value.absent(),
  }) => PluginDataData(
    pluginId: pluginId ?? this.pluginId,
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  PluginDataData copyWithCompanion(PluginDataCompanion data) {
    return PluginDataData(
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PluginDataData(')
          ..write('pluginId: $pluginId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pluginId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PluginDataData &&
          other.pluginId == this.pluginId &&
          other.key == this.key &&
          other.value == this.value);
}

class PluginDataCompanion extends UpdateCompanion<PluginDataData> {
  final Value<String> pluginId;
  final Value<String> key;
  final Value<Object?> value;
  final Value<int> rowid;
  const PluginDataCompanion({
    this.pluginId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PluginDataCompanion.insert({
    required String pluginId,
    required String key,
    required Object? value,
    this.rowid = const Value.absent(),
  }) : pluginId = Value(pluginId),
       key = Value(key),
       value = Value(value);
  static Insertable<PluginDataData> custom({
    Expression<String>? pluginId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginId != null) 'plugin_id': pluginId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PluginDataCompanion copyWith({
    Value<String>? pluginId,
    Value<String>? key,
    Value<Object?>? value,
    Value<int>? rowid,
  }) {
    return PluginDataCompanion(
      pluginId: pluginId ?? this.pluginId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $PluginDataTable.$convertervalue.toSql(value.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PluginDataCompanion(')
          ..write('pluginId: $pluginId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PluginSettingsTable extends PluginSettings
    with TableInfo<$PluginSettingsTable, PluginSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PluginSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plugins (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($PluginSettingsTable.$convertervalue);
  @override
  List<GeneratedColumn> get $columns => [pluginId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plugin_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<PluginSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pluginIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginId, key};
  @override
  PluginSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PluginSetting(
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: $PluginSettingsTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
    );
  }

  @override
  $PluginSettingsTable createAlias(String alias) {
    return $PluginSettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalue = const JsonConverter();
}

class PluginSetting extends DataClass implements Insertable<PluginSetting> {
  final String pluginId;
  final String key;
  final Object? value;
  const PluginSetting({required this.pluginId, required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_id'] = Variable<String>(pluginId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(
        $PluginSettingsTable.$convertervalue.toSql(value),
      );
    }
    return map;
  }

  PluginSettingsCompanion toCompanion(bool nullToAbsent) {
    return PluginSettingsCompanion(
      pluginId: Value(pluginId),
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory PluginSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PluginSetting(
      pluginId: serializer.fromJson<String>(json['pluginId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Object?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginId': serializer.toJson<String>(pluginId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Object?>(value),
    };
  }

  PluginSetting copyWith({
    String? pluginId,
    String? key,
    Value<Object?> value = const Value.absent(),
  }) => PluginSetting(
    pluginId: pluginId ?? this.pluginId,
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  PluginSetting copyWithCompanion(PluginSettingsCompanion data) {
    return PluginSetting(
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PluginSetting(')
          ..write('pluginId: $pluginId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pluginId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PluginSetting &&
          other.pluginId == this.pluginId &&
          other.key == this.key &&
          other.value == this.value);
}

class PluginSettingsCompanion extends UpdateCompanion<PluginSetting> {
  final Value<String> pluginId;
  final Value<String> key;
  final Value<Object?> value;
  final Value<int> rowid;
  const PluginSettingsCompanion({
    this.pluginId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PluginSettingsCompanion.insert({
    required String pluginId,
    required String key,
    required Object? value,
    this.rowid = const Value.absent(),
  }) : pluginId = Value(pluginId),
       key = Value(key),
       value = Value(value);
  static Insertable<PluginSetting> custom({
    Expression<String>? pluginId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginId != null) 'plugin_id': pluginId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PluginSettingsCompanion copyWith({
    Value<String>? pluginId,
    Value<String>? key,
    Value<Object?>? value,
    Value<int>? rowid,
  }) {
    return PluginSettingsCompanion(
      pluginId: pluginId ?? this.pluginId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $PluginSettingsTable.$convertervalue.toSql(value.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PluginSettingsCompanion(')
          ..write('pluginId: $pluginId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PolicyCacheTable extends PolicyCache
    with TableInfo<$PolicyCacheTable, PolicyCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PolicyCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plugins (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> values =
      GeneratedColumn<String>(
        'values',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($PolicyCacheTable.$convertervalues);
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pluginId, values, fetchedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'policy_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<PolicyCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pluginIdMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginId};
  @override
  PolicyCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PolicyCacheData(
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      )!,
      values: $PolicyCacheTable.$convertervalues.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}values'],
        )!,
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  $PolicyCacheTable createAlias(String alias) {
    return $PolicyCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalues =
      const JsonConverter();
}

class PolicyCacheData extends DataClass implements Insertable<PolicyCacheData> {
  final String pluginId;
  final Object? values;
  final DateTime fetchedAt;
  const PolicyCacheData({
    required this.pluginId,
    this.values,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_id'] = Variable<String>(pluginId);
    if (!nullToAbsent || values != null) {
      map['values'] = Variable<String>(
        $PolicyCacheTable.$convertervalues.toSql(values),
      );
    }
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    return map;
  }

  PolicyCacheCompanion toCompanion(bool nullToAbsent) {
    return PolicyCacheCompanion(
      pluginId: Value(pluginId),
      values: values == null && nullToAbsent
          ? const Value.absent()
          : Value(values),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory PolicyCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PolicyCacheData(
      pluginId: serializer.fromJson<String>(json['pluginId']),
      values: serializer.fromJson<Object?>(json['values']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginId': serializer.toJson<String>(pluginId),
      'values': serializer.toJson<Object?>(values),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  PolicyCacheData copyWith({
    String? pluginId,
    Value<Object?> values = const Value.absent(),
    DateTime? fetchedAt,
  }) => PolicyCacheData(
    pluginId: pluginId ?? this.pluginId,
    values: values.present ? values.value : this.values,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  PolicyCacheData copyWithCompanion(PolicyCacheCompanion data) {
    return PolicyCacheData(
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      values: data.values.present ? data.values.value : this.values,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PolicyCacheData(')
          ..write('pluginId: $pluginId, ')
          ..write('values: $values, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pluginId, values, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PolicyCacheData &&
          other.pluginId == this.pluginId &&
          other.values == this.values &&
          other.fetchedAt == this.fetchedAt);
}

class PolicyCacheCompanion extends UpdateCompanion<PolicyCacheData> {
  final Value<String> pluginId;
  final Value<Object?> values;
  final Value<DateTime> fetchedAt;
  final Value<int> rowid;
  const PolicyCacheCompanion({
    this.pluginId = const Value.absent(),
    this.values = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PolicyCacheCompanion.insert({
    required String pluginId,
    required Object? values,
    required DateTime fetchedAt,
    this.rowid = const Value.absent(),
  }) : pluginId = Value(pluginId),
       values = Value(values),
       fetchedAt = Value(fetchedAt);
  static Insertable<PolicyCacheData> custom({
    Expression<String>? pluginId,
    Expression<String>? values,
    Expression<DateTime>? fetchedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginId != null) 'plugin_id': pluginId,
      if (values != null) 'values': values,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PolicyCacheCompanion copyWith({
    Value<String>? pluginId,
    Value<Object?>? values,
    Value<DateTime>? fetchedAt,
    Value<int>? rowid,
  }) {
    return PolicyCacheCompanion(
      pluginId: pluginId ?? this.pluginId,
      values: values ?? this.values,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (values.present) {
      map['values'] = Variable<String>(
        $PolicyCacheTable.$convertervalues.toSql(values.value),
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PolicyCacheCompanion(')
          ..write('pluginId: $pluginId, ')
          ..write('values: $values, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ButtonPositionsTable extends ButtonPositions
    with TableInfo<$ButtonPositionsTable, ButtonPosition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ButtonPositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plugins (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _buttonIndexMeta = const VerificationMeta(
    'buttonIndex',
  );
  @override
  late final GeneratedColumn<int> buttonIndex = GeneratedColumn<int>(
    'button_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leftMeta = const VerificationMeta('left');
  @override
  late final GeneratedColumn<String> left = GeneratedColumn<String>(
    'left',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topMeta = const VerificationMeta('top');
  @override
  late final GeneratedColumn<String> top = GeneratedColumn<String>(
    'top',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pluginId, buttonIndex, left, top];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'button_positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ButtonPosition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pluginIdMeta);
    }
    if (data.containsKey('button_index')) {
      context.handle(
        _buttonIndexMeta,
        buttonIndex.isAcceptableOrUnknown(
          data['button_index']!,
          _buttonIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_buttonIndexMeta);
    }
    if (data.containsKey('left')) {
      context.handle(
        _leftMeta,
        left.isAcceptableOrUnknown(data['left']!, _leftMeta),
      );
    } else if (isInserting) {
      context.missing(_leftMeta);
    }
    if (data.containsKey('top')) {
      context.handle(
        _topMeta,
        top.isAcceptableOrUnknown(data['top']!, _topMeta),
      );
    } else if (isInserting) {
      context.missing(_topMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginId, buttonIndex};
  @override
  ButtonPosition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ButtonPosition(
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      )!,
      buttonIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}button_index'],
      )!,
      left: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}left'],
      )!,
      top: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}top'],
      )!,
    );
  }

  @override
  $ButtonPositionsTable createAlias(String alias) {
    return $ButtonPositionsTable(attachedDatabase, alias);
  }
}

class ButtonPosition extends DataClass implements Insertable<ButtonPosition> {
  final String pluginId;
  final int buttonIndex;
  final String left;
  final String top;
  const ButtonPosition({
    required this.pluginId,
    required this.buttonIndex,
    required this.left,
    required this.top,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_id'] = Variable<String>(pluginId);
    map['button_index'] = Variable<int>(buttonIndex);
    map['left'] = Variable<String>(left);
    map['top'] = Variable<String>(top);
    return map;
  }

  ButtonPositionsCompanion toCompanion(bool nullToAbsent) {
    return ButtonPositionsCompanion(
      pluginId: Value(pluginId),
      buttonIndex: Value(buttonIndex),
      left: Value(left),
      top: Value(top),
    );
  }

  factory ButtonPosition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ButtonPosition(
      pluginId: serializer.fromJson<String>(json['pluginId']),
      buttonIndex: serializer.fromJson<int>(json['buttonIndex']),
      left: serializer.fromJson<String>(json['left']),
      top: serializer.fromJson<String>(json['top']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginId': serializer.toJson<String>(pluginId),
      'buttonIndex': serializer.toJson<int>(buttonIndex),
      'left': serializer.toJson<String>(left),
      'top': serializer.toJson<String>(top),
    };
  }

  ButtonPosition copyWith({
    String? pluginId,
    int? buttonIndex,
    String? left,
    String? top,
  }) => ButtonPosition(
    pluginId: pluginId ?? this.pluginId,
    buttonIndex: buttonIndex ?? this.buttonIndex,
    left: left ?? this.left,
    top: top ?? this.top,
  );
  ButtonPosition copyWithCompanion(ButtonPositionsCompanion data) {
    return ButtonPosition(
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      buttonIndex: data.buttonIndex.present
          ? data.buttonIndex.value
          : this.buttonIndex,
      left: data.left.present ? data.left.value : this.left,
      top: data.top.present ? data.top.value : this.top,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ButtonPosition(')
          ..write('pluginId: $pluginId, ')
          ..write('buttonIndex: $buttonIndex, ')
          ..write('left: $left, ')
          ..write('top: $top')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pluginId, buttonIndex, left, top);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ButtonPosition &&
          other.pluginId == this.pluginId &&
          other.buttonIndex == this.buttonIndex &&
          other.left == this.left &&
          other.top == this.top);
}

class ButtonPositionsCompanion extends UpdateCompanion<ButtonPosition> {
  final Value<String> pluginId;
  final Value<int> buttonIndex;
  final Value<String> left;
  final Value<String> top;
  final Value<int> rowid;
  const ButtonPositionsCompanion({
    this.pluginId = const Value.absent(),
    this.buttonIndex = const Value.absent(),
    this.left = const Value.absent(),
    this.top = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ButtonPositionsCompanion.insert({
    required String pluginId,
    required int buttonIndex,
    required String left,
    required String top,
    this.rowid = const Value.absent(),
  }) : pluginId = Value(pluginId),
       buttonIndex = Value(buttonIndex),
       left = Value(left),
       top = Value(top);
  static Insertable<ButtonPosition> custom({
    Expression<String>? pluginId,
    Expression<int>? buttonIndex,
    Expression<String>? left,
    Expression<String>? top,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginId != null) 'plugin_id': pluginId,
      if (buttonIndex != null) 'button_index': buttonIndex,
      if (left != null) 'left': left,
      if (top != null) 'top': top,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ButtonPositionsCompanion copyWith({
    Value<String>? pluginId,
    Value<int>? buttonIndex,
    Value<String>? left,
    Value<String>? top,
    Value<int>? rowid,
  }) {
    return ButtonPositionsCompanion(
      pluginId: pluginId ?? this.pluginId,
      buttonIndex: buttonIndex ?? this.buttonIndex,
      left: left ?? this.left,
      top: top ?? this.top,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (buttonIndex.present) {
      map['button_index'] = Variable<int>(buttonIndex.value);
    }
    if (left.present) {
      map['left'] = Variable<String>(left.value);
    }
    if (top.present) {
      map['top'] = Variable<String>(top.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ButtonPositionsCompanion(')
          ..write('pluginId: $pluginId, ')
          ..write('buttonIndex: $buttonIndex, ')
          ..write('left: $left, ')
          ..write('top: $top, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkerStateTable extends WorkerState
    with TableInfo<$WorkerStateTable, WorkerStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkerStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plugins (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lastStartedAtMeta = const VerificationMeta(
    'lastStartedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastStartedAt =
      GeneratedColumn<DateTime>(
        'last_started_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _restartCountMeta = const VerificationMeta(
    'restartCount',
  );
  @override
  late final GeneratedColumn<int> restartCount = GeneratedColumn<int>(
    'restart_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _suspendedAtMeta = const VerificationMeta(
    'suspendedAt',
  );
  @override
  late final GeneratedColumn<DateTime> suspendedAt = GeneratedColumn<DateTime>(
    'suspended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    pluginId,
    lastStartedAt,
    lastError,
    restartCount,
    suspendedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'worker_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkerStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pluginIdMeta);
    }
    if (data.containsKey('last_started_at')) {
      context.handle(
        _lastStartedAtMeta,
        lastStartedAt.isAcceptableOrUnknown(
          data['last_started_at']!,
          _lastStartedAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('restart_count')) {
      context.handle(
        _restartCountMeta,
        restartCount.isAcceptableOrUnknown(
          data['restart_count']!,
          _restartCountMeta,
        ),
      );
    }
    if (data.containsKey('suspended_at')) {
      context.handle(
        _suspendedAtMeta,
        suspendedAt.isAcceptableOrUnknown(
          data['suspended_at']!,
          _suspendedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pluginId};
  @override
  WorkerStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkerStateData(
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      )!,
      lastStartedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_started_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      restartCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}restart_count'],
      )!,
      suspendedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}suspended_at'],
      ),
    );
  }

  @override
  $WorkerStateTable createAlias(String alias) {
    return $WorkerStateTable(attachedDatabase, alias);
  }
}

class WorkerStateData extends DataClass implements Insertable<WorkerStateData> {
  final String pluginId;
  final DateTime? lastStartedAt;
  final String? lastError;
  final int restartCount;
  final DateTime? suspendedAt;
  const WorkerStateData({
    required this.pluginId,
    this.lastStartedAt,
    this.lastError,
    required this.restartCount,
    this.suspendedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['plugin_id'] = Variable<String>(pluginId);
    if (!nullToAbsent || lastStartedAt != null) {
      map['last_started_at'] = Variable<DateTime>(lastStartedAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['restart_count'] = Variable<int>(restartCount);
    if (!nullToAbsent || suspendedAt != null) {
      map['suspended_at'] = Variable<DateTime>(suspendedAt);
    }
    return map;
  }

  WorkerStateCompanion toCompanion(bool nullToAbsent) {
    return WorkerStateCompanion(
      pluginId: Value(pluginId),
      lastStartedAt: lastStartedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStartedAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      restartCount: Value(restartCount),
      suspendedAt: suspendedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(suspendedAt),
    );
  }

  factory WorkerStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkerStateData(
      pluginId: serializer.fromJson<String>(json['pluginId']),
      lastStartedAt: serializer.fromJson<DateTime?>(json['lastStartedAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      restartCount: serializer.fromJson<int>(json['restartCount']),
      suspendedAt: serializer.fromJson<DateTime?>(json['suspendedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pluginId': serializer.toJson<String>(pluginId),
      'lastStartedAt': serializer.toJson<DateTime?>(lastStartedAt),
      'lastError': serializer.toJson<String?>(lastError),
      'restartCount': serializer.toJson<int>(restartCount),
      'suspendedAt': serializer.toJson<DateTime?>(suspendedAt),
    };
  }

  WorkerStateData copyWith({
    String? pluginId,
    Value<DateTime?> lastStartedAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    int? restartCount,
    Value<DateTime?> suspendedAt = const Value.absent(),
  }) => WorkerStateData(
    pluginId: pluginId ?? this.pluginId,
    lastStartedAt: lastStartedAt.present
        ? lastStartedAt.value
        : this.lastStartedAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    restartCount: restartCount ?? this.restartCount,
    suspendedAt: suspendedAt.present ? suspendedAt.value : this.suspendedAt,
  );
  WorkerStateData copyWithCompanion(WorkerStateCompanion data) {
    return WorkerStateData(
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      lastStartedAt: data.lastStartedAt.present
          ? data.lastStartedAt.value
          : this.lastStartedAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      restartCount: data.restartCount.present
          ? data.restartCount.value
          : this.restartCount,
      suspendedAt: data.suspendedAt.present
          ? data.suspendedAt.value
          : this.suspendedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkerStateData(')
          ..write('pluginId: $pluginId, ')
          ..write('lastStartedAt: $lastStartedAt, ')
          ..write('lastError: $lastError, ')
          ..write('restartCount: $restartCount, ')
          ..write('suspendedAt: $suspendedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    pluginId,
    lastStartedAt,
    lastError,
    restartCount,
    suspendedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkerStateData &&
          other.pluginId == this.pluginId &&
          other.lastStartedAt == this.lastStartedAt &&
          other.lastError == this.lastError &&
          other.restartCount == this.restartCount &&
          other.suspendedAt == this.suspendedAt);
}

class WorkerStateCompanion extends UpdateCompanion<WorkerStateData> {
  final Value<String> pluginId;
  final Value<DateTime?> lastStartedAt;
  final Value<String?> lastError;
  final Value<int> restartCount;
  final Value<DateTime?> suspendedAt;
  final Value<int> rowid;
  const WorkerStateCompanion({
    this.pluginId = const Value.absent(),
    this.lastStartedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.restartCount = const Value.absent(),
    this.suspendedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkerStateCompanion.insert({
    required String pluginId,
    this.lastStartedAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.restartCount = const Value.absent(),
    this.suspendedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pluginId = Value(pluginId);
  static Insertable<WorkerStateData> custom({
    Expression<String>? pluginId,
    Expression<DateTime>? lastStartedAt,
    Expression<String>? lastError,
    Expression<int>? restartCount,
    Expression<DateTime>? suspendedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pluginId != null) 'plugin_id': pluginId,
      if (lastStartedAt != null) 'last_started_at': lastStartedAt,
      if (lastError != null) 'last_error': lastError,
      if (restartCount != null) 'restart_count': restartCount,
      if (suspendedAt != null) 'suspended_at': suspendedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkerStateCompanion copyWith({
    Value<String>? pluginId,
    Value<DateTime?>? lastStartedAt,
    Value<String?>? lastError,
    Value<int>? restartCount,
    Value<DateTime?>? suspendedAt,
    Value<int>? rowid,
  }) {
    return WorkerStateCompanion(
      pluginId: pluginId ?? this.pluginId,
      lastStartedAt: lastStartedAt ?? this.lastStartedAt,
      lastError: lastError ?? this.lastError,
      restartCount: restartCount ?? this.restartCount,
      suspendedAt: suspendedAt ?? this.suspendedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (lastStartedAt.present) {
      map['last_started_at'] = Variable<DateTime>(lastStartedAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (restartCount.present) {
      map['restart_count'] = Variable<int>(restartCount.value);
    }
    if (suspendedAt.present) {
      map['suspended_at'] = Variable<DateTime>(suspendedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkerStateCompanion(')
          ..write('pluginId: $pluginId, ')
          ..write('lastStartedAt: $lastStartedAt, ')
          ..write('lastError: $lastError, ')
          ..write('restartCount: $restartCount, ')
          ..write('suspendedAt: $suspendedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HostSettingsTableTable extends HostSettingsTable
    with TableInfo<$HostSettingsTableTable, HostSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HostSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($HostSettingsTableTable.$convertervalue);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'host_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<HostSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  HostSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HostSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: $HostSettingsTableTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
    );
  }

  @override
  $HostSettingsTableTable createAlias(String alias) {
    return $HostSettingsTableTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalue = const JsonConverter();
}

class HostSettingRow extends DataClass implements Insertable<HostSettingRow> {
  final String key;
  final Object? value;
  const HostSettingRow({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(
        $HostSettingsTableTable.$convertervalue.toSql(value),
      );
    }
    return map;
  }

  HostSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return HostSettingsTableCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory HostSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HostSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Object?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Object?>(value),
    };
  }

  HostSettingRow copyWith({
    String? key,
    Value<Object?> value = const Value.absent(),
  }) => HostSettingRow(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  HostSettingRow copyWithCompanion(HostSettingsTableCompanion data) {
    return HostSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HostSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HostSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class HostSettingsTableCompanion extends UpdateCompanion<HostSettingRow> {
  final Value<String> key;
  final Value<Object?> value;
  final Value<int> rowid;
  const HostSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HostSettingsTableCompanion.insert({
    required String key,
    required Object? value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<HostSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HostSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<Object?>? value,
    Value<int>? rowid,
  }) {
    return HostSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $HostSettingsTableTable.$convertervalue.toSql(value.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HostSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LogsTable extends Logs with TableInfo<$LogsTable, Log> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pluginIdMeta = const VerificationMeta(
    'pluginId',
  );
  @override
  late final GeneratedColumn<String> pluginId = GeneratedColumn<String>(
    'plugin_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('log'),
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pluginId,
    level,
    message,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Log> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plugin_id')) {
      context.handle(
        _pluginIdMeta,
        pluginId.isAcceptableOrUnknown(data['plugin_id']!, _pluginIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Log map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Log(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pluginId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plugin_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LogsTable createAlias(String alias) {
    return $LogsTable(attachedDatabase, alias);
  }
}

class Log extends DataClass implements Insertable<Log> {
  final int id;
  final String? pluginId;
  final String level;
  final String message;
  final DateTime createdAt;
  const Log({
    required this.id,
    this.pluginId,
    required this.level,
    required this.message,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || pluginId != null) {
      map['plugin_id'] = Variable<String>(pluginId);
    }
    map['level'] = Variable<String>(level);
    map['message'] = Variable<String>(message);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LogsCompanion toCompanion(bool nullToAbsent) {
    return LogsCompanion(
      id: Value(id),
      pluginId: pluginId == null && nullToAbsent
          ? const Value.absent()
          : Value(pluginId),
      level: Value(level),
      message: Value(message),
      createdAt: Value(createdAt),
    );
  }

  factory Log.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Log(
      id: serializer.fromJson<int>(json['id']),
      pluginId: serializer.fromJson<String?>(json['pluginId']),
      level: serializer.fromJson<String>(json['level']),
      message: serializer.fromJson<String>(json['message']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pluginId': serializer.toJson<String?>(pluginId),
      'level': serializer.toJson<String>(level),
      'message': serializer.toJson<String>(message),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Log copyWith({
    int? id,
    Value<String?> pluginId = const Value.absent(),
    String? level,
    String? message,
    DateTime? createdAt,
  }) => Log(
    id: id ?? this.id,
    pluginId: pluginId.present ? pluginId.value : this.pluginId,
    level: level ?? this.level,
    message: message ?? this.message,
    createdAt: createdAt ?? this.createdAt,
  );
  Log copyWithCompanion(LogsCompanion data) {
    return Log(
      id: data.id.present ? data.id.value : this.id,
      pluginId: data.pluginId.present ? data.pluginId.value : this.pluginId,
      level: data.level.present ? data.level.value : this.level,
      message: data.message.present ? data.message.value : this.message,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Log(')
          ..write('id: $id, ')
          ..write('pluginId: $pluginId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pluginId, level, message, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Log &&
          other.id == this.id &&
          other.pluginId == this.pluginId &&
          other.level == this.level &&
          other.message == this.message &&
          other.createdAt == this.createdAt);
}

class LogsCompanion extends UpdateCompanion<Log> {
  final Value<int> id;
  final Value<String?> pluginId;
  final Value<String> level;
  final Value<String> message;
  final Value<DateTime> createdAt;
  const LogsCompanion({
    this.id = const Value.absent(),
    this.pluginId = const Value.absent(),
    this.level = const Value.absent(),
    this.message = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LogsCompanion.insert({
    this.id = const Value.absent(),
    this.pluginId = const Value.absent(),
    this.level = const Value.absent(),
    required String message,
    required DateTime createdAt,
  }) : message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<Log> custom({
    Expression<int>? id,
    Expression<String>? pluginId,
    Expression<String>? level,
    Expression<String>? message,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pluginId != null) 'plugin_id': pluginId,
      if (level != null) 'level': level,
      if (message != null) 'message': message,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LogsCompanion copyWith({
    Value<int>? id,
    Value<String?>? pluginId,
    Value<String>? level,
    Value<String>? message,
    Value<DateTime>? createdAt,
  }) {
    return LogsCompanion(
      id: id ?? this.id,
      pluginId: pluginId ?? this.pluginId,
      level: level ?? this.level,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pluginId.present) {
      map['plugin_id'] = Variable<String>(pluginId.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LogsCompanion(')
          ..write('id: $id, ')
          ..write('pluginId: $pluginId, ')
          ..write('level: $level, ')
          ..write('message: $message, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PluginsTable plugins = $PluginsTable(this);
  late final $PluginFilesTable pluginFiles = $PluginFilesTable(this);
  late final $PluginDataTable pluginData = $PluginDataTable(this);
  late final $PluginSettingsTable pluginSettings = $PluginSettingsTable(this);
  late final $PolicyCacheTable policyCache = $PolicyCacheTable(this);
  late final $ButtonPositionsTable buttonPositions = $ButtonPositionsTable(
    this,
  );
  late final $WorkerStateTable workerState = $WorkerStateTable(this);
  late final $HostSettingsTableTable hostSettingsTable =
      $HostSettingsTableTable(this);
  late final $LogsTable logs = $LogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    plugins,
    pluginFiles,
    pluginData,
    pluginSettings,
    policyCache,
    buttonPositions,
    workerState,
    hostSettingsTable,
    logs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plugins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plugin_files', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plugins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plugin_data', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plugins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('plugin_settings', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plugins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('policy_cache', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plugins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('button_positions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'plugins',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('worker_state', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PluginsTableCreateCompanionBuilder =
    PluginsCompanion Function({
      required String id,
      required String name,
      required String version,
      required Object? manifest,
      Value<bool> enabled,
      required DateTime installedAt,
      required DateTime updatedAt,
      Value<String?> latestVersion,
      Value<DateTime?> latestCheckedAt,
      Value<int> rowid,
    });
typedef $$PluginsTableUpdateCompanionBuilder =
    PluginsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> version,
      Value<Object?> manifest,
      Value<bool> enabled,
      Value<DateTime> installedAt,
      Value<DateTime> updatedAt,
      Value<String?> latestVersion,
      Value<DateTime?> latestCheckedAt,
      Value<int> rowid,
    });

final class $$PluginsTableReferences
    extends BaseReferences<_$AppDatabase, $PluginsTable, Plugin> {
  $$PluginsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PluginFilesTable, List<PluginFile>>
  _pluginFilesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pluginFiles,
    aliasName: 'plugins__id__plugin_files__plugin_id',
  );

  $$PluginFilesTableProcessedTableManager get pluginFilesRefs {
    final manager = $$PluginFilesTableTableManager(
      $_db,
      $_db.pluginFiles,
    ).filter((f) => f.pluginId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pluginFilesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PluginDataTable, List<PluginDataData>>
  _pluginDataRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pluginData,
    aliasName: 'plugins__id__plugin_data__plugin_id',
  );

  $$PluginDataTableProcessedTableManager get pluginDataRefs {
    final manager = $$PluginDataTableTableManager(
      $_db,
      $_db.pluginData,
    ).filter((f) => f.pluginId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pluginDataRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PluginSettingsTable, List<PluginSetting>>
  _pluginSettingsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pluginSettings,
    aliasName: 'plugins__id__plugin_settings__plugin_id',
  );

  $$PluginSettingsTableProcessedTableManager get pluginSettingsRefs {
    final manager = $$PluginSettingsTableTableManager(
      $_db,
      $_db.pluginSettings,
    ).filter((f) => f.pluginId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pluginSettingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PolicyCacheTable, List<PolicyCacheData>>
  _policyCacheRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.policyCache,
    aliasName: 'plugins__id__policy_cache__plugin_id',
  );

  $$PolicyCacheTableProcessedTableManager get policyCacheRefs {
    final manager = $$PolicyCacheTableTableManager(
      $_db,
      $_db.policyCache,
    ).filter((f) => f.pluginId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_policyCacheRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ButtonPositionsTable, List<ButtonPosition>>
  _buttonPositionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.buttonPositions,
    aliasName: 'plugins__id__button_positions__plugin_id',
  );

  $$ButtonPositionsTableProcessedTableManager get buttonPositionsRefs {
    final manager = $$ButtonPositionsTableTableManager(
      $_db,
      $_db.buttonPositions,
    ).filter((f) => f.pluginId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _buttonPositionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkerStateTable, List<WorkerStateData>>
  _workerStateRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workerState,
    aliasName: 'plugins__id__worker_state__plugin_id',
  );

  $$WorkerStateTableProcessedTableManager get workerStateRefs {
    final manager = $$WorkerStateTableTableManager(
      $_db,
      $_db.workerState,
    ).filter((f) => f.pluginId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workerStateRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PluginsTableFilterComposer
    extends Composer<_$AppDatabase, $PluginsTable> {
  $$PluginsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get manifest =>
      $composableBuilder(
        column: $table.manifest,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latestVersion => $composableBuilder(
    column: $table.latestVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get latestCheckedAt => $composableBuilder(
    column: $table.latestCheckedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> pluginFilesRefs(
    Expression<bool> Function($$PluginFilesTableFilterComposer f) f,
  ) {
    final $$PluginFilesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pluginFiles,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginFilesTableFilterComposer(
            $db: $db,
            $table: $db.pluginFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pluginDataRefs(
    Expression<bool> Function($$PluginDataTableFilterComposer f) f,
  ) {
    final $$PluginDataTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pluginData,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginDataTableFilterComposer(
            $db: $db,
            $table: $db.pluginData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pluginSettingsRefs(
    Expression<bool> Function($$PluginSettingsTableFilterComposer f) f,
  ) {
    final $$PluginSettingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pluginSettings,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginSettingsTableFilterComposer(
            $db: $db,
            $table: $db.pluginSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> policyCacheRefs(
    Expression<bool> Function($$PolicyCacheTableFilterComposer f) f,
  ) {
    final $$PolicyCacheTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.policyCache,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PolicyCacheTableFilterComposer(
            $db: $db,
            $table: $db.policyCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> buttonPositionsRefs(
    Expression<bool> Function($$ButtonPositionsTableFilterComposer f) f,
  ) {
    final $$ButtonPositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttonPositions,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonPositionsTableFilterComposer(
            $db: $db,
            $table: $db.buttonPositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workerStateRefs(
    Expression<bool> Function($$WorkerStateTableFilterComposer f) f,
  ) {
    final $$WorkerStateTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workerState,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkerStateTableFilterComposer(
            $db: $db,
            $table: $db.workerState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PluginsTableOrderingComposer
    extends Composer<_$AppDatabase, $PluginsTable> {
  $$PluginsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get manifest => $composableBuilder(
    column: $table.manifest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latestVersion => $composableBuilder(
    column: $table.latestVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get latestCheckedAt => $composableBuilder(
    column: $table.latestCheckedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PluginsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PluginsTable> {
  $$PluginsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get manifest =>
      $composableBuilder(column: $table.manifest, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get latestVersion => $composableBuilder(
    column: $table.latestVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get latestCheckedAt => $composableBuilder(
    column: $table.latestCheckedAt,
    builder: (column) => column,
  );

  Expression<T> pluginFilesRefs<T extends Object>(
    Expression<T> Function($$PluginFilesTableAnnotationComposer a) f,
  ) {
    final $$PluginFilesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pluginFiles,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginFilesTableAnnotationComposer(
            $db: $db,
            $table: $db.pluginFiles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pluginDataRefs<T extends Object>(
    Expression<T> Function($$PluginDataTableAnnotationComposer a) f,
  ) {
    final $$PluginDataTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pluginData,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginDataTableAnnotationComposer(
            $db: $db,
            $table: $db.pluginData,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pluginSettingsRefs<T extends Object>(
    Expression<T> Function($$PluginSettingsTableAnnotationComposer a) f,
  ) {
    final $$PluginSettingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pluginSettings,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginSettingsTableAnnotationComposer(
            $db: $db,
            $table: $db.pluginSettings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> policyCacheRefs<T extends Object>(
    Expression<T> Function($$PolicyCacheTableAnnotationComposer a) f,
  ) {
    final $$PolicyCacheTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.policyCache,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PolicyCacheTableAnnotationComposer(
            $db: $db,
            $table: $db.policyCache,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> buttonPositionsRefs<T extends Object>(
    Expression<T> Function($$ButtonPositionsTableAnnotationComposer a) f,
  ) {
    final $$ButtonPositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.buttonPositions,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ButtonPositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.buttonPositions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workerStateRefs<T extends Object>(
    Expression<T> Function($$WorkerStateTableAnnotationComposer a) f,
  ) {
    final $$WorkerStateTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workerState,
      getReferencedColumn: (t) => t.pluginId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkerStateTableAnnotationComposer(
            $db: $db,
            $table: $db.workerState,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PluginsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PluginsTable,
          Plugin,
          $$PluginsTableFilterComposer,
          $$PluginsTableOrderingComposer,
          $$PluginsTableAnnotationComposer,
          $$PluginsTableCreateCompanionBuilder,
          $$PluginsTableUpdateCompanionBuilder,
          (Plugin, $$PluginsTableReferences),
          Plugin,
          PrefetchHooks Function({
            bool pluginFilesRefs,
            bool pluginDataRefs,
            bool pluginSettingsRefs,
            bool policyCacheRefs,
            bool buttonPositionsRefs,
            bool workerStateRefs,
          })
        > {
  $$PluginsTableTableManager(_$AppDatabase db, $PluginsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PluginsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PluginsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PluginsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<Object?> manifest = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> installedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String?> latestVersion = const Value.absent(),
                Value<DateTime?> latestCheckedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginsCompanion(
                id: id,
                name: name,
                version: version,
                manifest: manifest,
                enabled: enabled,
                installedAt: installedAt,
                updatedAt: updatedAt,
                latestVersion: latestVersion,
                latestCheckedAt: latestCheckedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String version,
                required Object? manifest,
                Value<bool> enabled = const Value.absent(),
                required DateTime installedAt,
                required DateTime updatedAt,
                Value<String?> latestVersion = const Value.absent(),
                Value<DateTime?> latestCheckedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginsCompanion.insert(
                id: id,
                name: name,
                version: version,
                manifest: manifest,
                enabled: enabled,
                installedAt: installedAt,
                updatedAt: updatedAt,
                latestVersion: latestVersion,
                latestCheckedAt: latestCheckedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PluginsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                pluginFilesRefs = false,
                pluginDataRefs = false,
                pluginSettingsRefs = false,
                policyCacheRefs = false,
                buttonPositionsRefs = false,
                workerStateRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (pluginFilesRefs) db.pluginFiles,
                    if (pluginDataRefs) db.pluginData,
                    if (pluginSettingsRefs) db.pluginSettings,
                    if (policyCacheRefs) db.policyCache,
                    if (buttonPositionsRefs) db.buttonPositions,
                    if (workerStateRefs) db.workerState,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (pluginFilesRefs)
                        await $_getPrefetchedData<
                          Plugin,
                          $PluginsTable,
                          PluginFile
                        >(
                          currentTable: table,
                          referencedTable: $$PluginsTableReferences
                              ._pluginFilesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PluginsTableReferences(
                                db,
                                table,
                                p0,
                              ).pluginFilesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pluginId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pluginDataRefs)
                        await $_getPrefetchedData<
                          Plugin,
                          $PluginsTable,
                          PluginDataData
                        >(
                          currentTable: table,
                          referencedTable: $$PluginsTableReferences
                              ._pluginDataRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PluginsTableReferences(
                                db,
                                table,
                                p0,
                              ).pluginDataRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pluginId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pluginSettingsRefs)
                        await $_getPrefetchedData<
                          Plugin,
                          $PluginsTable,
                          PluginSetting
                        >(
                          currentTable: table,
                          referencedTable: $$PluginsTableReferences
                              ._pluginSettingsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PluginsTableReferences(
                                db,
                                table,
                                p0,
                              ).pluginSettingsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pluginId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (policyCacheRefs)
                        await $_getPrefetchedData<
                          Plugin,
                          $PluginsTable,
                          PolicyCacheData
                        >(
                          currentTable: table,
                          referencedTable: $$PluginsTableReferences
                              ._policyCacheRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PluginsTableReferences(
                                db,
                                table,
                                p0,
                              ).policyCacheRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pluginId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (buttonPositionsRefs)
                        await $_getPrefetchedData<
                          Plugin,
                          $PluginsTable,
                          ButtonPosition
                        >(
                          currentTable: table,
                          referencedTable: $$PluginsTableReferences
                              ._buttonPositionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PluginsTableReferences(
                                db,
                                table,
                                p0,
                              ).buttonPositionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pluginId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workerStateRefs)
                        await $_getPrefetchedData<
                          Plugin,
                          $PluginsTable,
                          WorkerStateData
                        >(
                          currentTable: table,
                          referencedTable: $$PluginsTableReferences
                              ._workerStateRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PluginsTableReferences(
                                db,
                                table,
                                p0,
                              ).workerStateRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.pluginId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PluginsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PluginsTable,
      Plugin,
      $$PluginsTableFilterComposer,
      $$PluginsTableOrderingComposer,
      $$PluginsTableAnnotationComposer,
      $$PluginsTableCreateCompanionBuilder,
      $$PluginsTableUpdateCompanionBuilder,
      (Plugin, $$PluginsTableReferences),
      Plugin,
      PrefetchHooks Function({
        bool pluginFilesRefs,
        bool pluginDataRefs,
        bool pluginSettingsRefs,
        bool policyCacheRefs,
        bool buttonPositionsRefs,
        bool workerStateRefs,
      })
    >;
typedef $$PluginFilesTableCreateCompanionBuilder =
    PluginFilesCompanion Function({
      required String pluginId,
      required String path,
      required Uint8List content,
      Value<String> mime,
      Value<int> rowid,
    });
typedef $$PluginFilesTableUpdateCompanionBuilder =
    PluginFilesCompanion Function({
      Value<String> pluginId,
      Value<String> path,
      Value<Uint8List> content,
      Value<String> mime,
      Value<int> rowid,
    });

final class $$PluginFilesTableReferences
    extends BaseReferences<_$AppDatabase, $PluginFilesTable, PluginFile> {
  $$PluginFilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PluginsTable _pluginIdTable(_$AppDatabase db) =>
      db.plugins.createAlias('plugin_files__plugin_id__plugins__id');

  $$PluginsTableProcessedTableManager get pluginId {
    final $_column = $_itemColumn<String>('plugin_id')!;

    final manager = $$PluginsTableTableManager(
      $_db,
      $_db.plugins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pluginIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PluginFilesTableFilterComposer
    extends Composer<_$AppDatabase, $PluginFilesTable> {
  $$PluginFilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  $$PluginsTableFilterComposer get pluginId {
    final $$PluginsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableFilterComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginFilesTableOrderingComposer
    extends Composer<_$AppDatabase, $PluginFilesTable> {
  $$PluginFilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  $$PluginsTableOrderingComposer get pluginId {
    final $$PluginsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableOrderingComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginFilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PluginFilesTable> {
  $$PluginFilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<Uint8List> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  $$PluginsTableAnnotationComposer get pluginId {
    final $$PluginsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableAnnotationComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginFilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PluginFilesTable,
          PluginFile,
          $$PluginFilesTableFilterComposer,
          $$PluginFilesTableOrderingComposer,
          $$PluginFilesTableAnnotationComposer,
          $$PluginFilesTableCreateCompanionBuilder,
          $$PluginFilesTableUpdateCompanionBuilder,
          (PluginFile, $$PluginFilesTableReferences),
          PluginFile,
          PrefetchHooks Function({bool pluginId})
        > {
  $$PluginFilesTableTableManager(_$AppDatabase db, $PluginFilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PluginFilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PluginFilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PluginFilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pluginId = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<Uint8List> content = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginFilesCompanion(
                pluginId: pluginId,
                path: path,
                content: content,
                mime: mime,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pluginId,
                required String path,
                required Uint8List content,
                Value<String> mime = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginFilesCompanion.insert(
                pluginId: pluginId,
                path: path,
                content: content,
                mime: mime,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PluginFilesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pluginId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pluginId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pluginId,
                                referencedTable: $$PluginFilesTableReferences
                                    ._pluginIdTable(db),
                                referencedColumn: $$PluginFilesTableReferences
                                    ._pluginIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PluginFilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PluginFilesTable,
      PluginFile,
      $$PluginFilesTableFilterComposer,
      $$PluginFilesTableOrderingComposer,
      $$PluginFilesTableAnnotationComposer,
      $$PluginFilesTableCreateCompanionBuilder,
      $$PluginFilesTableUpdateCompanionBuilder,
      (PluginFile, $$PluginFilesTableReferences),
      PluginFile,
      PrefetchHooks Function({bool pluginId})
    >;
typedef $$PluginDataTableCreateCompanionBuilder =
    PluginDataCompanion Function({
      required String pluginId,
      required String key,
      required Object? value,
      Value<int> rowid,
    });
typedef $$PluginDataTableUpdateCompanionBuilder =
    PluginDataCompanion Function({
      Value<String> pluginId,
      Value<String> key,
      Value<Object?> value,
      Value<int> rowid,
    });

final class $$PluginDataTableReferences
    extends BaseReferences<_$AppDatabase, $PluginDataTable, PluginDataData> {
  $$PluginDataTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PluginsTable _pluginIdTable(_$AppDatabase db) =>
      db.plugins.createAlias('plugin_data__plugin_id__plugins__id');

  $$PluginsTableProcessedTableManager get pluginId {
    final $_column = $_itemColumn<String>('plugin_id')!;

    final manager = $$PluginsTableTableManager(
      $_db,
      $_db.plugins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pluginIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PluginDataTableFilterComposer
    extends Composer<_$AppDatabase, $PluginDataTable> {
  $$PluginDataTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PluginsTableFilterComposer get pluginId {
    final $$PluginsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableFilterComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginDataTableOrderingComposer
    extends Composer<_$AppDatabase, $PluginDataTable> {
  $$PluginDataTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$PluginsTableOrderingComposer get pluginId {
    final $$PluginsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableOrderingComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginDataTableAnnotationComposer
    extends Composer<_$AppDatabase, $PluginDataTable> {
  $$PluginDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$PluginsTableAnnotationComposer get pluginId {
    final $$PluginsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableAnnotationComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginDataTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PluginDataTable,
          PluginDataData,
          $$PluginDataTableFilterComposer,
          $$PluginDataTableOrderingComposer,
          $$PluginDataTableAnnotationComposer,
          $$PluginDataTableCreateCompanionBuilder,
          $$PluginDataTableUpdateCompanionBuilder,
          (PluginDataData, $$PluginDataTableReferences),
          PluginDataData,
          PrefetchHooks Function({bool pluginId})
        > {
  $$PluginDataTableTableManager(_$AppDatabase db, $PluginDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PluginDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PluginDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PluginDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pluginId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<Object?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginDataCompanion(
                pluginId: pluginId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pluginId,
                required String key,
                required Object? value,
                Value<int> rowid = const Value.absent(),
              }) => PluginDataCompanion.insert(
                pluginId: pluginId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PluginDataTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pluginId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pluginId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pluginId,
                                referencedTable: $$PluginDataTableReferences
                                    ._pluginIdTable(db),
                                referencedColumn: $$PluginDataTableReferences
                                    ._pluginIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PluginDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PluginDataTable,
      PluginDataData,
      $$PluginDataTableFilterComposer,
      $$PluginDataTableOrderingComposer,
      $$PluginDataTableAnnotationComposer,
      $$PluginDataTableCreateCompanionBuilder,
      $$PluginDataTableUpdateCompanionBuilder,
      (PluginDataData, $$PluginDataTableReferences),
      PluginDataData,
      PrefetchHooks Function({bool pluginId})
    >;
typedef $$PluginSettingsTableCreateCompanionBuilder =
    PluginSettingsCompanion Function({
      required String pluginId,
      required String key,
      required Object? value,
      Value<int> rowid,
    });
typedef $$PluginSettingsTableUpdateCompanionBuilder =
    PluginSettingsCompanion Function({
      Value<String> pluginId,
      Value<String> key,
      Value<Object?> value,
      Value<int> rowid,
    });

final class $$PluginSettingsTableReferences
    extends BaseReferences<_$AppDatabase, $PluginSettingsTable, PluginSetting> {
  $$PluginSettingsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PluginsTable _pluginIdTable(_$AppDatabase db) =>
      db.plugins.createAlias('plugin_settings__plugin_id__plugins__id');

  $$PluginsTableProcessedTableManager get pluginId {
    final $_column = $_itemColumn<String>('plugin_id')!;

    final manager = $$PluginsTableTableManager(
      $_db,
      $_db.plugins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pluginIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PluginSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $PluginSettingsTable> {
  $$PluginSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$PluginsTableFilterComposer get pluginId {
    final $$PluginsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableFilterComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PluginSettingsTable> {
  $$PluginSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  $$PluginsTableOrderingComposer get pluginId {
    final $$PluginsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableOrderingComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PluginSettingsTable> {
  $$PluginSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$PluginsTableAnnotationComposer get pluginId {
    final $$PluginsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableAnnotationComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PluginSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PluginSettingsTable,
          PluginSetting,
          $$PluginSettingsTableFilterComposer,
          $$PluginSettingsTableOrderingComposer,
          $$PluginSettingsTableAnnotationComposer,
          $$PluginSettingsTableCreateCompanionBuilder,
          $$PluginSettingsTableUpdateCompanionBuilder,
          (PluginSetting, $$PluginSettingsTableReferences),
          PluginSetting,
          PrefetchHooks Function({bool pluginId})
        > {
  $$PluginSettingsTableTableManager(
    _$AppDatabase db,
    $PluginSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PluginSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PluginSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PluginSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pluginId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<Object?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PluginSettingsCompanion(
                pluginId: pluginId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pluginId,
                required String key,
                required Object? value,
                Value<int> rowid = const Value.absent(),
              }) => PluginSettingsCompanion.insert(
                pluginId: pluginId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PluginSettingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pluginId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pluginId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pluginId,
                                referencedTable: $$PluginSettingsTableReferences
                                    ._pluginIdTable(db),
                                referencedColumn:
                                    $$PluginSettingsTableReferences
                                        ._pluginIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PluginSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PluginSettingsTable,
      PluginSetting,
      $$PluginSettingsTableFilterComposer,
      $$PluginSettingsTableOrderingComposer,
      $$PluginSettingsTableAnnotationComposer,
      $$PluginSettingsTableCreateCompanionBuilder,
      $$PluginSettingsTableUpdateCompanionBuilder,
      (PluginSetting, $$PluginSettingsTableReferences),
      PluginSetting,
      PrefetchHooks Function({bool pluginId})
    >;
typedef $$PolicyCacheTableCreateCompanionBuilder =
    PolicyCacheCompanion Function({
      required String pluginId,
      required Object? values,
      required DateTime fetchedAt,
      Value<int> rowid,
    });
typedef $$PolicyCacheTableUpdateCompanionBuilder =
    PolicyCacheCompanion Function({
      Value<String> pluginId,
      Value<Object?> values,
      Value<DateTime> fetchedAt,
      Value<int> rowid,
    });

final class $$PolicyCacheTableReferences
    extends BaseReferences<_$AppDatabase, $PolicyCacheTable, PolicyCacheData> {
  $$PolicyCacheTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PluginsTable _pluginIdTable(_$AppDatabase db) =>
      db.plugins.createAlias('policy_cache__plugin_id__plugins__id');

  $$PluginsTableProcessedTableManager get pluginId {
    final $_column = $_itemColumn<String>('plugin_id')!;

    final manager = $$PluginsTableTableManager(
      $_db,
      $_db.plugins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pluginIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PolicyCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PolicyCacheTable> {
  $$PolicyCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Object?, Object, String> get values =>
      $composableBuilder(
        column: $table.values,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PluginsTableFilterComposer get pluginId {
    final $$PluginsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableFilterComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PolicyCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PolicyCacheTable> {
  $$PolicyCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get values => $composableBuilder(
    column: $table.values,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PluginsTableOrderingComposer get pluginId {
    final $$PluginsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableOrderingComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PolicyCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PolicyCacheTable> {
  $$PolicyCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Object?, String> get values =>
      $composableBuilder(column: $table.values, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$PluginsTableAnnotationComposer get pluginId {
    final $$PluginsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableAnnotationComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PolicyCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PolicyCacheTable,
          PolicyCacheData,
          $$PolicyCacheTableFilterComposer,
          $$PolicyCacheTableOrderingComposer,
          $$PolicyCacheTableAnnotationComposer,
          $$PolicyCacheTableCreateCompanionBuilder,
          $$PolicyCacheTableUpdateCompanionBuilder,
          (PolicyCacheData, $$PolicyCacheTableReferences),
          PolicyCacheData,
          PrefetchHooks Function({bool pluginId})
        > {
  $$PolicyCacheTableTableManager(_$AppDatabase db, $PolicyCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PolicyCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PolicyCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PolicyCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pluginId = const Value.absent(),
                Value<Object?> values = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PolicyCacheCompanion(
                pluginId: pluginId,
                values: values,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pluginId,
                required Object? values,
                required DateTime fetchedAt,
                Value<int> rowid = const Value.absent(),
              }) => PolicyCacheCompanion.insert(
                pluginId: pluginId,
                values: values,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PolicyCacheTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pluginId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pluginId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pluginId,
                                referencedTable: $$PolicyCacheTableReferences
                                    ._pluginIdTable(db),
                                referencedColumn: $$PolicyCacheTableReferences
                                    ._pluginIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PolicyCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PolicyCacheTable,
      PolicyCacheData,
      $$PolicyCacheTableFilterComposer,
      $$PolicyCacheTableOrderingComposer,
      $$PolicyCacheTableAnnotationComposer,
      $$PolicyCacheTableCreateCompanionBuilder,
      $$PolicyCacheTableUpdateCompanionBuilder,
      (PolicyCacheData, $$PolicyCacheTableReferences),
      PolicyCacheData,
      PrefetchHooks Function({bool pluginId})
    >;
typedef $$ButtonPositionsTableCreateCompanionBuilder =
    ButtonPositionsCompanion Function({
      required String pluginId,
      required int buttonIndex,
      required String left,
      required String top,
      Value<int> rowid,
    });
typedef $$ButtonPositionsTableUpdateCompanionBuilder =
    ButtonPositionsCompanion Function({
      Value<String> pluginId,
      Value<int> buttonIndex,
      Value<String> left,
      Value<String> top,
      Value<int> rowid,
    });

final class $$ButtonPositionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $ButtonPositionsTable, ButtonPosition> {
  $$ButtonPositionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PluginsTable _pluginIdTable(_$AppDatabase db) =>
      db.plugins.createAlias('button_positions__plugin_id__plugins__id');

  $$PluginsTableProcessedTableManager get pluginId {
    final $_column = $_itemColumn<String>('plugin_id')!;

    final manager = $$PluginsTableTableManager(
      $_db,
      $_db.plugins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pluginIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ButtonPositionsTableFilterComposer
    extends Composer<_$AppDatabase, $ButtonPositionsTable> {
  $$ButtonPositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get buttonIndex => $composableBuilder(
    column: $table.buttonIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get left => $composableBuilder(
    column: $table.left,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get top => $composableBuilder(
    column: $table.top,
    builder: (column) => ColumnFilters(column),
  );

  $$PluginsTableFilterComposer get pluginId {
    final $$PluginsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableFilterComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ButtonPositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ButtonPositionsTable> {
  $$ButtonPositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get buttonIndex => $composableBuilder(
    column: $table.buttonIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get left => $composableBuilder(
    column: $table.left,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get top => $composableBuilder(
    column: $table.top,
    builder: (column) => ColumnOrderings(column),
  );

  $$PluginsTableOrderingComposer get pluginId {
    final $$PluginsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableOrderingComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ButtonPositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ButtonPositionsTable> {
  $$ButtonPositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get buttonIndex => $composableBuilder(
    column: $table.buttonIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get left =>
      $composableBuilder(column: $table.left, builder: (column) => column);

  GeneratedColumn<String> get top =>
      $composableBuilder(column: $table.top, builder: (column) => column);

  $$PluginsTableAnnotationComposer get pluginId {
    final $$PluginsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableAnnotationComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ButtonPositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ButtonPositionsTable,
          ButtonPosition,
          $$ButtonPositionsTableFilterComposer,
          $$ButtonPositionsTableOrderingComposer,
          $$ButtonPositionsTableAnnotationComposer,
          $$ButtonPositionsTableCreateCompanionBuilder,
          $$ButtonPositionsTableUpdateCompanionBuilder,
          (ButtonPosition, $$ButtonPositionsTableReferences),
          ButtonPosition,
          PrefetchHooks Function({bool pluginId})
        > {
  $$ButtonPositionsTableTableManager(
    _$AppDatabase db,
    $ButtonPositionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ButtonPositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ButtonPositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ButtonPositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pluginId = const Value.absent(),
                Value<int> buttonIndex = const Value.absent(),
                Value<String> left = const Value.absent(),
                Value<String> top = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ButtonPositionsCompanion(
                pluginId: pluginId,
                buttonIndex: buttonIndex,
                left: left,
                top: top,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pluginId,
                required int buttonIndex,
                required String left,
                required String top,
                Value<int> rowid = const Value.absent(),
              }) => ButtonPositionsCompanion.insert(
                pluginId: pluginId,
                buttonIndex: buttonIndex,
                left: left,
                top: top,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ButtonPositionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pluginId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pluginId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pluginId,
                                referencedTable:
                                    $$ButtonPositionsTableReferences
                                        ._pluginIdTable(db),
                                referencedColumn:
                                    $$ButtonPositionsTableReferences
                                        ._pluginIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ButtonPositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ButtonPositionsTable,
      ButtonPosition,
      $$ButtonPositionsTableFilterComposer,
      $$ButtonPositionsTableOrderingComposer,
      $$ButtonPositionsTableAnnotationComposer,
      $$ButtonPositionsTableCreateCompanionBuilder,
      $$ButtonPositionsTableUpdateCompanionBuilder,
      (ButtonPosition, $$ButtonPositionsTableReferences),
      ButtonPosition,
      PrefetchHooks Function({bool pluginId})
    >;
typedef $$WorkerStateTableCreateCompanionBuilder =
    WorkerStateCompanion Function({
      required String pluginId,
      Value<DateTime?> lastStartedAt,
      Value<String?> lastError,
      Value<int> restartCount,
      Value<DateTime?> suspendedAt,
      Value<int> rowid,
    });
typedef $$WorkerStateTableUpdateCompanionBuilder =
    WorkerStateCompanion Function({
      Value<String> pluginId,
      Value<DateTime?> lastStartedAt,
      Value<String?> lastError,
      Value<int> restartCount,
      Value<DateTime?> suspendedAt,
      Value<int> rowid,
    });

final class $$WorkerStateTableReferences
    extends BaseReferences<_$AppDatabase, $WorkerStateTable, WorkerStateData> {
  $$WorkerStateTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PluginsTable _pluginIdTable(_$AppDatabase db) =>
      db.plugins.createAlias('worker_state__plugin_id__plugins__id');

  $$PluginsTableProcessedTableManager get pluginId {
    final $_column = $_itemColumn<String>('plugin_id')!;

    final manager = $$PluginsTableTableManager(
      $_db,
      $_db.plugins,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pluginIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkerStateTableFilterComposer
    extends Composer<_$AppDatabase, $WorkerStateTable> {
  $$WorkerStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get lastStartedAt => $composableBuilder(
    column: $table.lastStartedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restartCount => $composableBuilder(
    column: $table.restartCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get suspendedAt => $composableBuilder(
    column: $table.suspendedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PluginsTableFilterComposer get pluginId {
    final $$PluginsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableFilterComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkerStateTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkerStateTable> {
  $$WorkerStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get lastStartedAt => $composableBuilder(
    column: $table.lastStartedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restartCount => $composableBuilder(
    column: $table.restartCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get suspendedAt => $composableBuilder(
    column: $table.suspendedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PluginsTableOrderingComposer get pluginId {
    final $$PluginsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableOrderingComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkerStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkerStateTable> {
  $$WorkerStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get lastStartedAt => $composableBuilder(
    column: $table.lastStartedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get restartCount => $composableBuilder(
    column: $table.restartCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get suspendedAt => $composableBuilder(
    column: $table.suspendedAt,
    builder: (column) => column,
  );

  $$PluginsTableAnnotationComposer get pluginId {
    final $$PluginsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.pluginId,
      referencedTable: $db.plugins,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PluginsTableAnnotationComposer(
            $db: $db,
            $table: $db.plugins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkerStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkerStateTable,
          WorkerStateData,
          $$WorkerStateTableFilterComposer,
          $$WorkerStateTableOrderingComposer,
          $$WorkerStateTableAnnotationComposer,
          $$WorkerStateTableCreateCompanionBuilder,
          $$WorkerStateTableUpdateCompanionBuilder,
          (WorkerStateData, $$WorkerStateTableReferences),
          WorkerStateData,
          PrefetchHooks Function({bool pluginId})
        > {
  $$WorkerStateTableTableManager(_$AppDatabase db, $WorkerStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkerStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkerStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkerStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> pluginId = const Value.absent(),
                Value<DateTime?> lastStartedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> restartCount = const Value.absent(),
                Value<DateTime?> suspendedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkerStateCompanion(
                pluginId: pluginId,
                lastStartedAt: lastStartedAt,
                lastError: lastError,
                restartCount: restartCount,
                suspendedAt: suspendedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String pluginId,
                Value<DateTime?> lastStartedAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> restartCount = const Value.absent(),
                Value<DateTime?> suspendedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkerStateCompanion.insert(
                pluginId: pluginId,
                lastStartedAt: lastStartedAt,
                lastError: lastError,
                restartCount: restartCount,
                suspendedAt: suspendedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkerStateTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({pluginId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (pluginId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.pluginId,
                                referencedTable: $$WorkerStateTableReferences
                                    ._pluginIdTable(db),
                                referencedColumn: $$WorkerStateTableReferences
                                    ._pluginIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkerStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkerStateTable,
      WorkerStateData,
      $$WorkerStateTableFilterComposer,
      $$WorkerStateTableOrderingComposer,
      $$WorkerStateTableAnnotationComposer,
      $$WorkerStateTableCreateCompanionBuilder,
      $$WorkerStateTableUpdateCompanionBuilder,
      (WorkerStateData, $$WorkerStateTableReferences),
      WorkerStateData,
      PrefetchHooks Function({bool pluginId})
    >;
typedef $$HostSettingsTableTableCreateCompanionBuilder =
    HostSettingsTableCompanion Function({
      required String key,
      required Object? value,
      Value<int> rowid,
    });
typedef $$HostSettingsTableTableUpdateCompanionBuilder =
    HostSettingsTableCompanion Function({
      Value<String> key,
      Value<Object?> value,
      Value<int> rowid,
    });

class $$HostSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $HostSettingsTableTable> {
  $$HostSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$HostSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $HostSettingsTableTable> {
  $$HostSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HostSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $HostSettingsTableTable> {
  $$HostSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$HostSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HostSettingsTableTable,
          HostSettingRow,
          $$HostSettingsTableTableFilterComposer,
          $$HostSettingsTableTableOrderingComposer,
          $$HostSettingsTableTableAnnotationComposer,
          $$HostSettingsTableTableCreateCompanionBuilder,
          $$HostSettingsTableTableUpdateCompanionBuilder,
          (
            HostSettingRow,
            BaseReferences<
              _$AppDatabase,
              $HostSettingsTableTable,
              HostSettingRow
            >,
          ),
          HostSettingRow,
          PrefetchHooks Function()
        > {
  $$HostSettingsTableTableTableManager(
    _$AppDatabase db,
    $HostSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HostSettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HostSettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HostSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<Object?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HostSettingsTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required Object? value,
                Value<int> rowid = const Value.absent(),
              }) => HostSettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HostSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HostSettingsTableTable,
      HostSettingRow,
      $$HostSettingsTableTableFilterComposer,
      $$HostSettingsTableTableOrderingComposer,
      $$HostSettingsTableTableAnnotationComposer,
      $$HostSettingsTableTableCreateCompanionBuilder,
      $$HostSettingsTableTableUpdateCompanionBuilder,
      (
        HostSettingRow,
        BaseReferences<_$AppDatabase, $HostSettingsTableTable, HostSettingRow>,
      ),
      HostSettingRow,
      PrefetchHooks Function()
    >;
typedef $$LogsTableCreateCompanionBuilder =
    LogsCompanion Function({
      Value<int> id,
      Value<String?> pluginId,
      Value<String> level,
      required String message,
      required DateTime createdAt,
    });
typedef $$LogsTableUpdateCompanionBuilder =
    LogsCompanion Function({
      Value<int> id,
      Value<String?> pluginId,
      Value<String> level,
      Value<String> message,
      Value<DateTime> createdAt,
    });

class $$LogsTableFilterComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pluginId => $composableBuilder(
    column: $table.pluginId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LogsTableOrderingComposer extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pluginId => $composableBuilder(
    column: $table.pluginId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LogsTable> {
  $$LogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pluginId =>
      $composableBuilder(column: $table.pluginId, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$LogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LogsTable,
          Log,
          $$LogsTableFilterComposer,
          $$LogsTableOrderingComposer,
          $$LogsTableAnnotationComposer,
          $$LogsTableCreateCompanionBuilder,
          $$LogsTableUpdateCompanionBuilder,
          (Log, BaseReferences<_$AppDatabase, $LogsTable, Log>),
          Log,
          PrefetchHooks Function()
        > {
  $$LogsTableTableManager(_$AppDatabase db, $LogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> pluginId = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LogsCompanion(
                id: id,
                pluginId: pluginId,
                level: level,
                message: message,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> pluginId = const Value.absent(),
                Value<String> level = const Value.absent(),
                required String message,
                required DateTime createdAt,
              }) => LogsCompanion.insert(
                id: id,
                pluginId: pluginId,
                level: level,
                message: message,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LogsTable,
      Log,
      $$LogsTableFilterComposer,
      $$LogsTableOrderingComposer,
      $$LogsTableAnnotationComposer,
      $$LogsTableCreateCompanionBuilder,
      $$LogsTableUpdateCompanionBuilder,
      (Log, BaseReferences<_$AppDatabase, $LogsTable, Log>),
      Log,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PluginsTableTableManager get plugins =>
      $$PluginsTableTableManager(_db, _db.plugins);
  $$PluginFilesTableTableManager get pluginFiles =>
      $$PluginFilesTableTableManager(_db, _db.pluginFiles);
  $$PluginDataTableTableManager get pluginData =>
      $$PluginDataTableTableManager(_db, _db.pluginData);
  $$PluginSettingsTableTableManager get pluginSettings =>
      $$PluginSettingsTableTableManager(_db, _db.pluginSettings);
  $$PolicyCacheTableTableManager get policyCache =>
      $$PolicyCacheTableTableManager(_db, _db.policyCache);
  $$ButtonPositionsTableTableManager get buttonPositions =>
      $$ButtonPositionsTableTableManager(_db, _db.buttonPositions);
  $$WorkerStateTableTableManager get workerState =>
      $$WorkerStateTableTableManager(_db, _db.workerState);
  $$HostSettingsTableTableTableManager get hostSettingsTable =>
      $$HostSettingsTableTableTableManager(_db, _db.hostSettingsTable);
  $$LogsTableTableManager get logs => $$LogsTableTableManager(_db, _db.logs);
}
