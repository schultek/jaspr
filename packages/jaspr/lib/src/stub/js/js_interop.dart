import 'dart:typed_data';

class JS {
  final String? name;
  const JS([this.name]);
}

class _StaticInterop {
  const _StaticInterop();
}

// ignore: library_private_types_in_public_api
const Object staticInterop = _StaticInterop();

class _Anonymous {
  const _Anonymous();
}

// ignore: library_private_types_in_public_api
const Object anonymous = _Anonymous();

class JSExport {
  final String name;
  const JSExport([this.name = '']);
}

abstract class JSAny {}

class JSObject implements JSAny {
  JSObject();
}

abstract class JSFunction implements JSObject {}

abstract class JSExportedDartFunction implements JSFunction {}

abstract class JSArray<T extends JSAny?> implements JSObject {
  factory JSArray() => _unsupportedPlatformError();
  factory JSArray.withLength(int length) => _unsupportedPlatformError();

  static JSArray<T> from<T extends JSAny>(JSObject arrayLike) => _unsupportedPlatformError();

  int get length;
  set length(int newLength);
  T operator [](int index);
  void operator []=(int index, T value);

  void add(T value);
}

abstract class JSPromise<T extends JSAny?> implements JSObject {
  factory JSPromise() => _unsupportedPlatformError();
}

class NullRejectionException implements Exception {
  final bool isUndefined;
  NullRejectionException(this.isUndefined);
}

abstract class JSBoxedDartObject implements JSObject {}

abstract class JSArrayBuffer implements JSObject {
  factory JSArrayBuffer(int length, [JSObject? options]) => _unsupportedPlatformError();
}

abstract class JSDataView implements JSObject {
  factory JSDataView(JSArrayBuffer buffer, [int? byteOffset, int? byteLength]) => _unsupportedPlatformError();
}

abstract class JSTypedArray implements JSObject {}

abstract class JSInt8Array implements JSTypedArray {
  factory JSInt8Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSInt8Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSUint8Array implements JSTypedArray {
  factory JSUint8Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSUint8Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSUint8ClampedArray implements JSTypedArray {
  factory JSUint8ClampedArray([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSUint8ClampedArray.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSInt16Array implements JSTypedArray {
  factory JSInt16Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSInt16Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSUint16Array implements JSTypedArray {
  factory JSUint16Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSUint16Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSInt32Array implements JSTypedArray {
  factory JSInt32Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSInt32Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSUint32Array implements JSTypedArray {
  factory JSUint32Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSUint32Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSFloat32Array implements JSTypedArray {
  factory JSFloat32Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSFloat32Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSFloat64Array implements JSTypedArray {
  factory JSFloat64Array([JSArrayBuffer? buffer, int? byteOffset, int? length]) => _unsupportedPlatformError();

  factory JSFloat64Array.withLength(int length) => _unsupportedPlatformError();
}

abstract class JSNumber implements JSAny {}

abstract class JSString implements JSAny {}

abstract class JSBoolean implements JSAny {}

abstract class JSSymbol implements JSAny {
  factory JSSymbol([Object? description]) => _unsupportedPlatformError();

  static JSSymbol forKey(String key) => _unsupportedPlatformError();

  static JSSymbol get asyncIterator => _unsupportedPlatformError();

  static JSSymbol get hasInstance => _unsupportedPlatformError();

  static JSSymbol get isConcatSpreadable => _unsupportedPlatformError();

  static JSSymbol get iterator => _unsupportedPlatformError();

  static JSSymbol get match => _unsupportedPlatformError();

  static JSSymbol get matchAll => _unsupportedPlatformError();

  static JSSymbol get replace => _unsupportedPlatformError();

  static JSSymbol get search => _unsupportedPlatformError();

  static JSSymbol get species => _unsupportedPlatformError();

  static JSSymbol get split => _unsupportedPlatformError();

  static JSSymbol get toPrimitive => _unsupportedPlatformError();

  static JSSymbol get toStringTag => _unsupportedPlatformError();

  static JSSymbol get unscopables => _unsupportedPlatformError();

  String? get key;

  String get description;
}

abstract class JSBigInt implements JSAny {}

abstract class ExternalDartReference<T extends Object?> {}

typedef JSVoid = void;

extension NullableUndefineableJSAnyExtension on JSAny? {
  bool get isUndefined => false;
  bool get isNull => this == null;

  bool get isUndefinedOrNull => this == null;
  bool get isDefinedAndNotNull => !isUndefinedOrNull;
}

extension JSAnyUtilityExtension on JSAny? {
  bool typeofEquals(String typeString) => _unsupportedPlatformError();

  bool instanceof(JSFunction constructor) => _unsupportedPlatformError();

  bool instanceOfString(String constructorName) => _unsupportedPlatformError();

  bool isA<T extends JSAny?>() => _unsupportedPlatformError();

  Object? dartify() => _unsupportedPlatformError();
}

extension NullableObjectUtilExtension on Object? {
  JSAny? jsify() => _unsupportedPlatformError();
}

extension JSFunctionUtilExtension on JSFunction {
  JSAny? callAsFunction([JSAny? thisArg, JSAny? arg1, JSAny? arg2, JSAny? arg3, JSAny? arg4]) =>
      _unsupportedPlatformError();
}

// Extension members to support conversions between Dart types and JS types.
// Not all Dart types can be converted to JS types and vice versa.

extension JSExportedDartFunctionToFunction on JSExportedDartFunction {
  Function get toDart => _unsupportedPlatformError();
}

extension FunctionToJSExportedDartFunction on Function {
  JSExportedDartFunction get toJS => _unsupportedPlatformError();

  JSExportedDartFunction get toJSCaptureThis => _unsupportedPlatformError();
}

extension JSBoxedDartObjectToObject on JSBoxedDartObject {
  Object get toDart => _unsupportedPlatformError();
}

extension ObjectToJSBoxedDartObject on Object {
  JSBoxedDartObject get toJSBox => _unsupportedPlatformError();
}

extension ExternalDartReferenceToObject<T extends Object?> on ExternalDartReference<T> {
  T get toDartObject => _unsupportedPlatformError();
}

extension ObjectToExternalDartReference<T extends Object?> on T {
  ExternalDartReference<T> get toExternalReference => _unsupportedPlatformError();
}

extension JSPromiseToFuture<T extends JSAny?> on JSPromise<T> {
  Future<T> get toDart => _unsupportedPlatformError();
}

extension FutureOfJSAnyToJSPromise<T extends JSAny?> on Future<T> {
  JSPromise<T> get toJS => _unsupportedPlatformError();
}

extension FutureOfVoidToJSPromise on Future<void> {
  JSPromise get toJS => _unsupportedPlatformError();
}

extension JSArrayBufferToByteBuffer on JSArrayBuffer {
  ByteBuffer get toDart => _unsupportedPlatformError();
}

extension ByteBufferToJSArrayBuffer on ByteBuffer {
  JSArrayBuffer get toJS => _unsupportedPlatformError();
}

extension JSDataViewToByteData on JSDataView {
  ByteData get toDart => _unsupportedPlatformError();
}

extension ByteDataToJSDataView on ByteData {
  JSDataView get toJS => _unsupportedPlatformError();
}

extension JSInt8ArrayToInt8List on JSInt8Array {
  Int8List get toDart => _unsupportedPlatformError();
}

extension Int8ListToJSInt8Array on Int8List {
  JSInt8Array get toJS => _unsupportedPlatformError();
}

extension JSUint8ArrayToUint8List on JSUint8Array {
  Uint8List get toDart => _unsupportedPlatformError();
}

extension Uint8ListToJSUint8Array on Uint8List {
  JSUint8Array get toJS => _unsupportedPlatformError();
}

extension JSUint8ClampedArrayToUint8ClampedList on JSUint8ClampedArray {
  Uint8ClampedList get toDart => _unsupportedPlatformError();
}

extension Uint8ClampedListToJSUint8ClampedArray on Uint8ClampedList {
  JSUint8ClampedArray get toJS => _unsupportedPlatformError();
}

extension JSInt16ArrayToInt16List on JSInt16Array {
  Int16List get toDart => _unsupportedPlatformError();
}

extension Int16ListToJSInt16Array on Int16List {
  JSInt16Array get toJS => _unsupportedPlatformError();
}

extension JSUint16ArrayToInt16List on JSUint16Array {
  Uint16List get toDart => _unsupportedPlatformError();
}

extension Uint16ListToJSInt16Array on Uint16List {
  JSUint16Array get toJS => _unsupportedPlatformError();
}

extension JSInt32ArrayToInt32List on JSInt32Array {
  Int32List get toDart => _unsupportedPlatformError();
}

extension Int32ListToJSInt32Array on Int32List {
  JSInt32Array get toJS => _unsupportedPlatformError();
}

extension JSUint32ArrayToUint32List on JSUint32Array {
  Uint32List get toDart => _unsupportedPlatformError();
}

extension Uint32ListToJSUint32Array on Uint32List {
  JSUint32Array get toJS => _unsupportedPlatformError();
}

extension JSFloat32ArrayToFloat32List on JSFloat32Array {
  Float32List get toDart => _unsupportedPlatformError();
}

extension Float32ListToJSFloat32Array on Float32List {
  JSFloat32Array get toJS => _unsupportedPlatformError();
}

extension JSFloat64ArrayToFloat64List on JSFloat64Array {
  Float64List get toDart => _unsupportedPlatformError();
}

extension Float64ListToJSFloat64Array on Float64List {
  JSFloat64Array get toJS => _unsupportedPlatformError();
}

extension JSArrayToList<T extends JSAny?> on JSArray<T> {
  List<T> get toDart => _unsupportedPlatformError();
}

extension ListToJSArray<T extends JSAny?> on List<T> {
  JSArray<T> get toJS => _unsupportedPlatformError();

  JSArray<T> get toJSProxyOrRef => _unsupportedPlatformError();
}

extension JSNumberToNumber on JSNumber {
  double get toDartDouble => _unsupportedPlatformError();

  int get toDartInt => _unsupportedPlatformError();
}

extension DoubleToJSNumber on double {
  JSNumber get toJS => _unsupportedPlatformError();
}

extension NumToJSExtension on num {
  JSNumber get toJS => _unsupportedPlatformError();
}

extension JSBooleanToBool on JSBoolean {
  bool get toDart => _unsupportedPlatformError();
}

extension BoolToJSBoolean on bool {
  JSBoolean get toJS => _unsupportedPlatformError();
}

extension JSStringToString on JSString {
  String get toDart => _unsupportedPlatformError();
}

extension StringToJSString on String {
  JSString get toJS => _unsupportedPlatformError();
}

extension JSAnyOperatorExtension on JSAny? {
  // Arithmetic operators.

  JSAny add(JSAny? any) => _unsupportedPlatformError();

  JSAny subtract(JSAny? any) => _unsupportedPlatformError();

  JSAny multiply(JSAny? any) => _unsupportedPlatformError();

  JSAny divide(JSAny? any) => _unsupportedPlatformError();

  JSAny modulo(JSAny? any) => _unsupportedPlatformError();

  JSAny exponentiate(JSAny? any) => _unsupportedPlatformError();

  // Comparison operators.

  JSBoolean greaterThan(JSAny? any) => _unsupportedPlatformError();

  JSBoolean greaterThanOrEqualTo(JSAny? any) => _unsupportedPlatformError();

  JSBoolean lessThan(JSAny? any) => _unsupportedPlatformError();

  JSBoolean lessThanOrEqualTo(JSAny? any) => _unsupportedPlatformError();

  JSBoolean equals(JSAny? any) => _unsupportedPlatformError();

  JSBoolean notEquals(JSAny? any) => _unsupportedPlatformError();

  JSBoolean strictEquals(JSAny? any) => _unsupportedPlatformError();

  JSBoolean strictNotEquals(JSAny? any) => _unsupportedPlatformError();

  // Bitwise operators.

  JSNumber unsignedRightShift(JSAny? any) => _unsupportedPlatformError();

  // Logical operators.

  JSAny? and(JSAny? any) => _unsupportedPlatformError();

  JSAny? or(JSAny? any) => _unsupportedPlatformError();

  JSBoolean get not => _unsupportedPlatformError();

  JSBoolean get isTruthy => _unsupportedPlatformError();
}

JSObject get globalContext => _unsupportedPlatformError();

JSObject createJSInteropWrapper<T extends Object>(T dartObject, [JSObject? proto]) => _unsupportedPlatformError();

JSPromise<JSObject> importModule(JSAny moduleName) => _unsupportedPlatformError();

// error

Never _unsupportedPlatformError() {
  throw UnsupportedError('Cannot use js_interop on this platform.');
}
