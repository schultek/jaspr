import 'package:jaspr/jaspr.dart';
import 'package:test/test.dart';

void main() {
  group('object keys', () {
    // Built at runtime so the two strings are equal but not canonicalized.
    final a = 'key-${1}';
    final b = 'key-${'1'}';

    test('compare string values by their contents', () {
      expect(GlobalObjectKey(a), equals(GlobalObjectKey(b)));
      expect(GlobalObjectKey(a).hashCode, GlobalObjectKey(b).hashCode);
      expect(GlobalObjectStateKey(a), equals(GlobalObjectStateKey(b)));
      expect(GlobalObjectNodeKey(a), equals(GlobalObjectNodeKey(b)));
      expect(GlobalObjectKey(a), isNot(equals(GlobalObjectKey('key-2'))));
    });

    test('compare other values by identity', () {
      final value = Object();
      expect(GlobalObjectKey(value), equals(GlobalObjectKey(value)));
      expect(GlobalObjectStateKey(value), equals(GlobalObjectStateKey(value)));
      expect(GlobalObjectNodeKey(value), equals(GlobalObjectNodeKey(value)));
      expect(GlobalObjectKey(value), isNot(equals(GlobalObjectKey(Object()))));
      expect(GlobalObjectKey([1]), isNot(equals(GlobalObjectKey([1]))));
    });

    test('differ by key type', () {
      expect(GlobalObjectKey(a), isNot(equals(GlobalObjectStateKey(a))));
      expect(GlobalObjectKey(a), isNot(equals(_PrivateKey(a))));
    });
  });
}

class _PrivateKey extends GlobalObjectKey {
  const _PrivateKey(super.value);
}
