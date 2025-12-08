import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('raw', () {
      test('outputs raw styles', () {
        final styles = const Styles(raw: {'a': 'b', 'c': 'd'});

        expect(styles.properties, equals({'a': 'b', 'c': 'd'}));
      });
    });
  });
}
