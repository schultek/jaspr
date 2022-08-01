import '../../jaspr.dart';

mixin SchedulerBinding on BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SchedulerBinding? _instance;
  static SchedulerBinding? get instance => _instance;

  /// Schedules a build and ultimately calls [handleFrame] with the provided [buildCallback]
  void scheduleBuild(VoidCallback buildCallback);

  @protected
  void handleFrame(VoidCallback buildCallback) {
    buildCallback();
    var localPostFrameCallbacks = List<VoidCallback>.of(_postFrameCallbacks);
    _postFrameCallbacks.clear();
    for (var callback in localPostFrameCallbacks) {
      callback();
    }
  }

  final List<VoidCallback> _postFrameCallbacks = <VoidCallback>[];

  void addPostFrameCallback(VoidCallback callback) {
    _postFrameCallbacks.add(callback);
  }
}
