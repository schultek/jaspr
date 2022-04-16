import 'dart:async';
import 'dart:html';

import 'package:jaspr/jaspr.dart' hide Element;

import '../../components/elements/splitter.dart';

class SplitPair {
  SplitterElement parent;
  DomElement a, b;
  bool dragging;
  int index;

  double? _size;
  double? _start;
  double? _end;
  double? _dragOffset;

  SplitPair(this.parent, this.index, this.a, this.b, {this.dragging = false});

  void drag(Event e) {
    if (!dragging || e is! MouseEvent) return;

    var h = parent.component.horizontal;

    var offset = (h ? e.client.x : e.client.y) - _start! + (3 - _dragOffset!);

    parent.adjustSizes(offset / _size!, index);
  }

  StreamSubscription? _mouseUpSub, _mouseMoveSub;

  void startDragging(MouseEvent e) {
    // Right-clicking can't start dragging.
    if (e.button != 0) {
      return;
    }

    e.preventDefault();

    dragging = true;
    _mouseUpSub = window.onMouseUp.listen(stopDragging);
    _mouseMoveSub = window.onMouseMove.listen(drag);

    var h = parent.component.horizontal;
    document.body!.style.cursor = h ? 'col-resize' : 'row-resize';

    var a = (this.a.source as Element).getBoundingClientRect();
    var b = (this.b.source as Element).getBoundingClientRect();

    _size = (h ? (a.width + b.width) : (a.height + b.height)) + 6;
    _start = (h ? a.left : a.top) + 0.0;
    _end = (h ? a.right : a.bottom) + 0.0;

    _dragOffset = (h ? e.client.x : e.client.y) - _end!;

    parent.invalidateSelf();
  }

  void stopDragging(Event e) {
    dragging = false;

    _mouseUpSub?.cancel();
    _mouseMoveSub?.cancel();

    document.body!.style.cursor = '';

    parent.invalidateSelf();
  }
}
