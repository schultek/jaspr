import 'package:jaspr/jaspr.dart';

import '../../pkg/split/split.dart';

class Splitter extends StatelessComponent {
  const Splitter({required this.children, this.horizontal = true, this.initialSizes, Key? key}) : super(key: key);

  final List<Component> children;
  final bool horizontal;
  final List<double>? initialSizes;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield* children;
  }

  @override
  Element createElement() => SplitterElement(this);
}

class SplitterElement extends StatelessElement {
  SplitterElement(Splitter component) : super(component);

  @override
  Splitter get component => super.component as Splitter;

  late var sizes = component.initialSizes ?? <double>[];
  var splitPairs = <SplitPair>[];

  Map<String, String> getElementStyle(int childIndex) {
    var size = sizes[childIndex];
    var dragging = (childIndex > 0 ? splitPairs[childIndex - 1].dragging : false) ||
        (childIndex < splitPairs.length ? splitPairs[childIndex].dragging : false);
    return {
      'flex-basis': 'calc($size% - 3px)',
      if (dragging) ...{
        'user-select': 'none',
        'pointer-events': 'none',
      },
    };
  }

  void renderGutter(DomBuilder b, int gutterIndex) {
    var pair = splitPairs[gutterIndex];
    b.open(
      'div',
      classes: ['gutter', 'gutter-${component.horizontal ? 'horizontal' : 'vertical'}'],
      styles: {'flex-basis': '6px'},
      events: {'mousedown': (e) => pair.startDragging(e.event)},
    );
    b.close();
  }

  void adjustSizes(double offset, int index) {
    var percentage = sizes[index] + sizes[index + 1];

    sizes[index] = (offset * percentage * 100).roundToDouble() / 100;
    sizes[index + 1] = ((percentage - offset * percentage) * 100).roundToDouble() / 100;

    invalidate();
  }

  @override
  void performRebuild() {
    super.performRebuild();

    var elements = <DomElement>[];

    visitDomChild(Element child) {
      if (child is DomElement) {
        elements.add(child);
      } else {
        child.visitChildren(visitDomChild);
      }
    }

    visitChildren(visitDomChild);

    if (sizes.length != elements.length) {
      sizes = List.filled(elements.length, 100 / elements.length);
    }
    if (splitPairs.length != elements.length - 1) {
      splitPairs = List.generate(elements.length - 1, (i) => SplitPair(this, i, elements[i], elements[i + 1]));
    }
  }

  @override
  void render(DomBuilder b) {
    super.render(SplitterBuilder(this, b));
  }

  void invalidateSelf() {
    invalidate();
  }
}

class SplitterBuilder extends WrappedDomBuilder {
  SplitterElement element;

  SplitterBuilder(this.element, DomBuilder builder) : super(builder);

  int depth = 0;
  int childIndex = 0;

  @override
  void open(
    String tag, {
    String? key,
    String? id,
    Iterable<String>? classes,
    Map<String, String>? styles,
    Map<String, String>? attributes,
    Map<String, DomEventFn>? events,
    DomLifecycleEventFn? onCreate,
    DomLifecycleEventFn? onUpdate,
    DomLifecycleEventFn? onRemove,
  }) {
    if (depth == 0 && childIndex != 0) {
      element.renderGutter(builder, childIndex - 1);
    }

    if (depth == 0) {
      styles = {...element.getElementStyle(childIndex), ...styles ?? {}};
    }

    super.open(
      tag,
      key: key,
      id: id,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: events,
      onCreate: onCreate,
      onUpdate: onUpdate,
      onRemove: onRemove,
    );

    depth++;
  }

  @override
  dynamic close({String? tag}) {
    var e = super.close(tag: tag);
    depth--;

    if (depth == 0) {
      childIndex++;
    }
    return e;
  }
}
