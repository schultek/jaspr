@TestOn('vm')

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
          }),
        );
      });
    });

    group('flexbox', () {
      test('outputs all properties', () {
        var styles = const Styles(
          flexDirection: FlexDirection.column,
          flexWrap: FlexWrap.nowrap,
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.start,
        );

        expect(
          styles.properties,
          equals({
            'flex-direction': 'column',
            'flex-wrap': 'nowrap',
            'justify-content': 'center',
            'align-items': 'start',
          }),
        );
      });
    });

    group('flexitem', () {
      test('outputs all properties', () {
        var styles = const Styles(
          flex: Flex(grow: 2, shrink: 1, basis: FlexBasis.auto),
          order: 2,
          alignSelf: AlignSelf.start,
        );

        expect(
          styles.properties,
          equals({
            'flex': '2 1 auto',
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
          }),
        );
      });
    });

    group('griditem', () {
      test('outputs all properties', () {
        var styles = const Styles(
          gridPlacement: GridPlacement.area('content'),
        );

        expect(
          styles.properties,
          equals({
            'grid-area': 'content',
          }),
        );
      });
    });
  });
}
