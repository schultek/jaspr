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
  spaceRvenly('space-evenly'),
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
