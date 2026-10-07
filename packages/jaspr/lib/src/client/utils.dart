import 'dart:collection';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

/// Creates a map keyed by DOM nodes with efficient lookups.
///
/// JS objects all have the same `hashCode` in Dart,
/// which makes a default map keyed by them degrade to linear lookups.
/// `Map.identity` can't be used instead either,
/// since separate Dart references to the same node aren't `identical` on Wasm.
Map<K, V> nodeMap<K extends web.Node, V>() => LinkedHashMap(hashCode: _nodeHashCode);

/// Creates a set of DOM nodes with efficient lookups. See [nodeMap].
Set<E> nodeSet<E extends web.Node>() => LinkedHashSet(hashCode: _nodeHashCode);

/// A JS `WeakMap` from JS objects to numbers.
///
/// Unlike an [Expando], it compares keys as JS objects.
/// On Wasm, an [Expando] compares the Dart references wrapping them instead,
/// so it misses the same node when accessed through a different reference.
@JS('WeakMap')
extension type _WeakMap._(JSObject _) implements JSObject {
  external _WeakMap();
  external JSNumber? get(JSObject key);
  external void set(JSObject key, JSNumber value);
}

/// The hash codes assigned to nodes by [_nodeHashCode].
final _nodeHashCodes = _WeakMap();
var _nextNodeHashCode = 0;

/// Returns a hash code for [node] that is stable for its lifetime.
///
/// Assigns the next unused hash code the first time it's called for [node].
int _nodeHashCode(web.Node node) {
  if (_nodeHashCodes.get(node) case final hashCode?) return hashCode.toDartInt;
  final hashCode = _nextNodeHashCode++;
  _nodeHashCodes.set(node, hashCode.toJS);
  return hashCode;
}

extension RemoveValues on web.HTMLElement {
  /// Removes the given values, as well as the `class` and `style` attributes if they're left empty,
  /// rather than leaving behind attributes that the element didn't have before.
  ///
  /// The [id] is only removed if the element still has it.
  void removeValues({String? id, Iterable<String>? classes, Iterable<String>? styles, Iterable<String>? attributes}) {
    if (id != null && this.id == id) {
      removeAttribute('id');
    }

    if (classes != null && classes.isNotEmpty) {
      for (final c in classes) {
        classList.remove(c);
      }
      if (classList.length == 0) {
        removeAttribute('class');
      }
    }

    if (styles != null && styles.isNotEmpty) {
      for (final name in styles) {
        style.removeProperty(name);
      }
      if (style.length == 0) {
        // Read the attribute first, so the browser syncs the pending style changes into it.
        // Otherwise, it can sync them afterwards and add back an empty `style` attribute.
        getAttribute('style');
        removeAttribute('style');
      }
    }

    if (attributes != null) {
      for (final name in attributes) {
        removeAttribute(name);
      }
    }
  }
}

extension NodeListIterable on web.NodeList {
  Iterable<web.Node> toIterable() sync* {
    for (var i = 0; i < length; i++) {
      yield item(i)!;
    }
  }
}

extension NamedNodeMapMap on web.NamedNodeMap {
  Map<String, String> toMap() {
    final map = <String, String>{};
    for (var i = 0; i < length; i++) {
      final item = this.item(i)!;
      map[item.name] = item.value;
    }
    return map;
  }
}
