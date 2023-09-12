import 'package:jaspr/jaspr.dart';

import 'home.dart' deferred as home;

part 'app.g.dart';

@app
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );

    awaited()

    yield FutureBuilder(
      future: home.loadLibrary(),
      builder: (context, snapshot) sync* {
        if (snapshot.connectionState == ConnectionState.done) {
          yield home.Home();
        }
      },
    );
  }
}
