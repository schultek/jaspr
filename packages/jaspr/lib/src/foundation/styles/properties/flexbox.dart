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

  const FlexDirection(this.value);

  /// The css value
  final String value;
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

  const FlexWrap(this.value);

  /// The css value
  final String value;
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
  spaceRvenly('space-evenly'),
  stretch('stretch'),
  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  const JustifyContent(this.value);

  /// The css value
  final String value;
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

  const AlignItems(this.value);

  /// The css value
  final String value;
}
