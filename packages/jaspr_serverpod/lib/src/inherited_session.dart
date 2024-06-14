import 'package:jaspr/jaspr.dart';
import 'package:serverpod/server.dart';

export 'package:serverpod/server.dart' show Session;

class InheritedSession extends InheritedComponent {
  const InheritedSession({
    required this.session,
    super.key,
    required super.child,
  });

  final Session session;

  static Session sessionOf(BuildContext context) {
    return of(context).session;
  }

  static InheritedSession of(BuildContext context) {
    final InheritedSession? result = context.dependOnInheritedComponentOfExactType<InheritedSession>();
    assert(result != null, 'No InheritedSession found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedSession oldComponent) {
    return oldComponent.session != session;
  }
}
