@js.JS()
library state_interop;

import 'package:js/js.dart' as js;
import 'package:riverpod/riverpod.dart';

/// A static js property where the shared state will be stored.
@js.JS('_state')
external StateInterop? _stateInterop;

/// The shared state accessed by both dart programs.
///
/// This contains the actual shared state and a listener function, that
/// will be called when the state changes in order to notify the other program.
///
/// Normally this should be a [List<Function> listeners] to allow both programs
/// to register their listeners. However [List]s, as any other dart class, will
/// have a unique type identity in each program and therefore cannot be shared.
/// (See the docs at [AppState])
///
/// Therefore this implementation uses a nested listener approach, where each
/// program will save the existing listener in a local variable, override the listener,
/// and call the saved listener inside the new function.
@js.JS()
@js.anonymous
class StateInterop<T> {
  external factory StateInterop({dynamic state, void Function()? listener});

  external T state;
  external void Function()? listener;
}

/// A riverpod notifier that syncs its state across programs using js-interop.
///
/// This overrides the [state] setter to also notify the interop state when changed.
///
/// In the current implementation all notifiers will sync with the same underlying
/// state. However this could also be extended to sync multiple states based on some shared key.
abstract class InteropNotifier<T> extends Notifier<T> {
  late StateInterop<T> _interop;

  T buildState();

  @override
  T build() {
    var initialState = buildState();

    _interop = (_stateInterop ??= StateInterop(
      state: initialState,
      listener: null,
    )) as StateInterop<T>;

    // Uses 'nested listeners' to add a listener to the interop state.
    var l = _interop.listener;
    _interop.listener = js.allowInterop(() {
      if (state != _interop.state) {
        super.state = _interop.state;
      }
      l?.call();
    });

    return _interop.state;
  }

  @override
  set state(T newState) {
    super.state = newState;

    _interop.state = newState;
    _interop.listener?.call();
  }
}
