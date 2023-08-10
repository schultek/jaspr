import 'package:jaspr/jaspr.dart';

part 'app.g.dart';

@client
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      classes: 'p-6 max-w-sm mx-auto bg-white rounded-xl shadow-lg flex items-center space-x-4'.split(' '),
      child: Text('Hello World'),
    );
  }
}
