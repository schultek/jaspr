import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Router(
      routes: [
        Route(path: '/', builder: (_, _) => Home()),
        Route(path: '/about', builder: (_, _) => About()),
      ],
      errorBuilder: (_, state) {
        return span([Component.text('Unknown (${state.location})')]);
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

    return span([Component.text('Home')]);
  }

  void shouldThrow(void Function() fn) {
    try {
      fn();
    } on UnimplementedError catch (_) {
      return;
    }

    throw AssertionError('Router method should throw on server.');
  }
}

class About extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return span([Component.text('About')]);
  }
}

class Contact extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return span([Component.text('Contact')]);
  }
}
