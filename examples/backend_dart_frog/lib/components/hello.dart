import 'package:jaspr/dom.dart';

@client
class Hello extends StatelessComponent {
  Hello({required this.name, super.key});

  final String name;

  @override
  Component build(BuildContext context) {
    return p([.text('Hello $name')]);
  }
}
