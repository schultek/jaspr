/// Core Jaspr framework and component APIs.
library;

export 'package:meta/meta.dart'
    show factory, immutable, mustCallSuper, nonVirtual, optionalTypeArgs, protected, visibleForTesting;

export 'src/components/async.dart';
export 'src/components/badge.dart';
export 'src/components/basic.dart';
export 'src/components/document.dart';
export 'src/components/listenable_builder.dart';
export 'src/foundation/annotations.dart';
export 'src/foundation/basic_types.dart';
export 'src/foundation/binding.dart';
export 'src/foundation/change_notifier.dart';
export 'src/foundation/constants.dart';
export 'src/foundation/object.dart';
export 'src/foundation/scheduler.dart';
export 'src/foundation/sync.dart';
export 'src/foundation/synchronous_future.dart';
export 'src/framework/framework.dart';
export 'src/stub/app_context_stub.dart'
    if (dart.library.js_interop) 'src/client/app_context.dart'
    if (dart.library.io) 'src/server/app_context.dart'
    show AppContext;
export 'src/stub/run_app_stub.dart'
    if (dart.library.js_interop) 'src/client/run_app.dart'
    if (dart.library.io) 'src/server/run_app.dart'
    show runApp;
