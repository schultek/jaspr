import 'package:jaspr/jaspr.dart';
// ignore: implementation_imports
import 'package:universal_web/src/web.dart' as stubs;
import 'package:universal_web/web.dart';

Event fakeEvent(String type) {
  if (kIsWeb) {
    return Event(type);
  } else {
    return FakeEvent(type) as Event;
  }
}

final class FakeEvent implements stubs.Event {
  FakeEvent(this.type);

  @override
  final String type;

  @override
  void noSuchMethod(Invocation invocation) {
    // noop
  }
}
