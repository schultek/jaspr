import 'package:jaspr/jaspr.dart';

part 'hello.g.dart';

@client
class Hello extends StatelessComponent with _$Hello {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World Component'),
    );
  }
}
