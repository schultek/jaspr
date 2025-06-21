import 'package:jaspr/jaspr.dart';

@client
class Hello extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([
      text('Hello World Component'),
    ]);
  }
}
