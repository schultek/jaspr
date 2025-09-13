@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('border', () {
      test('base', () {
        expect(Border.initial.styles, equals({'border': 'initial'}));
        expect(Border.inherit.styles, equals({'border': 'inherit'}));
      });

      test('all', () {
        var border = Border(style: BorderStyle.dashed, color: Colors.blue, width: 2.px);

        expect(border.styles, equals({'border': 'dashed blue 2px'}));
      });

      test('only', () {
        var border = Border.only(
          left: BorderSide.groove(color: Colors.black, width: 2.pt),
        );

        expect(
          border.styles,
          equals({'border-left-style': 'groove', 'border-left-color': 'black', 'border-left-width': '2pt'}),
        );
      });

      test('symmetric', () {
        var border = Border.symmetric(
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
        var border = Border.symmetric(vertical: BorderSide.dotted(color: Colors.blue));

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
        var border = Border.none;

        expect(border.styles, equals({'border': 'none'}));
      });
    });

    group('border-radius', () {
      test('all', () {
        var radius = BorderRadius.all(Radius.circular(20.px));
        expect(radius.styles, equals({'border-radius': '20px'}));

        var radius2 = BorderRadius.all(Radius.elliptical(20.px, Unit.zero));
        expect(radius2.styles, equals({'border-radius': '20px / 0'}));
      });

      test('only single', () {
        var radius = BorderRadius.only(topLeft: Radius.circular(20.px));
        expect(radius.styles, equals({'border-top-left-radius': '20px'}));
      });

      test('only double circle', () {
        var radius = BorderRadius.only(topLeft: Radius.circular(20.px), topRight: Radius.circular(10.px));
        expect(radius.styles, equals({'border-top-left-radius': '20px', 'border-top-right-radius': '10px'}));
      });

      test('only double mixed', () {
        var radius = BorderRadius.only(topLeft: Radius.circular(20.px), topRight: Radius.elliptical(10.px, 5.px));
        expect(radius.styles, equals({'border-top-left-radius': '20px', 'border-top-right-radius': '10px 5px'}));
      });

      test('only all mixed', () {
        var radius = BorderRadius.only(
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
  });
}
