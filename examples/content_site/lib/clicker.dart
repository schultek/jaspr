import 'package:jaspr/jaspr.dart';
import 'package:jaspr_content/theme.dart';

@client
class Clicker extends StatefulComponent {
  const Clicker({
    super.key,
  });

  @override
  State<Clicker> createState() => _ClickerState();
}

class _ClickerState extends State<Clicker> {
  int count = 0;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield button(onClick: () => setState(() => count++), styles: Styles(border: Border(color: ContentColors.primary)), [
      text('Click me! ($count)'),
    ]);
  }
}
