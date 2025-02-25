import 'package:jaspr/jaspr.dart';

class Tag extends StatelessComponent {
  const Tag({required this.label, super.key});

  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: "tag", [text(label)]);
  }

  @css
  static final styles = [
    css('.tag').styles(
      border: Border(color: Colors.black, width: 1.px),
      radius: BorderRadius.circular(0.7.em),
      margin: Margin.symmetric(horizontal: 2.px),
      padding: Padding.symmetric(horizontal: 0.4.em, vertical: 0.2.em),
    ),
  ];
}
