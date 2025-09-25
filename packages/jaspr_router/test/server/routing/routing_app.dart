import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Router(
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
  Component build(BuildContext context) {
    shouldThrow(() => Router.of(context).push('/'));
    shouldThrow(() => Router.of(context).replace('/'));
    shouldThrow(() => Router.of(context).back());

    return span([text('Home')]);
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
  Component build(BuildContext context) {
    return span([text('About')]);
  }
}

class Contact extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return span([text('Contact')]);
  }
}
