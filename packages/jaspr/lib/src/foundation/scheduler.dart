import '../../jaspr.dart';

enum SchedulerPhase { idle, midFrameCallback, postFrameCallbacks }

mixin SchedulerBinding {
  SchedulerPhase _schedulerPhase = SchedulerPhase.idle;
  SchedulerPhase get schedulerPhase => _schedulerPhase;

  /// Schedules a frame with the provided [frameCallback].
  void scheduleFrame(VoidCallback frameCallback);

  /// Schedules a build and ultimately calls [_handleFrame] with the provided [buildCallback].
  void scheduleBuild(VoidCallback buildCallback) {
    scheduleFrame(() => _handleFrame(buildCallback));
  }

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
