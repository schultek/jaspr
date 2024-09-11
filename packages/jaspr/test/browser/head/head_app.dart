import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield Page();
  }
}

class Page extends StatefulComponent {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  bool pressed = false;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield div([
      if (!pressed) ...[
        Document.head(title: 'b', meta: {'c': 'e'}),
        Document.head(title: 'c'),
      ] else ...[
        Document.head(title: 'd'),
      ]
    ]);
    yield button(onClick: () {
      setState(() => pressed = true);
    }, [text('Toggle')]);
  }
}
