import 'dart:math' as math;

import 'package:jaspr/jaspr.dart';
import 'package:mobx/mobx.dart' as mobx;
// ignore: implementation_imports
import 'package:mobx/src/core.dart' show ReactionImpl;

import 'obs.dart';

export 'obs.dart';

class MobXHooksObserverComponent extends ObserverComponent {
  /// Initializes [key] for subclasses.
  const MobXHooksObserverComponent({required super.child});

  @override
  MobXHooksObserverElement createElement() => MobXHooksObserverElement(this);
}

class MobXHooksObserverElement extends ObserverElement {
  MobXHooksObserverElement(super.component);

  final Map<Element, HookCtx> hookContexts = {};

  @override
  void unmount() {
    for (final hook in hookContexts.values) {
      hook._dispose();
    }
    hookContexts.clear();
    super.unmount();
  }

  @override
  void willRebuildElement(Element element) {
    final ctx = hookContexts.putIfAbsent(
      element,
      () => HookCtx(element.markNeedsBuild),
    );
    ctx.startTracking();

    print('willRebuildElement ${ctx.hashCode} ${element.hashCode}');
  }

  @override
  void didRebuildElement(Element element) {
    print(
        'didRebuildElement ${globalHookContext.hashCode} ${element.hashCode}');

    globalHookContext.endTracking();
  }

  @override
  void didUnmountElement(Element element) {
    final ctx = hookContexts.remove(element);
    print('didUnmountElement ${ctx?.hashCode} ${element.hashCode}');
    if (ctx != null) {
      ctx._dispose();
    }
  }
}

T useTrack<T>(
  T Function() compute,
  void Function() onDependencyChange, {
  String? name,
}) {
  final reaction = useRef<ReactionImpl>(
    () {
      final _name = name ?? mobx.mainContext.nameFor('useTrack');
      return ReactionImpl(
        mobx.mainContext,
        () {
          print('$_name dependency-change');
          onDependencyChange();
        },
        name: _name,
        onError: (err, stackTrace) => print('useTrack $_name $err $stackTrace'),
      );
    },
  ).value;
  useEffect(
    () => reaction.dispose,
    const [],
  );

  late final T trackedValue;
  reaction.track(() {
    print('${reaction.name} start-track');
    trackedValue = compute();
    print('${reaction.name} end-track');
  });
  return trackedValue;
}

class Ref<T> {
  Ref._(this.value);
  T value;

  @override
  String toString() {
    return 'Ref($value)';
  }
}

/// A function to be called to cleanup an effect.
typedef Cleanup = void Function();

/// An [Effect] is a function to be called when a
/// component was (re)rendered.
typedef Effect = Cleanup? Function();

typedef KeysEquals = bool Function(Object?, Object?);

class HookEffect {
  final Effect effect;
  final List<Object?>? keys;
  final KeysEquals isEqual;
  Cleanup? cleanup;

  HookEffect({
    required this.effect,
    required this.keys,
    required this.isEqual,
  });
}

bool defaultKeysEquals(Object? a, Object? b) => a == b;

HookCtx? __globalHookContext;
HookCtx get globalHookContext {
  assert(
    __globalHookContext != null,
    'Current HookCtx is null ${StackTrace.current}',
  );
  return __globalHookContext!;
}

class HookCtx {
  int? _hookRefIndex;
  final List<Ref> _hookRefs = [];
  int? _hookObsIndex;
  final List<Obs> _hookObs = [];

  List<HookEffect> _hookEffects = [];
  List<HookEffect> _previousHookEffects = [];
  bool _disposed = false;
  bool get disposed => _disposed;
  HookCtx? _previous;
  HookCtx? _next;
  bool _scheduled = false;

  HookCtx(this._onDependencyChange);
  final void Function() _onDependencyChange;

  String get _name => hashCode.toString();

  late final _reaction = ReactionImpl(
    mobx.mainContext,
    () {
      print('$_name dependency-change');
      _onDependencyChange();
    },
    name: _name,
    onError: (err, stackTrace) =>
        print('ReactionImplError $_name $err $stackTrace'),
  );

  mobx.Derivation? _derivation;

  void startTracking() {
    assert(!_scheduled);
    assert(_derivation == null);
    _previous = __globalHookContext;
    if (_previous != null) {
      _previous!._next = this;
    }
    __globalHookContext = this;
    _derivation = _reaction.startTracking();
  }

  // TODO: test timing
  void endTracking() {
    assert(__globalHookContext == this);
    _reaction.endTracking(_derivation);
    _derivation = null;
    __globalHookContext = _previous;
    _scheduled = true;
    Future.microtask(_executeHooksLogic);
  }

  void _executeHooksLogic() {
    _scheduled = false;
    for (int i = 0;
        i < math.max(_hookEffects.length, _previousHookEffects.length);
        i++) {
      _executeHookItem(i);
    }

    _previousHookEffects = _hookEffects;
    _hookEffects = [];

    _hookRefIndex = 0;
    _hookObsIndex = 0;
  }

  void _executeHookItem(int i) {
    final previous =
        _previousHookEffects.length > i ? _previousHookEffects[i] : null;
    final current = _hookEffects.length > i ? _hookEffects[i] : null;
    if (previous != null && current != null) {
      assert(previous.isEqual == current.isEqual);
      final prevKeys = previous.keys;
      final newKeys = current.keys;

      if (areKeysDifferent(prevKeys, newKeys, current.isEqual)) {
        previous.cleanup?.call();
        current.cleanup = current.effect();
      } else {
        current.cleanup = previous.cleanup;
      }
    } else if (current != null) {
      current.cleanup = current.effect();
    } else if (previous != null) {
      previous.cleanup?.call();
    }
  }

  void _dispose() {
    if (disposed) return;
    _disposed = true;
    for (final hook in _previousHookEffects) {
      hook.cleanup?.call();
    }
    _reaction.dispose();
  }

  static bool areKeysDifferent(
    List<Object?>? prevKeys,
    List<Object?>? newKeys,
    KeysEquals isEqual,
  ) {
    int i = 0;
    return newKeys == null ||
        prevKeys == null ||
        (prevKeys.length != newKeys.length ||
            prevKeys.any((e) => !isEqual(e, newKeys[i++])));
  }
}

void useEffect(
  Effect effect, [
  List<Object?>? keys,
  KeysEquals isEqual = defaultKeysEquals,
]) {
  final _hook = HookEffect(
    effect: effect,
    keys: keys,
    isEqual: isEqual,
  );
  globalHookContext._hookEffects.add(_hook);
}

Ref<T> useRef<T>(T Function() builder) {
  final Ref<T> ref;
  final ctx = globalHookContext;
  final index = ctx._hookRefIndex;
  if (index == null) {
    ref = Ref._(builder());
    ctx._hookRefs.add(ref);
  } else {
    final _ref = ctx._hookRefs[index];
    ref = _ref as Ref<T>;
    ctx._hookRefIndex = index + 1;
  }
  return ref;
}

Obs<T> useObs<T>(T Function() builder) {
  final Obs<T> ref;
  final ctx = globalHookContext;
  final index = ctx._hookObsIndex;
  if (index == null) {
    ref = Obs(builder());
    ctx._hookObs.add(ref);
  } else {
    final _ref = ctx._hookObs[index];
    ref = _ref as Obs<T>;
    ctx._hookObsIndex = index + 1;
  }
  return ref;
}
