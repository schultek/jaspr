export 'package:meta/meta.dart'
    show factory, immutable, mustCallSuper, nonVirtual, optionalTypeArgs, protected, required, visibleForTesting;

export 'src/foundation/annotations.dart';
export 'src/foundation/basic_types.dart';
export 'src/foundation/binding.dart';
export 'src/foundation/binding_stub.dart' //
    if (dart.library.html) 'src/browser/browser_binding.dart'
    if (dart.library.io) 'src/server/server_binding.dart';
export 'src/foundation/change_notifier.dart';
export 'src/foundation/constants.dart';
export 'src/foundation/interop_stub.dart' //
    if (dart.library.html) 'src/browser/native_interop.dart'
    if (dart.library.io) 'src/server/native_interop.dart';
export 'src/foundation/object.dart';
export 'src/foundation/run_app_stub.dart'
    if (dart.library.html) 'src/browser/run_app.dart'
    if (dart.library.io) 'src/server/run_app.dart' show runApp;
export 'src/foundation/scheduler.dart';
export 'src/foundation/sync.dart';
export 'src/framework/framework.dart';
export 'src/ui/styles.dart';
