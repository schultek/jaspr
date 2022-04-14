// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Thin JS interop wrapper around https://split.js.org/
@JS()
library splitter;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

typedef _ElementStyleCallback = Function(Object? dimension, Object? size, num? gutterSize, [int? index]);
typedef _GutterStyleCallback = Function(Object? dimension, num? gutterSize, int? index);

@JS()
@anonymous
class _SplitOptions {
  external factory _SplitOptions({
    _ElementStyleCallback? elementStyle,
    _GutterStyleCallback? gutterStyle,
    String? direction,
    num? gutterSize,
    List<num>? sizes,
    List<num>? minSize,
    bool? expandToMin,
  });

  external _ElementStyleCallback get elementStyle;

  external _GutterStyleCallback get gutterStyle;

  external String get direction;

  external num get gutterSize;

  external List<num> get sizes;

  external List<num> get minSize;

  /// Whether to use the [minSize] property.
  external bool get expandToMin;
}

@JS('Split')
external Splitter _split(List parts, _SplitOptions options);

typedef _SplitterBuilder = Splitter Function(
  List<Element> parts, {
  required bool horizontal,
  required num gutterSize,
  required List<num>? sizes,
  required List<num>? minSize,
});

@JS()
@anonymous
class Splitter {
  external void setSizes(List sizes);

  external List getSizes();

  external void collapse(int indexToCollapse);

  external void destroy([bool? preserveStyles, bool? preserveGutters]);
}

bool _isAttachedToDocument(Element element) => element.isConnected!;

/// Splitter that splits multiple elements using flex layout.
///
/// You should used this flex splitter instead of the fixed splitter if the
/// size of the parent element of the element being split isn't fixed. Keep in
/// mind that the children being split must be sized such that flex-shrink does
/// not apply as otherwise flex-shrink will interact badly with the calculation
/// for the size of the two split regions.
/// https://developer.mozilla.org/en-US/docs/Web/CSS/flex-shrink
///
/// The underlying split.js library supports splitting elements that use layout
/// schemes other than flexbox but we don't need that flexibility.
Splitter flexSplit(
  List parts, {
  bool horizontal = true,
  num gutterSize = 5,
  List<num>? sizes,
  List<num>? minSize,
  void Function(dynamic size, dynamic index)? onChange,
}) {
  // The splitter library will generate nonsense split percentages if called
  // on elements that are not yet attached to the document.
  assert(parts.every((e) => _isAttachedToDocument(e)));

  return _split(
    parts,
    _SplitOptions(
      elementStyle: allowInterop((dimension, size, gutterSize, [int? index]) {
        onChange?.call(size, index);
        return js_util.jsify({
          'flex-basis': 'calc($size% - ${gutterSize}px)',
        });
      }),
      gutterStyle: allowInterop((dimension, gutterSize, index) {
        return js_util.jsify({
          'flex-basis': '${gutterSize}px',
        });
      }),
      direction: horizontal ? 'horizontal' : 'vertical',
      gutterSize: gutterSize,
      sizes: sizes,
      minSize: minSize,
      expandToMin: minSize?.isNotEmpty ?? false,
    ),
  );
}

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
  List<Element> parts, {
  bool horizontal = true,
  num gutterSize = 5,
  List<num>? sizes,
  List<num>? minSize,
}) {
  // The splitter library will generate nonsense split percentages if called
  // on elements that are not yet attached to the document.
  assert(parts.every(_isAttachedToDocument as bool Function(Element)));

  return _split(
    parts,
    _SplitOptions(
      elementStyle: allowInterop((dimension, size, gutterSize, [int? index]) {
        final Object o = js_util.newObject() as Object;
        js_util.setProperty(
          o,
          horizontal ? 'width' : 'height',
          'calc($size% - ${gutterSize}px)',
        );
        js_util.setProperty(
          o,
          horizontal ? 'height' : 'width',
          '100%',
        );
        return o;
      }),
      gutterStyle: allowInterop((dimension, gutterSize, index) {
        final Object o = js_util.newObject() as Object;
        js_util.setProperty(
          o,
          horizontal ? 'width' : 'height',
          '${gutterSize}px',
        );
        js_util.setProperty(
          o,
          horizontal ? 'height' : 'width',
          '100%',
        );
        return o;
      }),
      direction: horizontal ? 'horizontal' : 'vertical',
      gutterSize: gutterSize,
      sizes: sizes,
      minSize: minSize,
      expandToMin: minSize?.isNotEmpty ?? false,
    ),
  );
}

StreamSubscription<Object> _splitBidirectional(
  List<Element> parts, {
  required num gutterSize,
  required List<num>? verticalSizes,
  required List<num>? horizontalSizes,
  required List<num>? minSize,
  required _SplitterBuilder splitterBuilder,
}) {
  final mediaQueryList = window.matchMedia('(min-aspect-ratio: 1/1)');
  late Splitter splitter;
  // TODO(jacobr): cache the vertical or horizontal split and restore the value
  // when the aspect ratio changes back.
  void createSplitter() {
    final bool horizontal = mediaQueryList.matches;
    splitter = splitterBuilder(parts,
        horizontal: horizontal,
        gutterSize: gutterSize,
        minSize: minSize,
        sizes: horizontal ? horizontalSizes : verticalSizes);
  }

  createSplitter();
  return mediaQueryList.onChange.listen((e) {
    splitter.destroy(true, false);
    createSplitter();
  });
}

/// Creates a flex splitter that changes from horizontal to vertical depending
/// on the window aspect ratio.
///
/// You should used this flex splitter instead of the fixed splitter if the
/// size of the parent element of the element being split isn't fixed. Keep in
/// mind that the children being split must be sized such that flex-shrink does
/// not apply as otherwise flex-shrink will interact badly with the calculation
/// for the size of the two split regions.
/// https://developer.mozilla.org/en-US/docs/Web/CSS/flex-shrink
///
/// To avoid memory leaks, cancel the stream subscription when the splitter is
/// no longer being used.
StreamSubscription<Object> flexSplitBidirectional(
  List<Element> parts, {
  num gutterSize = 5,
  List<num>? verticalSizes,
  List<num>? horizontalSizes,
  List<num>? minSize,
}) {
  return _splitBidirectional(
    parts,
    gutterSize: gutterSize,
    verticalSizes: verticalSizes,
    horizontalSizes: horizontalSizes,
    minSize: minSize,
    splitterBuilder: flexSplit,
  );
}

/// Creates a fixed splitter that changes from horizontal to vertical depending
/// on the window aspect ratio.
///
/// You should used this fixed splitter instead of flex splitter when the parent
/// of the elements being split has a fixed size but one or more of the children
/// may have arbitrary size resulting in flex-shrink causing problems for the
/// flex calculations.
/// https://developer.mozilla.org/en-US/docs/Web/CSS/flex-shrink
///
/// To avoid memory leaks, cancel the stream subscription when the splitter is
/// no longer being used.
StreamSubscription<Object> fixedSplitBidirectional(
  List<Element> parts, {
  num gutterSize = 5,
  List<num>? verticalSizes,
  List<num>? horizontalSizes,
  List<num>? minSize,
}) {
  return _splitBidirectional(
    parts,
    gutterSize: gutterSize,
    verticalSizes: verticalSizes,
    horizontalSizes: horizontalSizes,
    minSize: minSize,
    splitterBuilder: fixedSplit,
  );
}
