// Tab list as a bottom sheet: switch, close, open a new one (F-01-1).
import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../l10n/generated/app_localizations.dart';
import 'tab_manager.dart';

Future<void> showTabSwitcher(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const _TabSwitcher(),
  );
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher();

  @override
  Widget build(BuildContext context) {
    final services = AppScope.of(context);
    final tabs = services.tabs;
    final l = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: tabs,
      builder: (context, _) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('${l.tabsTitle} (${tabs.tabs.length}/${tabs.limit})', style: Theme.of(context).textTheme.titleMedium),
                trailing: FilledButton.icon(
                  onPressed: tabs.canOpenMore
                      ? () {
                          tabs.open(kStartPageUrl);
                          Navigator.of(context).pop();
                        }
                      : null,
                  icon: const Icon(Icons.add),
                  label: Text(l.actionNewTab),
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: tabs.tabs.length,
                  itemBuilder: (context, i) {
                    final tab = tabs.tabs[i];
                    final selected = i == tabs.activeIndex;
                    final title = tab.isStartPage ? l.appTitle : (tab.title.isEmpty ? l.tabUntitled : tab.title);
                    return ListTile(
                      key: ValueKey('switcher-${tab.id}'),
                      selected: selected,
                      leading: Icon(tab.isStartPage ? Icons.home_outlined : Icons.public),
                      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: tab.isStartPage ? null : Text(tab.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        tooltip: l.actionCloseTab,
                        icon: const Icon(Icons.close),
                        onPressed: () => tabs.close(tab),
                      ),
                      onTap: () {
                        tabs.activate(i);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
