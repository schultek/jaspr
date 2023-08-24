import 'package:jaspr/html.dart';

part 'app.g.dart';

@client
class App extends StatelessComponent with _$App {
  const App(this.title);

  final String title;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield h1([text(title)]);
    yield p([text('Hello World')]);
  }
}
