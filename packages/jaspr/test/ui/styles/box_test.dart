import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('box', () {
      group('border', () {
        test('base', () {
          expect(Border.initial.styles, equals({'border': 'initial'}));
          expect(Border.inherit.styles, equals({'border': 'inherit'}));
        });

        test('all', () {
          var border = Border.all(BorderSide(
            style: BorderStyle.dashed,
            color: Colors.blue,
            width: 2.px,
          ));

          expect(border.styles, equals({'border': 'dashed blue 2px'}));
        });

        test('only', () {
          var border = Border.only(
            left: BorderSide(
              style: BorderStyle.solid,
              color: Colors.black,
              width: 2.pt,
            ),
          );

          expect(
            border.styles,
            equals({
              'border-left-style': 'solid',
              'border-left-color': 'black',
              'border-left-width': '2pt',
            }),
          );
        });

        test('symmetric', () {
          var border = Border.symmetric(
            vertical: BorderSide(
              style: BorderStyle.solid,
              color: Colors.blue,
            ),
            horizontal: BorderSide(
              style: BorderStyle.dashed,
              width: 2.pt,
            ),
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
          var radius = BorderRadius.only(
            topLeft: Radius.circular(20.px),
            topRight: Radius.circular(10.px),
          );
          expect(
            radius.styles,
            equals({'border-top-left-radius': '20px', 'border-top-right-radius': '10px'}),
          );
        });

        test('only double mixed', () {
          var radius = BorderRadius.only(
            topLeft: Radius.circular(20.px),
            topRight: Radius.elliptical(10.px, 5.px),
          );
          expect(
            radius.styles,
            equals({'border-top-left-radius': '20px', 'border-top-right-radius': '10px 5px'}),
          );
        });

        test('only all mixed', () {
          var radius = BorderRadius.only(
            topLeft: Radius.circular(20.px),
            topRight: Radius.elliptical(10.px, 5.pt),
            bottomLeft: Radius.elliptical(Unit.zero, 25.px),
            bottomRight: Radius.circular(2.em),
          );
          expect(
            radius.styles,
            equals({'border-radius': '20px 10px 2em 0 / 20px 5pt 2em 25px'}),
          );
        });
      });
    });
  });
}
