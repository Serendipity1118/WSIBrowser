// App lifecycle -> workers (F-05-2, P4-09): background = suspend, foreground = resume.
import 'package:flutter/widgets.dart';

import '../runtime/worker_manager.dart';

class WorkerLifecycleObserver with WidgetsBindingObserver {
  WorkerLifecycleObserver(this.workers);

  final WorkerManager workers;

  void start() => WidgetsBinding.instance.addObserver(this);
  void stop() => WidgetsBinding.instance.removeObserver(this);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        workers.suspendAll();
      case AppLifecycleState.resumed:
        workers.resumeAll();
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }
}
