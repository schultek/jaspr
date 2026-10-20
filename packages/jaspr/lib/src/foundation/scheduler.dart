import 'package:meta/meta.dart';

import 'basic_types.dart' show VoidCallback;

enum SchedulerPhase { idle, midFrameCallback, postFrameCallbacks }

mixin SchedulerBinding {
  SchedulerPhase _schedulerPhase = SchedulerPhase.idle;
  SchedulerPhase get schedulerPhase => _schedulerPhase;

  /// Schedules a frame with the provided [frameCallback].
  ///
  /// Implementations should schedule [frameCallback] to run asynchronously,
  /// so that updates made in the same task are batched into a single frame.
  @protected
  void scheduleFrame(VoidCallback frameCallback);

  /// Schedules a build and ultimately calls [_handleFrame] with the provided [buildCallback].
  @internal
  void scheduleBuild(VoidCallback buildCallback) {
    scheduleFrame(() => _handleFrame(buildCallback));
  }

  @internal
  void completeInitialFrame() {
    _flushPostFrameCallbacks();
  }

  void _handleFrame(VoidCallback buildCallback) {
    _schedulerPhase = SchedulerPhase.midFrameCallback;
    buildCallback();
    _schedulerPhase = SchedulerPhase.postFrameCallbacks;
    _flushPostFrameCallbacks();
    _schedulerPhase = SchedulerPhase.idle;
  }

  void _flushPostFrameCallbacks() {
    final localPostFrameCallbacks = List<VoidCallback>.of(_postFrameCallbacks);
    _postFrameCallbacks.clear();
    for (final callback in localPostFrameCallbacks) {
      callback();
    }
  }

  final List<VoidCallback> _postFrameCallbacks = <VoidCallback>[];

  void addPostFrameCallback(VoidCallback callback) {
    _postFrameCallbacks.add(callback);
  }
}
