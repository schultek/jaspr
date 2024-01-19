import 'package:jaspr/components.dart';
import 'package:jaspr_riverpod/jaspr_riverpod.dart';

Component providerApp(ComponentBuilder builder) {
  return ProviderScope(
    child: Builder(builder: builder),
  );
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed, super.key});

  final String label;
  final void Function() onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'button',
      child: Text(label),
      events: {'click': (e) => onPressed()},
    );
  }
}
