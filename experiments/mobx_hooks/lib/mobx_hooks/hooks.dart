import 'package:async/async.dart' show Result;
import 'package:mobx/mobx.dart'
    show Computed, Reaction, ReactiveContext, autorun;
import 'mobx_hooks.dart'
    show HookCtx, KeysEquals, defaultKeysEquals, useEffect, useObs, useRef;

/// Memoizes (caches) the value returned by [valueFactory]
/// as long as [keys] are the same.
T useMemo<T>(
  T Function() valueFactory, [
  List<Object?> keys = const [],
  KeysEquals keysEquals = defaultKeysEquals,
]) {
  final prevKeys = usePrevious(keys);
  final ref = useRef(valueFactory);
  if (prevKeys != null &&
      HookCtx.areKeysDifferent(prevKeys, keys, keysEquals)) {
    ref.value = valueFactory();
  }
  return ref.value;
}

/// Memoizes (caches) [callback] as long as [keys] are the same.
/// Useful when downstream logic has to perform more computations
/// when the reference to [callback] changes.
F useCallback<F extends Function>(
  F callback,
  List<Object?> keys, [
  KeysEquals keysEquals = defaultKeysEquals,
]) {
  return useMemo(() => callback, keys, keysEquals);
}

/// Returns the value passed as argument on the previous execution.
/// Returns null on the first execution.
T? usePrevious<T>(T value) {
  final previous = useRef<T?>(() => null);
  final toReturn = previous.value;
  previous.value = value;
  return toReturn;
}

R? useValueChanged<T, R>(
  T value,
  R? Function(T previous, R? oldResult) onChanged,
) {
  final previous = usePrevious(value);
  bool isInitial = false;
  final result = useRef<R?>(() {
    isInitial = true;
    return null;
  });
  if (!isInitial && value != previous) {
    result.value = onChanged(previous as T, result.value);
  }
  return result.value;
}

bool Function() useIsMounted() {
  final isMounted = useRef(() => false);
  useEffect(
    () {
      isMounted.value = true;
      return () {
        isMounted.value = false;
      };
    },
    const [],
  );
  final isMountedFn = useCallback(() => isMounted.value, const []);
  return isMountedFn;
}

/// Subscribes to [stream] and rebuilds on every change.
/// Unsubscribes to the previous [stream] it a new one is passed.
Result<T> useStream<T>(
  Stream<T> stream, {
  required T Function() initialValue,
}) {
  final result = useObs(
    () => Result.value(initialValue()),
  );
  useEffect(
    () {
      final subs = Result.captureStream(stream).listen((event) {
        result.value = event;
      });
      return () {
        subs.cancel();
      };
    },
    [stream],
  );
  return result.value;
}

/// Results the result of [future].
/// The component will rebuild when the future completes.
/// If another [future] is passed, the previous one's result will
/// not we set when it is complete.
Result<T> useFuture<T>(
  Future<T> future, {
  required T Function() initialValue,
}) {
  final result = useObs(
    () => Result.value(initialValue()),
  );
  useEffect(
    () {
      bool isCurrent = true;
      Result.capture(future).then((event) {
        if (isCurrent) {
          result.value = event;
        }
      });
      return () {
        isCurrent = false;
      };
    },
    [future],
  );
  return result.value;
}

Result<T>? useFutureFunc<T>(
  Future<T> Function() futureFunc, {
  List<Object?> keys = const [],
}) {
  final result = useObs<Result<T>?>(() => null);
  useEffect(
    () {
      bool isCurrent = true;
      Result.capture(futureFunc()).then((event) {
        if (isCurrent) {
          result.value = event;
        }
      });
      return () {
        isCurrent = false;
      };
    },
    [keys],
  );
  return result.value;
}

/// Executes [function] and tracks dependencies using MobX.
/// If any of the dependencies change and the value return by [function]
/// changes, the Component on which this is used will be rebuilt
/// and the new value will be returned on the next build execution.
///
/// For more information in [Computed].
T useComputed<T>(
  T Function() function, {
  String? name,
  ReactiveContext? context,
  bool Function(T?, T?)? equals,
  List<Object?> keys = const [],
}) {
  final comp = useMemo(
    () => Computed(function, name: name, context: context, equals: equals),
    keys,
  );
  return comp.value;
}

/// Executes [function] and tracks its dependencies using MobX.
/// If any of the dependencies change, [function] will be executed
/// and tracked again. The Component on which this is used
/// will not be rebuilt.
///
/// For more information in [autorun].
void useAutorun(
  void Function(Reaction) function, {
  String? name,
  ReactiveContext? context,
  Duration? delay,
  List<Object?> keys = const [],
  void Function(Object, Reaction)? onError,
}) {
  useEffect(() {
    return autorun(
      function,
      name: name,
      context: context,
      delay: delay?.inMilliseconds,
      onError: onError,
    );
  }, keys);
}
