import '../../../components.dart';
import '../styles/properties/list.dart';

class TextParagraph extends BaseComponent {
  const TextParagraph({
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
  })  : _size = size,
        super(tag: '');

  get size {
    if (_size < 1) {
      print('Warning: Title have too low size!');
      return 1;
    } else if (_size > 6) {
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

class TextListMarker {
  final bool? isInside;
  final Uri? imageUrl;
  final ListStyleType? type;

  const TextListMarker({
    this.isInside,
    this.imageUrl,
    this.type,
  });
}

class TextList extends BaseComponent {
  final TextListMarker? marker;

  const TextList({
    this.marker,
    required super.tag,
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.children,
  });

  factory TextList.ordered({
    Key? key,
    String? id,
    Styles? styles,
    List<String>? classes,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    List<Component>? children,
    TextListMarker? marker,
  }) {
    return TextList(
      key: key,
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children,
      tag: 'ol',
      marker: marker,
    );
  }

  factory TextList.unordered({
    Key? key,
    String? id,
    Styles? styles,
    List<String>? classes,
    Map<String, String>? attributes,
    Map<String, EventCallback>? events,
    List<Component>? children,
    TextListMarker? marker,
  }) {
    return TextList(
      key: key,
      id: id,
      styles: styles,
      classes: classes,
      attributes: attributes,
      events: events,
      children: children,
      tag: 'ul',
      marker: marker,
    );
  }

  @override
  Styles getStyles() => Styles.combine([
        Styles.raw({
          if (marker?.type == ListStyleType.none) 'margin': '0',
          if (marker?.type == ListStyleType.none) 'padding': '0',
          if (marker?.type != null) 'list-style-type': marker!.type!.value,
          if (marker?.isInside != null) 'list-style-position': marker!.isInside! ? 'inside' : 'outside',
          if (marker?.imageUrl != null) 'list-style-image': 'url("${marker?.imageUrl}")',
        }),
        if (styles != null) styles!
      ]);
}

class TextListItem extends BaseComponent {
  const TextListItem({
    super.key,
    super.id,
    super.styles,
    super.classes,
    super.attributes,
    super.events,
    super.child,
  }) : super(tag: 'li');
}
