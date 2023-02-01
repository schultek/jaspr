import 'unit.dart';

abstract class Flex {
  static const Flex auto = _FlexKeyword('auto');
  static const Flex none = _FlexKeyword('none');

  const factory Flex({double? grow, double? shrink, FlexBasis? basis}) = _Flex;

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
  final FlexBasis? basis;

  @override
  Map<String, String> get styles {
    if (grow != null) {
      if (shrink == null && basis == null) {
        return {'flex': grow!.toString()};
      } else if (basis == null) {
        return {'flex': '$grow $shrink'};
      } else if (shrink == null) {
        return {'flex': '$grow ${basis!.value}'};
      }
    } else if (basis != null && shrink == null) {
      return {'flex': basis!.value};
    }
    return {
      if (grow != null) 'flex-grow': grow.toString(),
      if (shrink != null) 'flex-shrink': shrink!.toString(),
      if (basis != null) 'flex-basis': basis!.value,
    };
  }
}

class FlexBasis {
  const FlexBasis._(this.value);

  final String value;

  static const FlexBasis auto = FlexBasis._('auto');

  const factory FlexBasis(Unit value) = _FlexBasis;
}

class _FlexBasis implements FlexBasis {
  const _FlexBasis(this._value);

  final Unit _value;

  @override
  String get value => _value.value;
}

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
