import 'package:jaspr/jaspr.dart';

import '../../pkg/split/split.dart' as split;

class Splitter extends StatelessComponent {
  const Splitter({required this.children, Key? key}) : super(key: key);

  final List<Component> children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'div',
      classes: ['panels'],
      children: children,
    );
  }

  @override
  Element createElement() => WrapSplitterElement(this);
}

class WrapSplitterElement extends StatelessElement {
  WrapSplitterElement(Splitter component) : super(component);

  var sizes = <double>[];

  @override
  void render(DomBuilder b) {
    super.render(b);
    var elements = [];

    void getFirstDomElement(Element e) {
      if (e is DomElement) {
        elements.add(e.source);
        return;
      }
      var hasChild = false;
      e.visitChildren((element) {
        if (!hasChild) getFirstDomElement(element);
        hasChild = true;
      });
    }

    children.first.visitChildren(getFirstDomElement);

    if (sizes.length != elements.length) {
      sizes = List.filled(elements.length, 100 / elements.length);
    }

    split.flexSplit(
      elements,
      horizontal: true,
      gutterSize: 6,
      sizes: sizes,
      minSize: List.filled(elements.length, 100),
      onChange: (size, index) {
        if (index != null) {
          sizes[index.round()] = size;
        }
      },
    );
  }
}
