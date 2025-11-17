import '../framework/framework.dart';
import 'sync/sync_web.dart' if (dart.library.io) 'sync/sync_vm.dart' as s;

/// Mixin on [State] that syncs state data from the server to the client.
mixin SyncStateMixin<T extends StatefulComponent, U> on State<T> {
  /// Called on the server after the initial build, to retrieve the state data of this component.
  U getState();

  /// Called on the client during [initState] to receive the synced state from the server.
  ///
  /// On initialization, this will be called as part of the `super.initState()` call. It is recommended to start with the
  /// inherited method call in you custom `initState()` implementation, however when you want to do some work before the
  /// initial `updateState()` call, you can invoke the `super.initState()` later in your implementation.
  ///
  /// ```dart
  /// @override
  /// void initState() {
  ///   // do some pre-initialization
  ///   super.initState(); // this will also call your updateState() implementation
  ///   // do some post-initialization
  /// }
  /// ```
  void updateState(U value);

  @override
  void initState() {
    super.initState();
    initSyncState(this);
  }

  static void initSyncState(SyncStateMixin<StatefulComponent, Object?> mixin) => s.initSyncState(mixin);
}

const sync = SyncAnnotation._();

class SyncAnnotation {
  const SyncAnnotation._();
}
