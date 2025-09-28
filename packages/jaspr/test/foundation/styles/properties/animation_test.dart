@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
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
            duration: 500.0,
            easeFunc: Curve.linear([Linear(0.2, 30.0, 60.0), Linear(0.3, 40.0, 80.5)]),
            delay: 100.0,
            iterCount: double.infinity,
            direction: AnimationDirection.normal,
            fillMode: AnimationFillMode.forwards,
            playState: AnimationPlayState.running,
            keyframe: 'slide',
          ),
        );
        expect(
          styles.properties,
          equals({
            'animation': '500ms linear(0.2 30% 60%, 0.3 40% 80.5%) 100ms infinity normal forwards running slide',
          }),
        );
      });

      group('combine', () {
        test('basic', () {
          const animations = Animation.list([
            Animation(duration: 100.0, keyframe: 'slide'),
            Animation(duration: 200.0, keyframe: 'rotate'),
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
