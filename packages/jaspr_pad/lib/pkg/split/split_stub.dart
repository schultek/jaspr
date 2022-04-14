class Splitter {
  external void setSizes(List sizes);

  external List getSizes();

  external void collapse(int indexToCollapse);

  external void destroy([bool? preserveStyles, bool? preserveGutters]);
}

Splitter flexSplit(
  List<dynamic> parts, {
  bool horizontal = true,
  num gutterSize = 5,
  List<num>? sizes,
  List<num>? minSize,
  void Function(dynamic size, dynamic index)? onChange,
}) =>
    Splitter();

/// Splitter that splits multiple elements that must have a parent of fixed
/// size.
///
/// You should used this fixed splitter instead of flex splitter when the parent
/// of the elements being split has a fixed size but one or more of the children
/// may have arbitrary size resulting in flex-shrink causing problems for the
/// flex calculations.
/// https://developer.mozilla.org/en-US/docs/Web/CSS/flex-shrink
///
/// The underlying split.js library supports splitting elements that use layout
/// schemes other than flexbox but we don't need that flexibility.
Splitter fixedSplit(
  List<dynamic> parts, {
  bool horizontal = true,
  num gutterSize = 5,
  List<num>? sizes,
  List<num>? minSize,
}) =>
    Splitter();
