import 'package:jaspr/jaspr.dart';

import 'inherited_session.dart' if (dart.library.js_interop) 'inherited_session_web.dart';

extension ContextSession on BuildContext {
  Session get session => InheritedSession.sessionOf(this);
}
