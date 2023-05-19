import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route(path: '/', builder: (_, __) => Home()),
        Route(path: '/about', builder: (_, __) => About()),
      ],
    );
  }
}

class Home extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'span', child: Text('Home'));
  }
}

class About extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'span', child: Text('About'));
    yield DomComponent(
      tag: 'button',
      child: Text('Home'),
      events: {
        'click': (e) => Router.of(context).push('/'),
      },
    );
  }
}
