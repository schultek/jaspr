import 'package:jaspr/html.dart';

@app
class Hello extends StatelessComponent {
  Hello({required this.name, super.key});

  final String name;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([text('Hello $name')]);

    yield a([text('Go To App')], href: '/app');
  }
}
