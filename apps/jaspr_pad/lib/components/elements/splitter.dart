import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../../adapters/html.dart' as html;
import '../utils/node_reader.dart';

class Splitter extends StatefulComponent {
  const Splitter({required this.children, this.horizontal = true, this.initialSizes, super.key});

  final List<Component> children;
  final bool horizontal;
  final List<double>? initialSizes;

  @override
  State createState() => SplitterState();
}

class SplitterState extends State<Splitter> {
  late var sizes = component.initialSizes ?? <double>[];
  var splitPairs = <SplitPair>[];

  @override
  void initState() {
    super.initState();
    updatePairs();
  }

  @override
  void didUpdateComponent(Splitter oldComponent) {
    super.didUpdateComponent(oldComponent);
    updatePairs();
  }

  void updatePairs() {
    if (sizes.length != component.children.length) {
      sizes = List.filled(component.children.length, 100 / component.children.length);
    }
    splitPairs = List.generate(component.children.length - 1, (i) => SplitPair(this, i));
  }

  void adjustSizes(double offset, int index) {
    var percentage = sizes[index] + sizes[index + 1];

    sizes[index] = (offset * percentage * 100).roundToDouble() / 100;
    sizes[index + 1] = ((percentage - offset * percentage) * 100).roundToDouble() / 100;

    setState(() {});
  }

  void updateSelf() {
    setState(() {});
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    for (var i = 0; i < component.children.length; i++) {
      if (i > 0) {
        var pair = splitPairs[i - 1];
        yield div(
          classes: 'gutter gutter-${component.horizontal ? 'horizontal' : 'vertical'}',
          styles: Styles(flex: Flex(basis: 6.px)),
          events: {'mousedown': (e) => pair.startDragging(e as html.MouseEventOrStubbed)},
          [],
        );
      }

      var dragging =
          (i > 0 ? splitPairs[i - 1].dragging : false) || (i < splitPairs.length ? splitPairs[i].dragging : false);

      yield DomComponent.wrap(
        styles: Styles(
          raw: {
            'flex-basis': 'calc(${sizes[i]}% - 3px)',
          },
          userSelect: dragging ? UserSelect.none : null,
          pointerEvents: dragging ? PointerEvents.none : null,
        ),
        child: DomNodeReader(
          onNode: (node) {
            if (i > 0) splitPairs[i - 1].b = node;
            if (i < splitPairs.length) splitPairs[i].a = node;
          },
          child: component.children[i],
        ),
      );
    }
  }
}

class SplitPair {
  SplitterState parent;
  html.ElementOrStubbed? a, b;
  bool dragging;
  int index;

  double? _size;
  double? _start;
  double? _end;
  double? _dragOffset;

  SplitPair(this.parent, this.index, {this.dragging = false});

  void drag(html.EventOrStubbed e) {
    if (!dragging) return;
    if (e is! html.MouseEventOrStubbed) return;

    var h = parent.component.horizontal;

    var offset = (h ? e.client.x : e.client.y) - _start! + (3 - _dragOffset!);

    parent.adjustSizes(offset / _size!, index);
  }

  StreamSubscription? _mouseUpSub, _mouseMoveSub;

  void startDragging(html.MouseEventOrStubbed e) {
    // Right-clicking can't start dragging.
    if (e.button != 0) {
      return;
    }

    if (this.a == null || this.b == null) {
      return;
    }

    e.preventDefault();

    dragging = true;
    _mouseUpSub = html.window.onMouseUp.listen(stopDragging);
    _mouseMoveSub = html.window.onMouseMove.listen(drag);

    var h = parent.component.horizontal;
    html.document.body!.style.cursor = h ? 'col-resize' : 'row-resize';

    var a = (this.a!).getBoundingClientRect();
    var b = (this.b!).getBoundingClientRect();

    _size = (h ? (a.width + b.width) : (a.height + b.height)) + 6;
    _start = (h ? a.left : a.top) + 0.0;
    _end = (h ? a.right : a.bottom) + 0.0;

    _dragOffset = (h ? e.client.x : e.client.y) - _end!;

    parent.updateSelf();
  }

  void stopDragging(html.EventOrStubbed e) {
    dragging = false;

    _mouseUpSub?.cancel();
    _mouseMoveSub?.cancel();

    html.document.body!.style.cursor = '';

    parent.updateSelf();
  }
}
