/// The `flex-direction` CSS property sets how flex items are placed in the flex container defining the main axis and
/// the direction (normal or reversed).
///
/// Read more: [MDN `flex-direction`](https://developer.mozilla.org/en-US/docs/Web/CSS/flex-direction)
enum FlexDirection {
  /// The flex container's main-axis is defined to be the same as the text direction. The main-start and main-end points
  /// are the same as the content direction.
  row('row'),

  /// Behaves the same as row but the main-start and main-end points are opposite to the content direction.
  rowReverse('row-reverse'),

  /// The flex container's main-axis is the same as the block-axis. The main-start and main-end points are the same as
  /// the before and after points of the writing-mode.
  column('column'),

  /// Behaves the same as column but the main-start and main-end are opposite to the content direction.
  columnReverse('column-reverse'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const FlexDirection(this.value);
}

/// The `flex-wrap` CSS property sets whether flex items are forced onto one line or can wrap onto multiple lines. If
/// wrapping is allowed, it sets the direction that lines are stacked.
///
/// Read more: [MDN `flex-wrap`](https://developer.mozilla.org/en-US/docs/Web/CSS/flex-wrap)
enum FlexWrap {
  /// The flex items are laid out in a single line which may cause the flex container to overflow. The cross-start is
  /// the equivalent of inline-start or block-start, depending on the flex-direction value. This is the default value.
  nowrap('nowrap'),

  /// The flex items break into multiple lines. The cross-start is the equivalent of inline-start or block-start,
  /// depending on the current writing mode, and the flex-direction value.
  wrap('wrap'),

  /// Behaves the same as wrap, but cross-start and cross-end are inverted.
  wrapReverse('wrap-reverse'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const FlexWrap(this.value);
}

/// The CSS `justify-content` property defines how the browser distributes space between and around content items along
/// the main axis of a flex container and the inline axis of grid and multicol containers.
///
/// Read more: [MDN `justify-content`](https://developer.mozilla.org/en-US/docs/Web/CSS/justify-content)
enum JustifyContent {
  /// The items are packed flush to each other toward the center of the alignment container along the main axis.
  center('center'),

  /// The items are packed flush to each other toward the start edge of the alignment container in the main axis.
  start('start'),

  /// The items are packed flush to each other toward the end edge of the alignment container in the main axis.
  end('end'),

  /// The items are packed flush to each other toward the left edge of the alignment container. When the property's
  /// horizontal axis is not parallel with the inline axis, such as when `flex-direction: column` is set, this value
  /// behaves like [start].
  left('left'),

  /// The items are packed flush to each other toward the right edge of the alignment container in the appropriate axis.
  /// If the property's axis is not parallel with the inline axis (in a grid container) or the main-axis (in a flexbox
  /// container), this value behaves like [start].
  right('right'),

  /// Behaves as [stretch], except in the case of multi-column containers with a non-auto column-width, in which case
  /// the columns take their specified column-width rather than stretching to fill the container. As stretch behaves as
  /// [start] in flex containers, normal also behaves as [start].
  normal('normal'),

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair
  /// of adjacent items is the same. The first item is flush with the main-start edge, and the last item is flush with
  /// the main-end edge.
  spaceBetween('space-between'),

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair
  /// of adjacent items is the same. The empty space before the first and after the last item equals half of the space
  /// between each pair of adjacent items. If there is only one item, it will be centered.
  spaceAround('space-around'),

  /// The items are evenly distributed within the alignment container along the main axis. The spacing between each pair
  /// of adjacent items, the main-start edge and the first item, and the main-end edge and the last item, are all exactly
  /// the same.
  spaceEvenly('space-evenly'),

  /// If the combined size of the items along the main axis is less than the size of the alignment container, any auto-sized
  /// items have their size increased equally (not proportionally), while still respecting the constraints imposed by
  /// max-height/max-width (or equivalent functionality), so that the combined size exactly fills the alignment container
  /// along the main axis.
  stretch('stretch'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const JustifyContent(this.value);
}

/// The CSS `align-items` property sets the align-self value on all direct children as a group. In flexbox, it controls
/// the alignment of items on the cross axis. In grid layout, it controls the alignment of items on the block axis within
/// their grid areas.
///
/// Read more: [MDN `align-items`](https://developer.mozilla.org/en-US/docs/Web/CSS/align-items)
enum AlignItems {
  /// The effect of this keyword is dependent of the layout mode we are in:
  ///
  /// - In absolutely-positioned layouts, the keyword behaves like [start] on replaced absolutely-positioned boxes, and as
  ///   [stretch] on all other absolutely-positioned boxes.
  /// - In static position of absolutely-positioned layouts, the keyword behaves as [stretch].
  /// - For flex items, the keyword behaves as [stretch].
  /// - For grid items, this keyword leads to a behavior similar to the one of [stretch], except for boxes with an aspect
  ///   ratio or an intrinsic size where it behaves like [start].
  /// - The property doesn't apply to block-level boxes, and to table cells.
  normal('normal'),

  /// If the item's cross-size is auto, the used size is set to the length necessary to be as close to filling the
  /// container as possible, respecting the item's width and height limits. If the item is not auto-sized, this value
  /// falls back to flex-start, and to self-start or self-end if the container's align-content is first baseline
  /// (or baseline) or last baseline.
  stretch('stretch'),

  /// The flex items' margin boxes are centered within the line on the cross-axis. If the cross-size of an item is larger
  /// than the flex container, it will overflow equally in both directions.
  center('center'),

  /// The items are packed flush to each other toward the start edge of the alignment container in the appropriate axis.
  start('start'),

  /// The items are packed flush to each other toward the end edge of the alignment container in the appropriate axis.
  end('end'),

  /// All flex items are aligned such that their flex container baselines align. The item with the largest distance
  /// between its cross-start margin edge and its baseline is flushed with the cross-start edge of the line.
  baseline('baseline'),

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const AlignItems(this.value);
}

/// The CSS `align-content` property sets the distribution of space between and around content items along a flexbox's
/// cross axis, or a grid or block-level element's block axis.
///
/// Read more: [MDN `align-content`](https://developer.mozilla.org/en-US/docs/Web/CSS/align-content)
enum AlignContent {
  // The items are packed in their default position as if no align-content value was set.
  normal('normal'),

  /// The items are packed flush to each other against the start edge of the alignment container in the cross axis.
  start('start'),

  /// The items are packed flush to each other in the center of the alignment container along the cross axis.
  center('center'),

  /// The items are packed flush to each other against the end edge of the alignment container in the cross axis.
  end('end'),

  /// The items are packed flush to each other against the edge of the alignment container depending on the flex
  /// container's cross-start side. This only applies to flex layout items. For items that are not children of a flex
  /// container, this value is treated like [start].
  flexStart('flex-start'),

  /// The items are packed flush to each other against the edge of the alignment container depending on the flex
  /// container's cross-end side. This only applies to flex layout items. For items that are not children of a flex
  /// container, this value is treated like [end].
  flexEnd('flex-end'),

  /// The items are evenly distributed within the alignment container along the cross axis. The spacing between each
  /// pair of adjacent items is the same. The first item is flush with the start edge of the alignment container in the
  /// cross axis, and the last item is flush with the end edge of the alignment container in the cross axis.
  spaceBetween('space-between'),

  /// The items are evenly distributed within the alignment container along the cross axis. The spacing between each
  /// pair of adjacent items is the same. The empty space before the first and after the last item equals half of the
  /// space between each pair of adjacent items.
  spaceAround('space-around'),

  /// The items are evenly distributed within the alignment container along the cross axis. The spacing between each
  /// pair of adjacent items, the start edge and the first item, and the end edge and the last item, are all exactly the
  /// same.
  spaceEvenly('space-evenly'),

  /// If the combined size of the items along the cross axis is less than the size of the alignment container, any
  /// auto-sized items have their size increased equally (not proportionally), while still respecting the constraints
  /// imposed by max-height/max-width (or equivalent functionality), so that the combined size exactly fills the alignment
  /// container along the cross axis.
  stretch('stretch'),

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
  const AlignContent(this.value);
}
