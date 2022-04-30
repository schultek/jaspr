import '../foundation/binding.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';
import '../scheduler/binding.dart';

/// Main entry point for the app
///
/// TODO: Add hint about usage of global variables and isolate state
void runApp(Component app, {String attachTo = 'body'}) {}

/// Global component binding for the app
abstract class AppBinding extends BindingBase with ComponentsBinding, SyncBinding, SchedulerBinding {
  static AppBinding ensureInitialized() {
    throw UnimplementedError('Should be overridden on client and server.');
  }
}
