import 'dart:js_interop';

extension JSObjectUnsafeUtilExtension on JSObject {
  bool has(String property) => hasProperty(property.toJS).toDart;

  JSBoolean hasProperty(JSAny property) => _unsupportedPlatformError();

  JSAny? operator [](String property) => getProperty(property.toJS);

  R getProperty<R extends JSAny?>(JSAny property) => _unsupportedPlatformError();

  void operator []=(String property, JSAny? value) => setProperty(property.toJS, value);

  void setProperty(JSAny property, JSAny? value) => _unsupportedPlatformError();

  R callMethod<R extends JSAny?>(JSAny method, [JSAny? arg1, JSAny? arg2, JSAny? arg3, JSAny? arg4]) =>
      _unsupportedPlatformError();

  R callMethodVarArgs<R extends JSAny?>(JSAny method, [List<JSAny?>? arguments]) => _unsupportedPlatformError();

  JSBoolean delete(JSAny property) => _unsupportedPlatformError();
}

extension JSFunctionUnsafeUtilExtension on JSFunction {
  R callAsConstructor<R>([JSAny? arg1, JSAny? arg2, JSAny? arg3, JSAny? arg4]) => _unsupportedPlatformError();

  R callAsConstructorVarArgs<R extends JSObject>([List<JSAny?>? arguments]) => _unsupportedPlatformError();
}

// error

Never _unsupportedPlatformError() {
  throw UnsupportedError('Cannot use js_interop_unsafe on this platform.');
}
