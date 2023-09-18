import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

part 'app.g.dart';

@client
class App extends StatelessComponent with _$App {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(routes: [
      Route(path: '/', builder: (context, state) => Home()),
      Route(path: '/about', builder: (context, state) => About()),
    ]);
  }
}

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'h1',
      child: Text('Home'),
    );
    // navigate to /about
    yield DomComponent(
      tag: 'a',
      attributes: {
        'href': '/about',
      },
      child: Text('About'),
    );
  }
}

class About extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'h1',
      child: Text('About'),
    );
  }
}
