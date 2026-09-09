// Plugin-provided menu sections for the URL bar's overflow menu (F-08-2).
// The browser layer only knows this shape; the runtime's MenuBus fills it.
import 'package:flutter/foundation.dart';

enum AppMenuItemType { page, action, toggle, separator }

class AppMenuItem {
  const AppMenuItem({
    required this.id,
    required this.type,
    this.label = '',
    this.icon,
    this.checked,
    this.onSelect,
  });

  final String id;
  final AppMenuItemType type;
  final String label;
  final String? icon;
  final bool? checked;

  /// Called for page / action / toggle. For toggle, receives the new value.
  final Future<void> Function(bool? value)? onSelect;
}

class AppMenuSection {
  const AppMenuSection({required this.title, required this.items});
  final String title;
  final List<AppMenuItem> items;
}

/// Something that provides plugin menu sections and notifies when they change.
abstract class AppMenuSource implements Listenable {
  List<AppMenuSection> get sections;
}
