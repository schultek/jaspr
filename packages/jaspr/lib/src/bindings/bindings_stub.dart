import '../foundation/binding.dart';
import '../foundation/scheduler.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';

/// Main entry point on the server
void runApp(Component app) {}

/// Global component binding for the app
abstract class AppBinding extends BindingBase with SchedulerBinding, ComponentsBinding, SyncBinding {
  static AppBinding ensureInitialized() {
    throw UnimplementedError('Should be overridden on client and server.');
  }
}
