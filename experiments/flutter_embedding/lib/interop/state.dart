@js.JS()
library state_interop;

import 'package:js/js.dart' as js;

export 'package:js/js.dart' show JS, anonymous;

@js.JS('_state')
external StateInterop? _stateInterop;

@js.JS()
@js.anonymous
class StateInterop {
  external factory StateInterop({dynamic state, void Function()? listener});

  external dynamic state;
  external void Function()? listener;
}

class InteropStateNotifier<T> {

  InteropStateNotifier(T initialState) {
    _interop = _stateInterop ??= StateInterop(state: initialState, listener: null);
    _state = _interop.state;

    var l = _interop.listener;
    _interop.listener = js.allowInterop(() {
      if (_state != _interop.state) {
        _state = _interop.state;
        for (var l in _listeners) {
          l();
        }
      }
      l?.call();
    });
  }

  late StateInterop _interop;
  late T _state;

  T get state => _state;
  set state(T newState) {
    _state = newState;
    for (var l in _listeners) {
      l();
    }

    _interop.state = newState;
    _interop.listener?.call();
  }

  Set<void Function()> _listeners = {};

  void addListener(void Function() l) {
    _listeners.add(l);
  }

  void removeListener(void Function() l) {
    _listeners.remove(l);
  }
}
