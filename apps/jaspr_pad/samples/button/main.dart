// [sample=3] Simple Button
import 'package:jaspr/jaspr.dart';

void main() {
  runApp(App());
}

class App extends StatelessComponent {
  const App({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Button(
      label: 'Button 1',
      onPressed: () {
        print("Button 1 pressed");
      },
    );

    yield Button(
      label: 'Button 2',
      onPressed: () {
        print("Button 2 pressed");
      },
    );
  }
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(
      onClick: onPressed,
      [text(label)],
    );
  }
}
