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

@optionalTypeArgs
class GlobalObjectKey<T extends State<StatefulComponent>> extends GlobalKey<T> {
  /// Creates a global key that uses [identical] on [value] for its [operator==].
  const GlobalObjectKey(this.value) : super();

  /// The object whose identity is used by this key's [operator==].
  final Object value;

  @override
  bool operator ==(Object other) {
    return other.runtimeType == runtimeType && other is GlobalObjectKey<T> && identical(other.value, value);
  }

  @override
  int get hashCode => identityHashCode(value);
}

extension _SyncKey on GlobalKey {
  bool get _canSync {
    var state = currentState;
    return state != null && state is SyncStateMixin;
  }

  SyncStateMixin get _currentState => currentState as SyncStateMixin;

  String get _id => _currentState.syncId;

  void _notifyState(String? state) {
    if (!_canSync) return;
    var s = _currentState;
    s.updateState(state != null ? s.syncCodec.decode(state) : null);
  }

  String _saveState() {
    var s = _currentState;
    return s.syncCodec.encode(s.saveState());
  }
}
