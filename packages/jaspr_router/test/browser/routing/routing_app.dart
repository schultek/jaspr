import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Router(
      routes: [
        Route('/', (_) => [Home()]),
        Route('/about', (_) => [About()]),
        Route.lazy('/contact', (_) => [Contact()], () => Future.delayed(Duration(milliseconds: 10))),
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
      child: Text('Contact'),
      events: {
        'click': (e) => Router.of(context).replace('/contact', eager: false),
      },
    );
  }
}

class Contact extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'span', child: Text('Contact'));
    yield SyncContact();
  }
}

class SyncContact extends StatefulComponent {
  SyncContact({Key? key}) : super(key: key);

  @override
  State<StatefulComponent> createState() => ContactState();
}

class ContactState extends State<SyncContact> with SyncStateMixin<SyncContact, String> {
  String? name;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'span', child: Text(name ?? 'No Name'));
  }

  @override
  String saveState() => throw UnimplementedError();

  @override
  String get syncId => 'contact';

  @override
  void updateState(String? value) {
    setState(() => name = value);
  }
}
