// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Framework code should use this method in favor of calling `toString` on
/// [Object.runtimeType].
///
/// Calling `toString` on a runtime type is a non-trivial operation that can
/// negatively impact performance. If asserts are enabled, this method will
/// return `object.runtimeType.toString()`; otherwise, it will return the
/// [optimizedValue], which must be a simple constant string.
String objectRuntimeType(Object? object, String optimizedValue) {
  assert(() {
    optimizedValue = object.runtimeType.toString();
    return true;
  }());
  return optimizedValue;
}

/// Returns a 5 character long hexadecimal string generated from
/// [Object.hashCode]'s 20 least-significant bits.
String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

/// Returns a summary of the runtime type and hash code of `object`.
///
/// See also:
///
///  * [Object.hashCode], a value used when placing an object in a [Map] or
///    other similar data structure, and which is also used in debug output to
///    distinguish instances of the same class (hash collisions are
///    possible, but rare enough that its use in debug output is useful).
///  * [Object.runtimeType], the [Type] of an object.
String describeIdentity(Object? object) => '${objectRuntimeType(object, '<optimized out>')}#${shortHash(object)}';
