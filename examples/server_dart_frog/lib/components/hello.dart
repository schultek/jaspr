import 'package:jaspr/jaspr.dart';

@client
class Hello extends StatelessComponent {
  Hello({required this.name, super.key});

  final String name;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([text('Hello $name')]);
  }
}
