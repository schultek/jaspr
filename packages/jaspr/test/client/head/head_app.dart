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

/// Swaps between pages whose head sits in a fragment, as a router does.
class SwappingApp extends StatefulComponent {
  const SwappingApp({super.key});

  @override
  State<SwappingApp> createState() => _SwappingAppState();
}

class _SwappingAppState extends State<SwappingApp> {
  bool second = false;

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      if (second)
        Component.fragment([
          Document.head(title: 'second'),
          div([Component.text('second')]),
        ], key: const ValueKey('second'))
      else
        Component.fragment([
          Document.head(title: 'first'),
          div([Component.text('first')]),
        ], key: const ValueKey('first')),
      button(onClick: () => setState(() => second = !second), [Component.text('Swap')]),
    ]);
  }
}
