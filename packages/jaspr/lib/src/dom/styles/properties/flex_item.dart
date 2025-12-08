import 'unit.dart';

/// Controls how a flex item consumes available space inside a flex container.
///
/// This maps to the CSS `flex` property and related properties like `flex-grow`,
/// `flex-shrink`, and `flex-basis`.
///
/// Read more: [MDN Flex Item](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_flexible_box_layout/Controlling_ratios_of_flex_items_along_the_main_axis)
abstract class Flex {
  /// The item can grow and shrink, and uses its base size.
  static const Flex auto = _FlexKeyword('auto');

  /// The item is inflexible and uses its base size.
  static const Flex none = _FlexKeyword('none');

  /// Create a flex value from grow/shrink/basis components.
  const factory Flex({double? grow, double? shrink, Unit? basis}) = _Flex;

  /// Create a flex value with the given [grow] factor.
  const factory Flex.grow(double grow) = _Flex.grow;

  /// Create a flex value with the given [shrink] factor.
  const factory Flex.shrink(double shrink) = _Flex.shrink;

  /// Create a flex value with the given [basis].
  const factory Flex.basis(Unit basis) = _Flex.basis;

  static const Flex inherit = _FlexKeyword('inherit');
  static const Flex initial = _FlexKeyword('initial');
  static const Flex revert = _FlexKeyword('revert');
  static const Flex revertLayer = _FlexKeyword('revert-layer');
  static const Flex unset = _FlexKeyword('unset');

  Map<String, String> get styles;
}

class _FlexKeyword implements Flex {
  const _FlexKeyword(this.value);

  final String value;

  @override
  Map<String, String> get styles => {'flex': value};
}

class _Flex implements Flex {
  const _Flex({this.grow, this.shrink, this.basis});

  const _Flex.grow(this.grow) : shrink = null, basis = null;

  const _Flex.shrink(this.shrink) : grow = null, basis = null;

  const _Flex.basis(this.basis) : grow = null, shrink = null;

  final double? grow;
  final double? shrink;
  final Unit? basis;

  @override
  Map<String, String> get styles {
    return {
      'flex-grow': ?grow?.numstr,
      'flex-shrink': ?shrink?.numstr,
      'flex-basis': ?basis?.value,
    };
  }
}

/// The `align-self` CSS property overrides a grid or flex item's align-items value. In grid, it aligns the item inside
/// the grid area. In flexbox, it aligns the item on the cross axis.
///
/// Read more: [MDN Align Self](https://developer.mozilla.org/en-US/docs/Web/CSS/align-self)
enum AlignSelf {
  /// Computes to the parent's align-items value.
  auto('auto'),

  /// The effect of this keyword is dependent of the layout mode we are in:
  ///
  /// - In absolutely-positioned layouts, the keyword behaves like [start] on replaced absolutely-positioned boxes, and
  ///   as [stretch] on all other absolutely-positioned boxes.
  /// - In static position of absolutely-positioned layouts, the keyword behaves as [stretch].
  /// - For flex items, the keyword behaves as [stretch].
  /// - For grid items, this keyword leads to a behavior similar to the one of [stretch], except for boxes with an aspect
  ///   ratio or an intrinsic size where it behaves like [start].
  /// - The property doesn't apply to block-level boxes, and to table cells.
  normal('normal'),

  /// If the item's cross-size is auto, the used size is set to the length necessary to be as close to filling the
  /// container as possible, respecting the item's width and height limits. If the item is not auto-sized, this value
  /// falls back to [flexStart], and to [selfStart] or [selfEnd] if the container's align-content is first baseline (or
  /// baseline) or last baseline.
  stretch('stretch'),

  /// The flex item's margin box is centered within the line on the cross-axis. If the cross-size of the item is larger
  /// than the flex container, it will overflow equally in both directions.
  center('center'),

  /// The cross-start margin edge of the item is flushed with the cross-start edge of the line.
  start('start'),

  /// The cross-end margin edge of the item is flushed with the cross-end edge of the line.
  end('end'),

  /// The cross-start margin edge of the flex item is flushed with the cross-start edge of the line.
  flexStart('flex-start'),

  /// The cross-end margin edge of the flex item is flushed with the cross-end edge of the line.
  flexEnd('flex-end'),

  /// Aligns the items to be flush with the edge of the alignment container corresponding to the item's start side in
  /// the cross axis.
  selfStart('self-start'),

  /// Aligns the items to be flush with the edge of the alignment container corresponding to the item's end side in the
  /// cross axis.
  selfEnd('self-end'),

  /// In the case of anchor-positioned elements, aligns the item to the center of the associated anchor element in the
  /// block direction. See Centering on the anchor using anchor-center.
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

  inherit('inherit'),
  initial('initial'),
  revert('revert'),
  revertLayer('revert-layer'),
  unset('unset');

  /// The css value
  final String value;
  const AlignSelf(this.value);
}
