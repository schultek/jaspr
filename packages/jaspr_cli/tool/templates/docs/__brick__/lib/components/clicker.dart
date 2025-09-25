import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/theme.dart';

/// A simple Jaspr component that counts the number of clicks.
@client
class Clicker extends StatefulComponent {
  const Clicker({super.key});

  @override
  State<Clicker> createState() => ClickerState();
}

class ClickerState extends State<Clicker> {
  int count = 0;

  @override
  Component build(BuildContext context) {
    return button(
      classes: 'clicker',
      onClick: () {
        setState(() => count++);
      },
      [
        text('Click me! ($count)'),
      ],
    );
  }

  @css
  static List<StyleRule> get styles => [
    css('.clicker').styles(
      padding: Padding.all(0.5.rem),
      margin: Margin.only(top: 1.rem),
      border: Border(color: ContentColors.primary),
      radius: BorderRadius.circular(0.5.rem),
    ),
  ];
}
