import 'dart:async';

import 'package:serverpod_client/serverpod_client.dart';
import 'package:web/web.dart';

class JasprConnectivityMonitor extends ConnectivityMonitor {
  JasprConnectivityMonitor() {
    _onlineSub = const EventStreamProvider<Event>('online').forTarget(window).listen((_) {
      notifyListeners(true);
    });
    _offlineSub = const EventStreamProvider<Event>('offline').forTarget(window).listen((_) {
      notifyListeners(false);
    });
  }

  late StreamSubscription _onlineSub;
  late StreamSubscription _offlineSub;

  @override
  void dispose() {
    _onlineSub.cancel();
    _offlineSub.cancel();
    super.dispose();
  }
}
