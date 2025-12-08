/// Describes where a grid item should be placed within a grid. It can
/// place an item by naming a grid area, or by describing start/end lines
/// for the item's row and column tracks. Use this to control the item's
/// location and span inside its grid.
///
/// Maps to the CSS `grid-area`, `grid-row`, and `grid-column` properties.
///
/// Read more: [MDN Grid Placement](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_grid_layout/Grid_layout_using_line-based_placement)
abstract class GridPlacement {
  /// Creates a placement that targets a named grid area.
  const factory GridPlacement.area(String name) = _GridPlacement;

  /// A placement that leaves the item's position to automatic placement
  /// (equivalent to using the browser's automatic grid placement).
  static const GridPlacement auto = _GridPlacement('auto');

  /// Creates a placement by specifying start/end lines for rows and
  /// columns using [LinePlacement] values.
  const factory GridPlacement({
    LinePlacement? rowStart,
    LinePlacement? rowEnd,
    LinePlacement? columnStart,
    LinePlacement? columnEnd,
  }) = _LineGridPlacement;

  Map<String, String> get styles;
}

class _GridPlacement implements GridPlacement {
  const _GridPlacement(this.value);

  final String value;

  @override
  Map<String, String> get styles => {'grid-area': value};
}

class _LineGridPlacement implements GridPlacement {
  const _LineGridPlacement({this.rowStart, this.rowEnd, this.columnStart, this.columnEnd});

  final LinePlacement? rowStart;
  final LinePlacement? rowEnd;
  final LinePlacement? columnStart;
  final LinePlacement? columnEnd;

  @override
  Map<String, String> get styles {
    if (rowStart != null && columnStart != null && (rowEnd != null || columnEnd == null)) {
      return {
        'grid-area': [
          rowStart!.value,
          columnStart!.value,
          if (rowEnd != null) rowEnd!.value,
          if (columnEnd != null) columnEnd!.value,
        ].join(' / '),
      };
    } else {
      return {
        if (rowStart != null)
          'grid-row': [rowStart!.value, if (rowEnd != null) rowEnd!.value].join(' / ')
        else if (rowEnd != null)
          'grid-row-end': rowEnd!.value,
        if (columnStart != null)
          'grid-column': [columnStart!.value, if (columnEnd != null) columnEnd!.value].join(' / ')
        else if (columnEnd != null)
          'grid-column-end': columnEnd!.value,
      };
    }
  }
}

/// Places an item by specifying grid lines or spans.
///
/// A line placement identifies a grid line by name or index,
/// or describes a span across multiple tracks. It's used to indicate
/// where a grid item should start or end on a row or column axis.
class LinePlacement {
  const LinePlacement._(this.value);

  final String value;

  /// The automatic placement value.
  static const LinePlacement auto = LinePlacement._('auto');

  /// Creates a placement that targets a named grid line.
  const factory LinePlacement.named(String name) = _NamedLinePlacement;

  /// Creates a placement by numeric line index. Optionally provide
  /// a [lineName] to also include a named line.
  const factory LinePlacement(int index, {String? lineName}) = _NormalLinePlacement;

  /// Creates a placement using a `span` expression to span multiple
  /// tracks. An optional [lineName] may be provided.
  const factory LinePlacement.span(int span, {String? lineName}) = _SpanLinePlacement;
}

class _LinePlacement implements LinePlacement {
  const _LinePlacement({this.number, this.span = false, this.lineName})
    : assert(
        span || number != null || lineName != null,
        'At least one of span, number or lineName must be set. Otherwise, use LinePlacement.auto',
      );

  final int? number;
  final bool span;
  final String? lineName;

  @override
  String get value => [
    if (span) 'span',
    ?number,
    ?lineName,
  ].join(' ');
}

class _NamedLinePlacement extends _LinePlacement {
  const _NamedLinePlacement(String name) : super(lineName: name);
}

class _NormalLinePlacement extends _LinePlacement {
  const _NormalLinePlacement(int index, {super.lineName}) : super(number: index);
}

class _SpanLinePlacement extends _LinePlacement {
  const _SpanLinePlacement(int span, {super.lineName}) : super(span: true, number: span);
}

/// The CSS `justify-self` property sets the way a box is justified inside its alignment container along the appropriate axis.
enum JustifySelf {
  /// The value used is the value of the justify-items property of the parents box, unless the box has no parent, or is
  /// absolutely positioned, in these cases, [auto] represents [normal].
  auto('auto'),

  /// The effect of this keyword is dependent of the layout mode we are in:
  ///
  /// - In block-level layouts, the keyword is a synonym of [start].
  /// - In absolutely-positioned layouts, the keyword behaves like [start] on replaced absolutely-positioned boxes, and
  ///   as [stretch] on all other absolutely-positioned boxes.
  /// - In table cell layouts, this keyword has no meaning as this property is ignored.
  /// - In flexbox layouts, this keyword has no meaning as this property is ignored.
  /// - In grid layouts, this keyword leads to a behavior similar to the one of [stretch], except for boxes with an
  ///   aspect ratio or an intrinsic size where it behaves like [start].
  normal('normal'),

  /// If the combined size of the items is less than the size of the alignment container, any auto-sized items have their
  /// size increased equally (not proportionally), while still respecting the constraints imposed by max-height/max-width
  /// (or equivalent functionality), so that the combined size exactly fills the alignment container.
  stretch('stretch'),

  /// The items are packed flush to each other toward the center of the alignment container.
  center('center'),

  /// The item is packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start('start'),

  /// The item is packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end('end'),

  /// For items that are not children of a flex container, this value is treated like [start].
  flexStart('flex-start'),

  /// For items that are not children of a flex container, this value is treated like [end].
  flexEnd('flex-end'),

  /// The item is packed flush to the edge of the alignment container of the start side of the item, in the
  /// appropriate axis.
  selfStart('self-start'),

  /// The item is packed flush to the edge of the alignment container of the end side of the item, in the
  /// appropriate axis.
  selfEnd('self-end'),

  /// The items are packed flush to each other toward the left edge of the alignment container. If the property's axis
  /// is not parallel with the inline axis, this value behaves like [start].
  left('left'),

  /// The items are packed flush to each other toward the right edge of the alignment container in the appropriate axis.
  /// If the property's axis is not parallel with the inline axis, this value behaves like [start].
  right('right'),

  /// In the case of anchor-positioned elements, aligns the item to the center of the associated anchor element in the
  /// inline direction.
  anchorCenter('anchor-center'),

  /// Specifies participation in baseline alignment: aligns the alignment baseline of the box's baseline set with the
  /// corresponding baseline in the shared baseline set of all the boxes in its baseline-sharing group.
  baseline('baseline'),

  /// Specifies participation in first-baseline alignment: aligns the alignment baseline of the box's first baseline set
  /// with the corresponding baseline in the shared first baseline set of all the boxes in its baseline-sharing group.
  /// The fallback alignment is [start].
  firstBaseline('first baseline'),

  /// Specifies participation in last-baseline alignment: aligns the alignment baseline of the box's last baseline set
  /// with the corresponding baseline in the shared last baseline set of all the boxes in its baseline-sharing group.
  /// The fallback alignment is [end].
  lastBaseline('last baseline'),

  // Overflow alignment
  safeCenter('safe center'),
  unsafeCenter('unsafe center'),

  // Global values
  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const JustifySelf(this.value);
}
