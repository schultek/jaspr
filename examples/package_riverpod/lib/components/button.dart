import 'package:jaspr/jaspr.dart';

/// Simple button component
class Button extends StatelessComponent {
  Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(events: {
      'click': (e) => onPressed()
    }, [
      text(label),
    ]);
  }
}
