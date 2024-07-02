import 'package:jaspr/jaspr.dart';

class Tag extends StatelessComponent {
  const Tag({required this.label, super.key});

  final String label;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield span(classes: "tag", [text(label)]);
  }

  static List<StyleRule> get styles => [
        css('.tag').box(
          border: Border.all(BorderSide.solid(color: Colors.black, width: 1.px)),
          radius: BorderRadius.circular(0.7.em),
          margin: EdgeInsets.symmetric(horizontal: 2.px),
          padding: EdgeInsets.symmetric(horizontal: 0.4.em, vertical: 0.2.em),
        ),
      ];
}
