import 'package:jaspr/jaspr.dart' as jaspr;
import 'package:mobx/mobx.dart' as mobx;

class Obs<T>
    with
        jaspr.ChangeNotifier
    implements
        // mobx.Interceptable<T>,
        mobx.Listenable<mobx.ChangeNotification<T>>,
        mobx.ObservableValue<T>,
        jaspr.ValueListenable<T> {
  Obs(
    this._value, {
    this.equals,
    String? name,
    mobx.ReactiveContext? context,
  }) :
        // _listeners = mobx.Listeners(context ?? mobx.mainContext),
        // _interceptors = mobx.Interceptors(context ?? mobx.mainContext),
        _atom = mobx.Atom(name: name, context: context);

  // final mobx.Interceptors<T> _interceptors;
  // final mobx.Listeners<mobx.ChangeNotification<T>> _listeners;

  // @override
  // mobx.Dispose intercept(mobx.Interceptor<T> interceptor) {
  //   return _interceptors.add(interceptor);
  // }

  final mobx.Atom _atom;
  final mobx.EqualityComparer<T>? equals;
  mobx.ChangeNotification<T>? lastNotification;
  T _value;

  String get name => _atom.name;

  @override
  T get value {
    _atom.reportObserved();
    return _value;
  }

  set value(T v) {
    if (equals == null ? _value == v : equals!(_value, v)) return;
    lastNotification = mobx.ChangeNotification(
      newValue: v,
      oldValue: _value,
      type: mobx.OperationType.update,
      object: this,
    );
    _atom.reportWrite(v, _value, () {
      _value = v;
    });
    notifyListeners();
  }

  T get() => value;

  void set(T v) {
    value = v;
  }

  @override
  mobx.Dispose observe(
    mobx.Listener<mobx.ChangeNotification<T>> listener, {
    bool fireImmediately = false,
  }) {
    if (fireImmediately) {
      listener(
        mobx.ChangeNotification<T>(
          type: mobx.OperationType.update,
          newValue: _value,
          oldValue: null,
          object: this,
        ),
      );
    }

    void _callback() {
      listener(lastNotification!);
    }

    addListener(_callback);
    return () {
      removeListener(_callback);
    };
  }

  @override
  String toString() {
    return 'Obs(name: "$name", equals: $equals, ${(_value)},'
        ' previousValue: ${lastNotification == null ? '' : lastNotification!.oldValue},'
        ' hasListeners: $hasListeners,'
        ' hasObservers: ${_atom.hasObservers})';
  }
}
