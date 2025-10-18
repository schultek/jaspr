@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('transition', () {
      test('named', () {
        const styles = Styles(transition: Transition.inherit);
        expect(styles.properties, equals({'transition': 'inherit'}));
      });

      test('basic', () {
        const styles = Styles(transition: Transition('all', duration: 500.0, curve: Curve.ease, delay: 600.0));
        expect(styles.properties, equals({'transition': 'all 500ms ease 600ms'}));
      });

      group('combine', () {
        test('basic', () {
          const transition = Transition.combine([
            Transition('opacity', duration: 100.0),
            Transition('height', duration: 200.0),
          ]);
          expect(transition.value, equals('opacity 100ms, height 200ms'));
        });

        test('empty list not allowed', () {
          expect(
            () => Transition.combine([]).value,
            throwsA(predicate((e) => e == 'Transition.combine cannot be empty.')),
          );
        });

        test('keyword values not allowed', () {
          expect(
            () => Transition.combine([Transition.initial]).value,
            throwsA(
              predicate((e) => e == 'Cannot use initial as a transition list item, only standalone use supported.'),
            ),
          );
        });
      });
    });
  });
}
