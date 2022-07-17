import '../../jaspr.dart';

mixin SchedulerBinding on BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  static SchedulerBinding? _instance;
  static SchedulerBinding? get instance => _instance;

  /// Schedules a build and ultimately calls [buildCallback]
  void scheduleBuild(VoidCallback buildCallback);
}
