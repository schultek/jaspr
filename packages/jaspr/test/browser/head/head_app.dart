import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class App extends StatelessComponent {
  @override
  Component build(BuildContext context) {
    return Component.fragment([
      Document.head(title: 'a', meta: {'test': 'b', 'c': 'd'}),
      Page(),
    ]);
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
  Component build(BuildContext context) {
    return Component.fragment([
      div([
        if (!pressed) ...[
          Document.head(title: 'b', meta: {'c': 'e'}),
          Document.head(title: 'c'),
        ] else ...[
          Document.head(title: 'd'),
        ],
      ]),
      button(
        onClick: () {
          setState(() => pressed = true);
        },
        [Component.text('Toggle')],
      ),
    ]);
  }
}
