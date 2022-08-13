import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../../adapters/html.dart' as html;

class Splitter extends StatefulComponent {
  const Splitter({required this.children, this.horizontal = true, this.initialSizes, Key? key}) : super(key: key);

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
        yield DomComponent(
          tag: 'div',
          classes: ['gutter', 'gutter-${component.horizontal ? 'horizontal' : 'vertical'}'],
          styles: {'flex-basis': '6px'},
          events: {'mousedown': (e) => pair.startDragging(e)},
        );
      }

      var dragging =
          (i > 0 ? splitPairs[i - 1].dragging : false) || (i < splitPairs.length ? splitPairs[i].dragging : false);

      yield RenderScope(
        delegate: SplitElementRenderDelegate(
          size: sizes[i],
          dragging: dragging,
          onNode: (node) {
            if (i > 0) splitPairs[i - 1].b = node;
            if (i < splitPairs.length) splitPairs[i].a = node;
          },
        ),
        child: component.children[i],
      );
    }
  }
}

class SplitElementRenderDelegate extends RenderDelegate {
  SplitElementRenderDelegate({required this.size, required this.dragging, required this.onNode});

  final double size;
  final bool dragging;
  final void Function(RenderElement) onNode;

  @override
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    styles = {
      ...?styles,
      'flex-basis': 'calc($size% - 3px)',
      if (dragging) ...{
        'user-select': 'none',
        'pointer-events': 'none',
      }
    };
    super.renderNode(node, tag, id, classes, styles, attributes, events);
    onNode(node);
  }

  @override
  bool updateShouldNotify(covariant SplitElementRenderDelegate oldDelegate) {
    return size != oldDelegate.size || dragging != oldDelegate.dragging;
  }
}

class SplitPair {
  SplitterState parent;
  RenderElement? a, b;
  bool dragging;
  int index;

  double? _size;
  double? _start;
  double? _end;
  double? _dragOffset;

  SplitPair(this.parent, this.index, {this.dragging = false});

  void drag(html.Event e) {
    if (!dragging) return;
    if (e is! html.MouseEvent) return;

    var h = parent.component.horizontal;

    var offset = (h ? e.client.x : e.client.y) - _start! + (3 - _dragOffset!);

    parent.adjustSizes(offset / _size!, index);
  }

  StreamSubscription? _mouseUpSub, _mouseMoveSub;

  void startDragging(html.MouseEvent e) {
    // Right-clicking can't start dragging.
    if (e.button != 0) {
      return;
    }

    print("START DRAG ${this.a} ${this.b}");

    if (this.a == null || this.b == null) {
      return;
    }

    e.preventDefault();

    dragging = true;
    _mouseUpSub = html.window.onMouseUp.listen(stopDragging);
    _mouseMoveSub = html.window.onMouseMove.listen(drag);

    var h = parent.component.horizontal;
    html.document.body!.style.cursor = h ? 'col-resize' : 'row-resize';

    var a = (this.a!.nativeElement).getBoundingClientRect();
    var b = (this.b!.nativeElement).getBoundingClientRect();

    _size = (h ? (a.width + b.width) : (a.height + b.height)) + 6;
    _start = (h ? a.left : a.top) + 0.0;
    _end = (h ? a.right : a.bottom) + 0.0;

    _dragOffset = (h ? e.client.x : e.client.y) - _end!;

    parent.updateSelf();
  }

  void stopDragging(html.Event e) {
    dragging = false;

    _mouseUpSub?.cancel();
    _mouseMoveSub?.cancel();

    html.document.body!.style.cursor = '';

    parent.updateSelf();
  }
}
