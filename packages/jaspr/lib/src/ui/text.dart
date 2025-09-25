import '../../jaspr.dart';

class TextParagraph extends StatelessComponent {
  const TextParagraph({super.key, required this.children});

  final List<Component> children;

  @override
  Component build(BuildContext context) {
    return p(children);
  }
}

class TextSpan extends StatelessComponent {
  const TextSpan({super.key, required this.text, this.breakLine = false, this.newLine = false});

  final String text;
  final bool breakLine;
  final bool newLine;

  @override
  Component build(BuildContext context) {
    final children = <Component>[];
    if (newLine) children.add(br());

    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      children.add(Component.text(lines[i]));
      if (i < lines.length - 1 || breakLine) {
        children.add(br());
      }
    }
    return Component.fragment(children);
  }
}

class Heading extends StatelessComponent {
  const Heading({super.key, this.size = 1, required this.text}) : assert(size >= 1 && size <= 6);

  final String text;
  final int size;

  @override
  Component build(BuildContext context) {
    return switch (size) {
      1 => h1([Component.text(text)]),
      2 => h2([Component.text(text)]),
      3 => h3([Component.text(text)]),
      4 => h4([Component.text(text)]),
      5 => h5([Component.text(text)]),
      6 => h6([Component.text(text)]),
      _ => throw UnimplementedError(),
    };
  }
}

class BreakLine extends StatelessComponent {
  final int numberLines;

  const BreakLine({this.numberLines = 1});

  @override
  Component build(BuildContext context) {
    return Component.fragment([for (var i = 0; i < numberLines; i++) br()]);
  }
}
