// WSI.tabs.* (F-06). Worker context only, 'tabs' permission.
import '../runtime/tab_controller.dart';
import 'registry.dart';

void registerTabsOps(OpRegistry registry, TabController tabs) {
  const workerOnly = {BridgeContext.worker};

  registry.register('tabs.open', permission: 'tabs', contexts: workerOnly, (call) async {
    final url = Uri.tryParse(call.requireString('url'));
    if (url == null || !(url.scheme == 'https' || url.scheme == 'http')) throw OpError('tabs.open: invalid url');
    final hidden = call.arg<bool>('hidden') ?? true;
    return tabs.open(call.session, url, hidden: hidden);
  });

  registry.register('tabs.navigate', permission: 'tabs', contexts: workerOnly, (call) async {
    final url = Uri.tryParse(call.requireString('url'));
    if (url == null || !(url.scheme == 'https' || url.scheme == 'http')) throw OpError('tabs.navigate: invalid url');
    await tabs.navigate(call.pluginId, call.requireString('tabId'), url);
    return true;
  });

  registry.register('tabs.run', permission: 'tabs', contexts: workerOnly, (call) async {
    return tabs.run(call.pluginId, call.requireString('tabId'), call.requireString('code'));
  });

  registry.register('tabs.close', permission: 'tabs', contexts: workerOnly, (call) async {
    await tabs.close(call.pluginId, call.requireString('tabId'));
    return true;
  });

  registry.register('tabs.list', permission: 'tabs', contexts: workerOnly, (call) async {
    return tabs.list(call.pluginId);
  });

  registry.register('tabs.dialogPolicy', permission: 'tabs', contexts: workerOnly, (call) async {
    final action = call.arg<String>('action') ?? 'accept';
    if (!const {'accept', 'dismiss', 'show'}.contains(action)) throw OpError('tabs.dialogPolicy: action must be accept / dismiss / show');
    tabs.dialogPolicies[call.pluginId] = action;
    return true;
  });
}
