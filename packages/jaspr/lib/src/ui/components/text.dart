import 'package:jaspr/components.dart';
import 'package:jaspr/jaspr.dart';

class RichText extends BaseComponent {
  const RichText({
  super.key,
  super.id,
  super.styles,
  super.classes,
  super.attributes,
  super.events,
  super.child,
  super.children,
  }) : super(tag: 'p');
}

class TextSpan extends BaseComponent {
  final String text;
  final bool rawHtml;
  final bool breakLine;
  final bool newLine;

  const TextSpan({
  required this.text,
  this.rawHtml = false,
  this.breakLine = false,
  this.newLine = false,
  super.key,
  super.id,
  super.styles,
  super.classes,
  super.attributes,
  super.events,
  }) : super(tag: 'span');

  @override
  List<Component> getChildren() {
    List<Component> children = [];
    if (newLine) children.add(DomComponent(tag: 'br'));

    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      children.add(Text(lines[i], rawHtml: rawHtml));
      if (i < lines.length - 1 || breakLine) {
        children.add(DomComponent(tag: 'br'));
      }
    }
    return children;
  }
}

class Title extends BaseComponent {
  final String text;
  final int _size;

  Title({
    required this.text,
    size = 1,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
  }) : _size = size,
       super(tag: '');

  get size {
    if (_size < 1) {
      print('Warning: Title have too low size!');
      return 1;
    }
    else if (_size > 6) {
      print('Warning: Title have too high size!');
      return 6;
    } else {
      return _size;
    }
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      id: id,
      tag: 'h$size',
      styles: getStyles(),
      classes: getClasses(),
      attributes: getAttributes(),
      events: getEvents(),
      child: Text(text),
    );
  }
}

class BreakLine extends StatelessComponent {
  final int numberLines;

  const BreakLine({
    this.numberLines = 1,
  });

  @override
  Iterable<Component> build(BuildContext context) sync* {
    for (var i = 0; i < numberLines; i++) {
      yield DomComponent(tag: 'br');
    }
  }
}
