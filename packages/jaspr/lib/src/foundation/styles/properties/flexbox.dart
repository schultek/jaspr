
/// Represents the CSS `flex-direction` property.
///
/// Controls the direction in which flex items are laid out in a flex
/// container. Use values like `row`, `column`, and their `-reverse` variants
/// when constructing flex container styles.
enum FlexDirection {
  row('row'),
  rowReverse('row-reverse'),
  column('column'),
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

/// Represents the CSS `flex-wrap` property.
///
/// Controls whether flex items wrap onto multiple lines (`wrap`) or are
/// kept on a single line (`nowrap`). Use in combination with [FlexDirection]
/// to configure a flex container.
enum FlexWrap {
  nowrap('nowrap'),
  wrap('wrap'),
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

/// Represents the CSS `justify-content` property for flex containers.
///
/// Defines alignment along the main axis. Use values like `center`,
/// `space-between`, or `space-evenly` to distribute free space.
enum JustifyContent {
  center('center'),
  start('start'),
  end('end'),
  left('left'),
  right('right'),
  normal('normal'),
  spaceBetween('space-between'),
  spaceAround('space-around'),
  spaceEvenly('space-evenly'),
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

/// Represents the CSS `align-items` property for flex containers.
///
/// Controls default alignment for items along the cross axis. Use values
/// such as `stretch`, `center`, or `baseline`.
enum AlignItems {
  normal('normal'),
  stretch('stretch'),
  center('center'),
  start('start'),
  end('end'),
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

/// Represents the CSS `align-content` property for multi-line flex containers.
///
/// Controls distribution of lines when there is extra space in the cross
/// axis. Use values like `space-between`, `stretch`, or `center`.
enum AlignContent {
  // Normal alignment
  normal('normal'),

  // Basic positional alignment
  start('start'),
  center('center'),
  end('end'),
  flexStart('flex-start'),
  flexEnd('flex-end'),

  // Distributed alignment
  spaceBetween('space-between'),
  spaceAround('space-around'),
  spaceEvenly('space-evenly'),
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
