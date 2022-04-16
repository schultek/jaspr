import 'package:jaspr/jaspr.dart';

import '../../components/elements/splitter.dart';

class SplitPair {
  SplitterElement parent;
  DomElement a, b;
  bool dragging;
  int index;

  SplitPair(this.parent, this.index, this.a, this.b, {this.dragging = false});

  void startDragging(dynamic e) {}

  void stopDragging(dynamic e) {}
}
