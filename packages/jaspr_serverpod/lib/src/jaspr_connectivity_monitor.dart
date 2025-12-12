import 'dart:async';

import 'package:serverpod_client/serverpod_client.dart';
import 'package:web/web.dart';

/// Monitors the browsers connectivity. Should be attached to the generated Serverpod client.
///
/// {@category Setup}
final class JasprConnectivityMonitor extends ConnectivityMonitor {
  JasprConnectivityMonitor() {
    _onlineSub = const EventStreamProvider<Event>('online').forTarget(window).listen((_) {
      notifyListeners(true);
    });
    _offlineSub = const EventStreamProvider<Event>('offline').forTarget(window).listen((_) {
      notifyListeners(false);
    });
  }

  late final StreamSubscription<void> _onlineSub;
  late final StreamSubscription<void> _offlineSub;

  @override
  void dispose() {
    _onlineSub.cancel();
    _offlineSub.cancel();
    super.dispose();
  }
}
