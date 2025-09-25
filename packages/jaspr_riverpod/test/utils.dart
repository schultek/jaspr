import 'package:jaspr/jaspr.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

Component providerApp(ComponentBuilder builder) {
  return ProviderScope(child: Builder(builder: builder));
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed, super.key});

  final String label;
  final void Function() onPressed;

  @override
  Component build(BuildContext context) {
    return button(events: {'click': (e) => onPressed()}, [text(label)]);
  }
}
