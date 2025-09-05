@TestOn('vm')
library;

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style group', () {
    group('raw', () {
      test('outputs raw styles', () {
        var styles = const Styles(raw: {'a': 'b', 'c': 'd'});

        expect(styles.properties, equals({'a': 'b', 'c': 'd'}));
      });
    });

    group('combine', () {
      test('combines raw styles', () {
        var styles = const Styles.combine([
          Styles(raw: {'a': 'b', 'c': 'd'}),
          Styles(raw: {'c': 'e', 'f': 'g'}),
        ]);

        expect(
          styles.properties,
          equals({
            'a': 'b',
            'c': 'e',
            'f': 'g',
          }),
        );
      });

      test('combines typed styles', () {
        var styles = const Styles.combine([
          Styles(
            fontSize: Unit.pixels(12),
            fontFamily: FontFamily('Roboto'),
          ),
          Styles(
            fontSize: Unit.pixels(14),
          ),
        ]);

        expect(
          styles.properties,
          equals({
            'font-size': '14px',
            'font-family': "'Roboto'",
          }),
        );
      });
    });

    group('text', () {
      test('outputs all properties', () {
        var styles = const Styles(
          color: Colors.blue,
          textAlign: TextAlign.center,
          fontFamily: FontFamily('Roboto'),
          fontStyle: FontStyle.italic,
          fontSize: Unit.pixels(12),
          fontWeight: FontWeight.bold,
          textDecoration: TextDecoration(line: TextDecorationLine.underline),
          textTransform: TextTransform.lowerCase,
          textIndent: Unit.pixels(8),
          letterSpacing: Unit.em(0.5),
          wordSpacing: Unit.points(10),
          lineHeight: Unit.rem(1.5),
          textShadow: TextShadow(offsetX: Unit.zero, offsetY: Unit.zero, blur: Unit.pixels(10)),
          textOverflow: TextOverflow.ellipsis,
        );

        expect(
          styles.properties,
          equals({
            'color': 'blue',
            'text-align': 'center',
            'font-family': "'Roboto'",
            'font-style': 'italic',
            'font-size': '12px',
            'font-weight': 'bold',
            'text-decoration': 'underline',
            'text-transform': 'lowercase',
            'text-indent': '8px',
            'letter-spacing': '0.5em',
            'word-spacing': '10pt',
            'line-height': '1.5rem',
            'text-shadow': '0 0 10px',
            'text-overflow': 'ellipsis'
          }),
        );
      });
    });

    group('background', () {
      test('outputs all properties', () {
        var styles = const Styles(
          backgroundColor: Colors.red,
          backgroundAttachment: BackgroundAttachment.fixed,
          backgroundClip: BackgroundClip.borderBox,
          backgroundImage: ImageStyle.url('abc.png'),
          backgroundOrigin: BackgroundOrigin.contentBox,
          backgroundPosition: BackgroundPosition(
            alignX: BackgroundAlignX.left,
            alignY: BackgroundAlignY.center,
            offsetX: Unit.percent(20),
          ),
          backgroundRepeat: BackgroundRepeat.noRepeat,
          backgroundSize: BackgroundSize.cover,
        );

        expect(
          styles.properties,
          equals({
            'background-color': 'red',
            'background-attachment': 'fixed',
            'background-clip': 'border-box',
            'background-image': 'url(abc.png)',
            'background-origin': 'content-box',
            'background-position': 'left 20% center',
            'background-repeat': 'no-repeat',
            'background-size': 'cover'
          }),
        );
      });
    });

    group('box', () {
      test('outputs all properties', () {
        var styles = const Styles(
          padding: Padding.all(Unit.pixels(20)),
          margin: Margin.zero,
          display: Display.inlineBlock,
          boxSizing: BoxSizing.borderBox,
          width: Unit.percent(80),
          height: Unit.percent(70),
          maxWidth: Unit.pixels(1000),
          border: Border.only(top: BorderSide(style: BorderStyle.solid, color: Colors.green)),
          radius: BorderRadius.circular(Unit.pixels(20)),
          outline: Outline(color: Colors.yellow),
          overflow: Overflow.visible,
          visibility: Visibility.visible,
          position: Position.absolute(top: Unit.pixels(100)),
          zIndex: ZIndex(100),
          opacity: 0.5,
          transform: Transform.scale(2),
          shadow: BoxShadow(offsetX: Unit.zero, offsetY: Unit.zero, blur: Unit.pixels(10)),
          cursor: Cursor.crosshair,
          transition: Transition('width', duration: 500),
          all: All.initial,
        );

        expect(
          styles.properties,
          equals({
            'padding': '20px',
            'margin': '0',
            'display': 'inline-block',
            'box-sizing': 'border-box',
            'width': '80%',
            'height': '70%',
            'max-width': '1000px',
            'border-top-style': 'solid',
            'border-top-color': 'green',
            'border-radius': '20px',
            'outline-color': 'yellow',
            'overflow': 'visible',
            'visibility': 'visible',
            'position': 'absolute',
            'top': '100px',
            'z-index': '100',
            'opacity': '0.5',
            'transform': 'scale(2)',
            'box-shadow': '0 0 10px',
            'cursor': 'crosshair',
            'transition': 'width 500ms',
            'all': 'initial',
          }),
        );
      });
    });

    group('filter', () {
      test('outputs all properties', () {
        var styles = const Styles(
          filter: Filter.list([
            Filter.blur(),
            Filter.brightness(),
            Filter.contrast(),
            Filter.dropShadow(offsetX: Unit.rem(1), offsetY: Unit.rem(1)),
            Filter.grayscale(),
            Filter.hueRotate(),
            Filter.invert(),
            Filter.opacity(),
            Filter.sepia(),
            Filter.saturate(),
            Filter.url("abc.svg#urltest"),
          ]),
          backdropFilter: Filter.list([
            Filter.blur(Unit.rem(0.1)),
            Filter.brightness(0.2),
            Filter.contrast(0.3),
            Filter.dropShadow(offsetX: Unit.rem(1), offsetY: Unit.rem(1), spread: Unit.rem(0.4), color: Colors.red),
            Filter.grayscale(0.5),
            Filter.hueRotate(Angle.deg(45)),
            Filter.invert(0.6),
            Filter.opacity(0.7),
            Filter.sepia(0.8),
            Filter.saturate(0.9),
            Filter.url("xyz.svg#urltest"),
          ]),
        );

        expect(
          styles.properties,
          equals({
            'filter': 'blur(0) brightness(1) contrast(1) '
                'drop-shadow(1rem 1rem) grayscale(1) hue-rotate(0) '
                'invert(1) opacity(1) sepia(1) saturate(1) url(abc.svg#urltest)',
            'backdrop-filter': 'blur(0.1rem) brightness(0.2) contrast(0.3) '
                'drop-shadow(1rem 1rem 0.4rem red) grayscale(0.5) hue-rotate(45deg) '
                'invert(0.6) opacity(0.7) sepia(0.8) saturate(0.9) url(xyz.svg#urltest)',
          }),
        );
      });

      test("Filter.list does not allow empty list", () {
        final filter = Filter.list([]);
        expect(
          () => filter.value,
          throwsA(predicate((e) {
            return e == 'Filter.list cannot be empty.';
          })),
        );
      });

      test("Filter.list does not allow nesting another Filter.list", () {
        final nestedFilter = Filter.list([Filter.list([])]);
        expect(
          () => nestedFilter.value,
          throwsA(predicate((e) {
            return e == 'Cannot nest [Filter.list] inside [Filter.list].';
          })),
        );
      });

      test("Filter.list does not allow non-listable members", () {
        for (final val in const <Filter>[
          Filter.none,
          Filter.initial,
          Filter.revert,
          Filter.revertLayer,
          Filter.unset,
        ]) {
          final filter = Filter.list([val]);
          expect(
            () => filter.value,
            throwsA(predicate((e) {
              return e ==
                  'Cannot use ${val.value} as a filter list item, '
                      'only standalone use supported.';
            })),
          );
        }
      });
    });
  });

  group('flexbox', () {
    test('outputs all properties', () {
      var styles = const Styles(
        flexDirection: FlexDirection.column,
        flexWrap: FlexWrap.nowrap,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.start,
        alignContent: AlignContent.center,
      );

      expect(
        styles.properties,
        equals({
          'flex-direction': 'column',
          'flex-wrap': 'nowrap',
          'justify-content': 'center',
          'align-items': 'start',
          'align-content': 'center',
        }),
      );
    });
  });

  group('flexitem', () {
    test('outputs all properties', () {
      var styles = const Styles(
        flex: Flex(grow: 2, shrink: 1, basis: Unit.auto),
        order: 2,
        alignSelf: AlignSelf.start,
      );

      expect(
        styles.properties,
        equals({
          'flex-grow': '2',
          'flex-shrink': '1',
          'flex-basis': 'auto',
          'order': '2',
          'align-self': 'start',
        }),
      );
    });
  });

  group('grid', () {
    test('outputs all properties', () {
      var styles = const Styles(
        gridTemplate: GridTemplate(
            areas: GridAreas([
          'header header',
          'side content',
          'side content',
        ])),
        gap: Gap(row: Unit.pixels(20)),
        autoRows: [TrackSize(Unit.percent(20)), TrackSize.auto],
        autoColumns: [TrackSize(Unit.pixels(100)), TrackSize.auto, TrackSize.auto],
        justifyItems: JustifyItems.center,
      );

      expect(
        styles.properties,
        equals({
          'grid-template-areas': '"header header"\n'
              '"side content"\n'
              '"side content"',
          'grid-auto-rows': '20% auto',
          'grid-auto-columns': '100px auto auto',
          'row-gap': '20px',
          'justify-items': 'center',
        }),
      );
    });
  });

  group('griditem', () {
    test('outputs all properties', () {
      var styles = const Styles(
        gridPlacement: GridPlacement.area('content'),
        justifySelf: JustifySelf.start,
      );

      expect(
        styles.properties,
        equals({
          'grid-area': 'content',
          'justify-self': 'start',
        }),
      );
    });
  });
}
