import 'package:jaspr/jaspr.dart';

typedef Session = Object;

class InheritedSession extends InheritedComponent {
  const InheritedSession._({required super.child});

  static Session sessionOf(BuildContext context) {
    throw AssertionError('InheritedSession may only be used on the server.');
  }

  static InheritedSession of(BuildContext context) {
    throw AssertionError('InheritedSession may only be used on the server.');
  }

  @override
  bool updateShouldNotify(InheritedSession oldComponent) {
    return false;
  }
}
