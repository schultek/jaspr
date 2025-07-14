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
      errorBuilder: (_, state) {
        return span([text('Unknown (${state.location})')]);
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

    yield span([text('Home')]);
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
    yield span([text('About')]);
  }
}

class Contact extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span([text('Contact')]);
  }
}
