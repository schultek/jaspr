import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

@client
class InnerButton extends StatelessComponent {
  const InnerButton({super.key});

  @override
  Component build(BuildContext context) => button([
    .text('Click me'),
  ]);
}
