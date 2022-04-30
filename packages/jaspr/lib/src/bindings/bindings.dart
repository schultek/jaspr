export 'bindings_stub.dart' //
    if (dart.library.html) 'browser_bindings.dart'
    if (dart.library.io) 'server_bindings.dart';
