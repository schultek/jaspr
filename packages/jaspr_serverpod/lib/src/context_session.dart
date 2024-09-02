import 'package:jaspr/jaspr.dart';

import 'inherited_session.dart' if (dart.library.js_interop) 'inherited_session_web.dart';

/// Context extension to get the Serverpod session from inside a components [build] method.
///
/// {@category Setup}
extension ContextSession on BuildContext {
  /// Get the current Serverpod session.
  Session get session => InheritedSession.sessionOf(this);
}
