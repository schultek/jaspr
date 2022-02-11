part of framework;

@immutable
abstract class Key {
  @protected
  const Key.empty();
}

abstract class LocalKey extends Key {
  const LocalKey() : super.empty();
}

class ValueKey<T> extends LocalKey {
  const ValueKey(this.value);

  final T value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is ValueKey<T> && other.value == value;
  }

  @override
  int get hashCode => Object.hashAll([runtimeType, value]);

  @override
  String toString() {
    final String valueString = T == String ? "<'$value'>" : '<$value>';

    if (runtimeType == ValueKey<T>) {
      return '[$valueString]';
    }
    return '[$T $valueString]';
  }
}

class UniqueKey extends LocalKey {
  // ignore: prefer_const_constructors_in_immutables
  UniqueKey();

  @override
  String toString() => '[#$hashCode]';
}

@optionalTypeArgs
class GlobalKey<T extends State<StatefulComponent>> extends Key {
  const GlobalKey() : super.empty();

  Element? get _currentElement => AppBinding.instance!._globalKeyRegistry[this];

  BuildContext? get currentContext => _currentElement;

  Component? get currentComponent => _currentElement?.component;

  T? get currentState {
    final Element? element = _currentElement;
    if (element is StatefulElement) {
      final StatefulElement statefulElement = element;
      final State state = statefulElement.state;
      if (state is T) return state;
    }
    return null;
  }
}

class StateKey<T extends State> extends GlobalKey<T> {
  const StateKey({required this.id}) : super();

  final String id;

  void _saveState(dynamic state) {
    AppBinding.instance!._saveState(this, state);
  }

  dynamic _getState() {
    return AppBinding.instance!._getState(this);
  }

  bool _isLoadingState() {
    return AppBinding.instance!.isLoadingState;
  }

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is StateKey<T> && other.id == id;
  }

  @override
  int get hashCode => Object.hashAll([runtimeType, id]);
}
