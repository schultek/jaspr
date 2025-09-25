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
