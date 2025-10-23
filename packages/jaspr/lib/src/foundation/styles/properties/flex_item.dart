import 'unit.dart';

/// Controls how a flex item consumes available space inside a flex container.
///
/// This maps to the CSS `flex` property and related properties like `flex-grow`, 
/// `flex-shrink`, and `flex-basis`.
abstract class Flex {
  /// The item can grow and shrink, and uses its base size.
  static const Flex auto = _FlexKeyword('auto');
  /// The item is inflexible and uses its base size.
  static const Flex none = _FlexKeyword('none');

  /// Create a flex value from grow/shrink/basis components.
  const factory Flex({double? grow, double? shrink, Unit? basis}) = _Flex;

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

/// Overrides a container's `align-items` for a single flex/grid item.
///
/// The `align-self` property controls how this item is aligned on the cross
/// axis (the axis perpendicular to the flex container's main axis). Typical
/// values include `start`, `center`, `end`, and `stretch`. In CSS Grid it
/// instead aligns the item inside its grid area on the cross axis.
enum AlignSelf {
  auto('auto'),
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
  const AlignSelf(this.value);
}
