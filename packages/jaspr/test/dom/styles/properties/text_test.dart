@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('text', () {
      group('font', () {
        group('family', () {
          test('global value', () {
            const styles = Styles(fontFamily: FontFamily.initial);
            expect(styles.properties, {'font-family': 'initial'});
          });

          test('named', () {
            const styles = Styles(fontFamily: FontFamily('Roberto'));
            expect(styles.properties, {'font-family': "'Roberto'"});
          });

          test('variable', () {
            const styles = Styles(fontFamily: FontFamily.variable('--foo'));
            expect(styles.properties, {'font-family': 'var(--foo)'});
          });

          test('list', () {
            const styles = Styles(fontFamily: FontFamily.list([FontFamily('Roberto'), FontFamily('Helvetica')]));
            expect(styles.properties, equals({'font-family': "'Roberto', 'Helvetica'"}));

            expect(
              () => FontFamily.list([]).value,
              throwsA(predicate((e) => e == 'FontFamily.list cannot be empty')),
            );
          });
        });

        group('style', () {
          test('named', () {
            const styles = Styles(fontStyle: FontStyle.normal);
            expect(styles.properties, equals({'font-style': 'normal'}));
          });

          test('oblique angle', () {
            const styles = Styles(fontStyle: FontStyle.obliqueAngle(Angle.rad(1.2)));
            expect(styles.properties, equals({'font-style': 'oblique 1.2rad'}));
          });
        });
      });

      group('decoration', () {
        test('named', () {
          const styles = Styles(textDecoration: TextDecoration.unset);
          expect(styles.properties, equals({'text-decoration': 'unset'}));
        });

        test('basic', () {
          const styles = Styles(
            textDecoration: TextDecoration(
              line: TextDecorationLine.multi([
                TextDecorationLineKeyword.underline,
                TextDecorationLineKeyword.overline,
              ]),
              style: TextDecorationStyle.solid,
              color: Colors.red,
              thickness: TextDecorationThickness.value(Unit.rem(1)),
            ),
          );
          expect(styles.properties, equals({'text-decoration': 'underline overline solid red 1rem'}));
        });

        group('line', () {
          test('named', () {
            var textDecLine = TextDecorationLine.none;
            expect(textDecLine.value, equals('none'));

            textDecLine = TextDecorationLineKeyword.lineThrough;
            expect(textDecLine.value, equals('line-through'));
          });

          test('multi cannot be empty', () {
            expect(
              () => TextDecorationLine.multi([]).value,
              throwsA(predicate((e) => e == 'TextDecorationLine.multi cannot be empty')),
            );
          });
        });

        group('thickness', () {
          test('named', () {
            const thickness = TextDecorationThickness.auto;
            expect(thickness.value, equals('auto'));
          });

          test('value', () {
            const thickness = TextDecorationThickness.value(Unit.rem(1));
            expect(thickness.value, equals('1rem'));
          });
        });
      });

      group('shadow', () {
        test('named', () {
          const textShadow = TextShadow.initial;
          expect(textShadow.value, equals('initial'));
        });

        test('basic', () {
          final textShadow = TextShadow(offsetX: 1.rem, offsetY: 2.rem, blur: 3.rem, color: Colors.red);
          expect(textShadow.value, equals('1rem 2rem 3rem red'));
        });

        group('combine', () {
          test('basic', () {
            const textShadow = TextShadow.combine([
              TextShadow(offsetX: Unit.rem(1), offsetY: Unit.rem(2)),
              TextShadow(offsetX: Unit.rem(3), offsetY: Unit.rem(4)),
            ]);
            expect(textShadow.value, equals('1rem 2rem, 3rem 4rem'));
          });

          test('disallow empty list', () {
            const emptyTextShadow = TextShadow.combine([]);
            expect(
              () => emptyTextShadow.value,
              throwsA(
                predicate((e) => e == 'TextShadow.combine cannot be empty. For no text shadow, use TextShadow.none'),
              ),
            );
          });

          test('disallow named values', () {
            const illegalTextShadow = TextShadow.combine([TextShadow.unset]);
            expect(
              () => illegalTextShadow.value,
              throwsA(
                predicate((e) => e == 'Cannot use unset as a text shadow list item, only standalone use supported'),
              ),
            );
          });
        });
      });

      group('quotes', () {
        test('named', () {
          const quote = Quotes.initial;
          expect(quote.value, equals('initial'));
        });

        test('primary', () {
          final quote = Quotes(('<', '>'));
          expect(quote.value, equals('"<" ">"'));
        });

        test('secondary', () {
          final quote = Quotes(('<', '>'), ('<<', '>>'));
          expect(quote.value, equals('"<" ">" "<<" ">>"'));
        });
      });
    });
  });
}
