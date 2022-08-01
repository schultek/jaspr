import 'package:async/async.dart' show Result;
import 'package:mobx/mobx.dart' show Computed, ReactiveContext;
import 'mobx_hooks.dart'
    show HookCtx, KeysEquals, defaultKeysEquals, useEffect, useObs, useRef;

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

F useCallback<F extends Function>(
  F callback,
  List<Object?> keys, [
  KeysEquals keysEquals = defaultKeysEquals,
]) {
  return useMemo(() => callback, keys, keysEquals);
}

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
  final newResult = useMemo(
    () {
      if (!isInitial && value != previous) {
        return onChanged(previous as T, result.value);
      }
      return result.value;
    },
    [previous, value],
  );
  return newResult;
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
  return () => isMounted.value;
}

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

T useComputed<T>(
  T Function() func, {
  String? name,
  ReactiveContext? context,
  bool Function(T?, T?)? equals,
  List<Object?> keys = const [],
}) {
  final comp = useMemo(
    () => Computed(func, name: name, context: context, equals: equals),
    keys,
  );
  return comp.value;
}

// TODO:
void useMobXEffect(void Function()? Function() effect) {
  final dispose = useComputed(effect);
  useEffect(() => dispose, [dispose]);
}
