@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('transition', () {
      test('named', () {
        const styles = Styles(transition: Transition.inherit);
        expect(styles.properties, equals({'transition': 'inherit'}));
      });

      test('basic', () {
        final styles = Styles(
          transition: Transition('all', duration: 500.ms, curve: Curve.ease, delay: 600.ms),
        );
        expect(styles.properties, equals({'transition': 'all 500ms ease 600ms'}));
      });

      group('combine', () {
        test('basic', () {
          final transition = Transition.combine([
            Transition('opacity', duration: 100.ms),
            Transition('height', duration: 2.seconds),
          ]);
          expect(transition.value, equals('opacity 100ms, height 2000ms'));
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
