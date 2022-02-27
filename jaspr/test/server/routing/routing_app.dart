import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route('/', (_) => Home()),
        Route('/about', (_) => About()),
        Route.lazy('/contact', (_) => Contact(), () => Future.delayed(Duration(milliseconds: 10))),
      ],
      onUnknownRoute: (route, context) {
        return DomComponent(tag: 'span', child: Text('Unknown ($route)'));
      },
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
  }
}

class Contact extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'span', child: Text('Contact'));
  }
}
