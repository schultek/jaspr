@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('border', () {
      test('base', () {
        expect(Border.initial.styles, equals({'border': 'initial'}));
        expect(Border.inherit.styles, equals({'border': 'inherit'}));
      });

      test('all', () {
        final okBorder = Border.all(style: BorderStyle.dashed, color: Colors.blue, width: 2.px);
        expect(okBorder.styles, equals({'border': 'dashed blue 2px'}));

        expect(() => Border.all(style: null, color: null, width: null), throwsAssertionError);
      });

      test('only', () {
        final border = Border.only(
          left: BorderSide.groove(color: Colors.black, width: 2.pt),
        );

        expect(
          border.styles,
          equals({'border-left-style': 'groove', 'border-left-color': 'black', 'border-left-width': '2pt'}),
        );
      });

      test('symmetric', () {
        final border = Border.symmetric(
          vertical: BorderSide.solid(color: Colors.blue),
          horizontal: BorderSide.dashed(width: 2.pt),
        );

        expect(
          border.styles,
          equals({
            'border-style': 'solid dashed',
            'border-top-color': 'blue',
            'border-bottom-color': 'blue',
            'border-left-width': '2pt',
            'border-right-width': '2pt',
          }),
        );
      });

      test('symmetric only', () {
        final border = Border.symmetric(vertical: BorderSide.dotted(color: Colors.blue));

        expect(
          border.styles,
          equals({
            'border-top-style': 'dotted',
            'border-bottom-style': 'dotted',
            'border-top-color': 'blue',
            'border-bottom-color': 'blue',
          }),
        );
      });

      test('none', () {
        final border = Border.none;

        expect(border.styles, equals({'border': 'none'}));
      });
    });

    group('border-radius', () {
      test('all', () {
        final radius = BorderRadius.all(Radius.circular(20.px));
        expect(radius.styles, equals({'border-radius': '20px'}));

        final radius2 = BorderRadius.all(Radius.elliptical(20.px, Unit.zero));
        expect(radius2.styles, equals({'border-radius': '20px / 0'}));
      });

      test('only single', () {
        final radius = BorderRadius.only(topLeft: Radius.circular(20.px));
        expect(radius.styles, equals({'border-top-left-radius': '20px'}));
      });

      test('only double circle', () {
        final radius = BorderRadius.only(topLeft: Radius.circular(20.px), topRight: Radius.circular(10.px));
        expect(radius.styles, equals({'border-top-left-radius': '20px', 'border-top-right-radius': '10px'}));
      });

      test('only double mixed', () {
        final radius = BorderRadius.only(topLeft: Radius.circular(20.px), topRight: Radius.elliptical(10.px, 5.px));
        expect(radius.styles, equals({'border-top-left-radius': '20px', 'border-top-right-radius': '10px 5px'}));
      });

      test('only all mixed', () {
        final radius = BorderRadius.only(
          topLeft: Radius.circular(20.px),
          topRight: Radius.elliptical(10.px, 5.pt),
          bottomLeft: Radius.elliptical(Unit.zero, 25.px),
          bottomRight: Radius.circular(2.em),
        );
        expect(radius.styles, equals({'border-radius': '20px 10px 2em 0 / 20px 5pt 2em 25px'}));
      });
    });

    group('overflow', () {
      test('value', () {
        expect(Overflow.initial.styles, equals({'overflow': 'initial'}));
        expect(Overflow.unset.styles, equals({'overflow': 'unset'}));
        expect(Overflow.auto.styles, equals({'overflow': 'auto'}));
        expect(Overflow.clip.styles, equals({'overflow': 'clip'}));
        expect(Overflow.scroll.styles, equals({'overflow': 'scroll'}));
        expect(Overflow.visible.styles, equals({'overflow': 'visible'}));
        expect(Overflow.hidden.styles, equals({'overflow': 'hidden'}));
        expect(Overflow.inherit.styles, equals({'overflow': 'inherit'}));
        expect(Overflow.revert.styles, equals({'overflow': 'revert'}));
        expect(Overflow.revertLayer.styles, equals({'overflow': 'revert-layer'}));
      });

      test('only', () {
        expect(Overflow.only(x: Overflow.visible, y: Overflow.hidden).styles, equals({'overflow': 'visible hidden'}));
        expect(Overflow.only(x: Overflow.clip).styles, equals({'overflow-x': 'clip'}));
      });
    });

    group('aspect-ratio', () {
      test('global values (private constructor) works', () {
        const styles = Styles(aspectRatio: AspectRatio.initial);
        expect(styles.properties, equals({'aspect-ratio': 'initial'}));
      });

      test('only numerator works', () {
        const styles = Styles(aspectRatio: AspectRatio(1));
        expect(styles.properties, equals({'aspect-ratio': '1'}));
      });

      test('numerator and denominator works', () {
        const styles = Styles(aspectRatio: AspectRatio(1, 2));
        expect(styles.properties, equals({'aspect-ratio': '1/2'}));
      });

      test('auto works', () {
        const styles = Styles(aspectRatio: AspectRatio.auto);
        expect(styles.properties, equals({'aspect-ratio': 'auto'}));
      });

      test('autoOrRatio with numerator works', () {
        const styles = Styles(aspectRatio: AspectRatio.autoOrRatio(1));
        expect(styles.properties, equals({'aspect-ratio': 'auto 1'}));
      });

      test('autoOrRatio with numerator and denominator works', () {
        const styles = Styles(aspectRatio: AspectRatio.autoOrRatio(1, 2));
        expect(styles.properties, equals({'aspect-ratio': 'auto 1/2'}));
      });
    });

    group('box shadow', () {
      test('global values', () {
        const styles = Styles(shadow: BoxShadow.initial);
        expect(styles.properties, equals({'box-shadow': 'initial'}));
      });

      test('all', () {
        final styles = Styles(
          shadow: BoxShadow(
            offsetX: 1.rem,
            offsetY: 2.rem,
            blur: 3.rem,
            spread: 4.rem,
            color: Colors.red,
          ),
        );
        expect(styles.properties, {'box-shadow': '1rem 2rem 3rem 4rem red'});
      });

      test('inset', () {
        final styles = Styles(
          shadow: BoxShadow.inset(
            offsetX: 1.rem,
            offsetY: 2.rem,
            blur: 3.rem,
            spread: 4.rem,
            color: Colors.red,
          ),
        );
        expect(styles.properties, {'box-shadow': 'inset 1rem 2rem 3rem 4rem red'});
      });

      group('combine', () {
        test('basic', () {
          const styles = Styles(
            shadow: BoxShadow.combine([BoxShadow(offsetX: Unit.rem(1), offsetY: Unit.rem(2))]),
          );
          expect(styles.properties, equals({'box-shadow': '1rem 2rem'}));
        });

        test('disallow empty list', () {
          expect(
            () => BoxShadow.combine([]).value,
            throwsA(predicate((e) => e == '[BoxShadow.combine] cannot be empty.')),
          );
        });

        test('disallow named values', () {
          const badBoxShadow = BoxShadow.combine([BoxShadow.initial]);
          expect(
            () => badBoxShadow.value,
            throwsA(predicate((e) => e == 'Cannot use initial as a list item, only standalone use supported.')),
          );
        });
      });
    });
  });
}
