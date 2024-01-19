import 'package:jaspr/jaspr.dart';

class Button extends StatelessComponent {
  const Button({
    super.key,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(classes: 'btn btn-primary', []);
  }
}
