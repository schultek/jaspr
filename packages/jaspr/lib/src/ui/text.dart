import '../../jaspr.dart';

class TextParagraph extends StatelessComponent {
  const TextParagraph({
    super.key,
    required this.children,
  });

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield p(children);
  }
}

class TextSpan extends StatelessComponent {
  const TextSpan({
    super.key,
    required this.text,
    this.breakLine = false,
    this.newLine = false,
  });

  final String text;
  final bool breakLine;
  final bool newLine;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (newLine) yield br();

    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      yield Text(lines[i]);
      if (i < lines.length - 1 || breakLine) {
        yield br();
      }
    }
  }
}

class Heading extends StatelessComponent {
  const Heading({
    super.key,
    this.size = 1,
    required this.text,
  }) : assert(size >= 1 && size <= 6);

  final String text;
  final int size;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield switch (size) {
      1 => h1([Text(text)]),
      2 => h2([Text(text)]),
      3 => h3([Text(text)]),
      4 => h4([Text(text)]),
      5 => h5([Text(text)]),
      6 => h6([Text(text)]),
      _ => throw UnimplementedError(),
    };
  }
}

class BreakLine extends StatelessComponent {
  const BreakLine({
    this.numberLines = 1,
  });

  final int numberLines;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    for (var i = 0; i < numberLines; i++) {
      yield br();
    }
  }
}
