import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route('/', (_) => [Home()]),
        Route('/about', (_) => [About()]),
        Route.lazy('/contact', (_) => [Contact()], () => Future.delayed(Duration(milliseconds: 10))),
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
    shouldThrow(() => Router.of(context).push('/'));
    shouldThrow(() => Router.of(context).replace('/'));
    shouldThrow(() => Router.of(context).back());

    yield DomComponent(tag: 'span', child: Text('Home'));
  }

  void shouldThrow(Function fn) async {
    try {
      await fn();
    } on UnimplementedError catch (_) {
      return;
    }

    throw AssertionError('Router method should throw on server.');
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
