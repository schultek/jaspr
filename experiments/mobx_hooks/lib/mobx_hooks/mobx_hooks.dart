import 'dart:math' as math;

import 'package:mobx/mobx.dart'
    show Atom, AtomSpyReporter, Derivation, mainContext;

import 'package:jaspr/jaspr.dart';
// ignore: implementation_imports
import 'package:mobx/src/core.dart' show ReactionImpl;

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
    ctx._previous = _ctx;
    _ctx = ctx;
    ctx._startTracking();

    print('willRebuildElement ${ctx.hashCode} ${element.hashCode}');
  }

  @override
  void didRebuildElement(Element element) {
    print('didRebuildElement ${ctx.hashCode} ${element.hashCode}');

    ctx._afterRender();
    _ctx = ctx._previous;
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
      final _name = name ?? mainContext.nameFor('useTrack');
      return ReactionImpl(
        mainContext,
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

HookCtx? _ctx;
HookCtx get ctx {
  assert(_ctx != null, 'Current HookCtx is null ${StackTrace.current}');
  return _ctx!;
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

  HookCtx(this._onDependencyChange);
  final void Function() _onDependencyChange;

  String get _name => hashCode.toString();

  late final _reaction = ReactionImpl(
    mainContext,
    () {
      print('$_name dependency-change');
      _onDependencyChange();
    },
    name: _name,
    onError: (err, stackTrace) =>
        print('ReactionImplError $_name $err $stackTrace'),
  );

  Derivation? _derivation;

  void _startTracking() {
    _derivation = _reaction.startTracking();
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

  // TODO: test timing
  void _afterRender() {
    _reaction.endTracking(_derivation);

    for (int i = 0;
        i < math.max(_hookEffects.length, _previousHookEffects.length);
        i++) {
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

    _previousHookEffects = _hookEffects;
    _hookEffects = [];

    _hookRefIndex = 0;
    _hookObsIndex = 0;
  }

  void _dispose() {
    if (disposed) return;
    _disposed = true;
    for (final hook in _previousHookEffects) {
      hook.cleanup?.call();
    }
    _reaction.dispose();
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
  ctx._hookEffects.add(_hook);
}

Ref<T> useRef<T>(T Function() builder) {
  final Ref<T> ref;
  if (ctx._hookRefIndex == null) {
    ref = Ref._(builder());
    ctx._hookRefs.add(ref);
  } else {
    final _ref = ctx._hookRefs[ctx._hookRefIndex!];
    ref = _ref as Ref<T>;
    ctx._hookRefIndex = ctx._hookRefIndex! + 1;
  }
  return ref;
}

Obs<T> useObs<T>(T Function() builder) {
  final Obs<T> ref;
  if (ctx._hookObsIndex == null) {
    ref = Obs(builder());
    ctx._hookObs.add(ref);
  } else {
    final _ref = ctx._hookObs[ctx._hookObsIndex!];
    ref = _ref as Obs<T>;
    ctx._hookObsIndex = ctx._hookObsIndex! + 1;
  }
  return ref;
}
