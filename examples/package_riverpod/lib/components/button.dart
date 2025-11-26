import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

/// Simple button component
class Button extends StatelessComponent {
  Button({required this.label, required this.onPressed});

  final String label;
  final void Function() onPressed;

  @override
  Component build(BuildContext context) {
    return button(events: {'click': (e) => onPressed()}, [.text(label)]);
  }
}
