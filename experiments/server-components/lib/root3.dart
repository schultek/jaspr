import 'package:jaspr/jaspr.dart';

@client
class Root3 extends StatelessComponent {
  const Root3({required this.children, required this.children2, super.key});

  final List<Component> children;
  final Map<String, Component> children2;

  @override
  Component build(BuildContext context) {
    return section([
      for (var child in children)
        p([
          text("Child 1: "),
          child,
        ]),
      aside([
        for (var entry in children2.entries)
          div([
            text("Child 2 [${entry.key}]: "),
            entry.value,
          ]),
      ]),
    ]);
  }
}
