import 'package:jaspr/html.dart';

part 'button.g.dart';

@app
class Button extends StatefulComponent with _$Button {
  const Button({Key? key}) : super(key: key);

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {

  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button([text('Click Me')], events: {'click': (_) => setState(() => count++)});

    yield text('You clicked $count times.');
  }
}
