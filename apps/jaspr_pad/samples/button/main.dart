// [sample=3] Simple Button
import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

void main() {
  runApp(App());
}

class App extends StatelessComponent {
  const App({super.key});

  @override
  Component build(BuildContext context) {
    return div([
      Button(
        label: 'Button 1',
        onPressed: () {
          print("Button 1 pressed");
        },
      ),
      Button(
        label: 'Button 2',
        onPressed: () {
          print("Button 2 pressed");
        },
      ),
    ]);
  }
}

class Button extends StatelessComponent {
  const Button({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback onPressed;

  @override
  Component build(BuildContext context) {
    return button(onClick: onPressed, [text(label)]);
  }
}
