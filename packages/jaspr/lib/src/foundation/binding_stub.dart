import '../framework/framework.dart';
import 'binding.dart';
import 'scheduler.dart';
import 'sync.dart';

/// Global component binding for the app
abstract class AppBinding extends BindingBase with SchedulerBinding, ComponentsBinding, SyncBinding {
  static AppBinding ensureInitialized() {
    throw UnimplementedError('Should be overridden on client and server.');
  }
}
