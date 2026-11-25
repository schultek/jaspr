@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('animation', () {
      test('named', () {
        const styles = Styles(animation: Animation.none);
        expect(styles.properties, equals({'animation': 'none'}));
      });

      test('basic', () {
        const styles = Styles(
          animation: Animation(
            name: 'slide',
            duration: Duration(milliseconds: 500),
            curve: Curve.linearFn([Linear(0.2, 30.0, 60.0), Linear(0.3, 40.0, 80.5)]),
            delay: Duration(milliseconds: 100),
            count: double.infinity,
            direction: AnimationDirection.normal,
            fillMode: AnimationFillMode.forwards,
            playState: AnimationPlayState.running,
          ),
        );
        expect(
          styles.properties,
          equals({
            'animation': '500ms linear(0.2 30% 60%, 0.3 40% 80.5%) 100ms infinite normal forwards running slide',
          }),
        );
      });

      test('finite count', () {
        const animations = Animation.list([
          Animation(name: 'slide', duration: Duration(milliseconds: 100), count: 3),
          Animation(name: 'fade', duration: Duration(milliseconds: 200), count: 1.5),
        ]);
        expect(animations.value, equals('100ms 3 slide, 200ms 1.5 fade'));
      });

      group('combine', () {
        test('basic', () {
          const animations = Animation.list([
            Animation(duration: Duration(milliseconds: 100), name: 'slide'),
            Animation(duration: Duration(milliseconds: 200), name: 'rotate'),
          ]);
          expect(animations.value, equals('100ms slide, 200ms rotate'));
        });

        test('empty list not allowed', () {
          expect(
            () => Animation.list([]).value,
            throwsA(
              predicate((e) => e == 'Cannot have empty Animation.list. For no animation, use Animation.none instead'),
            ),
          );
        });
      });
    });
  });
}
