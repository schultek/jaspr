import 'package:jaspr/jaspr.dart';

part 'hello.g.dart';

@client
class Hello extends StatelessComponent with _$Hello {
  Hello({required this.name, super.key});

  final String name;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p([text('Hello $name')]);
  }
}
