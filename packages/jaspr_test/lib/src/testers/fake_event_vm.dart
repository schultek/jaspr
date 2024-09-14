// ignore: implementation_imports
import 'package:jaspr/src/foundation/events/web_stub.dart';

Event fakeEvent() {
  return _FakeEvent();
}

final class _FakeEvent implements Event {
  @override
  void preventDefault() {}

  @override
  Node get target => throw UnimplementedError();
}
