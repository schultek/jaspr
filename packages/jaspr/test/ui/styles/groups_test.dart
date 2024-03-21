@TestOn('vm')

import 'package:jaspr/jaspr.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style group', () {
    group('raw', () {
      test('outputs raw styles', () {
        var styles = const Styles.raw({'a': 'b', 'c': 'd'});

        expect(styles.styles, equals({'a': 'b', 'c': 'd'}));
      });
    });

    group('combine', () {
      test('combines raw styles', () {
        var styles = const Styles.combine([
          Styles.raw({'a': 'b', 'c': 'd'}),
          Styles.raw({'c': 'e', 'f': 'g'}),
        ]);

        expect(
          styles.styles,
          equals({
            'a': 'b',
            'c': 'e',
            'f': 'g',
          }),
        );
      });

      test('combines typed styles', () {
        var styles = const Styles.combine([
          Styles.text(
            fontSize: Unit.pixels(12),
            fontFamily: FontFamily('Roboto'),
          ),
          Styles.text(
            fontSize: Unit.pixels(14),
          ),
        ]);

        expect(
          styles.styles,
          equals({
            'font-size': '14px',
            'font-family': "'Roboto'",
          }),
        );
      });
    });

    group('text', () {
      test('outputs all properties', () {
        var styles = const Styles.text(
          color: Colors.blue,
          align: TextAlign.center,
          fontFamily: FontFamily('Roboto'),
          fontStyle: FontStyle.italic,
          fontSize: Unit.pixels(12),
          fontWeight: FontWeight.bold,
          decoration: TextDecoration(line: TextDecorationLine.underline),
          transform: TextTransform.lowerCase,
          indent: Unit.pixels(8),
          letterSpacing: Unit.em(0.5),
          wordSpacing: Unit.points(10),
          lineHeight: Unit.rem(1.5),
          shadow: TextShadow(offsetX: Unit.zero, offsetY: Unit.zero, blur: Unit.pixels(10)),
          overflow: TextOverflow.ellipsis,
        );

        expect(
          styles.styles,
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
        var styles = const Styles.background(
          color: Colors.red,
          attachment: BackgroundAttachment.fixed,
          clip: BackgroundClip.borderBox,
          image: ImageStyle.url('abc.png'),
          origin: BackgroundOrigin.contentBox,
          position: BackgroundPosition(
            alignX: BackgroundAlignX.left,
            alignY: BackgroundAlignY.center,
            offsetX: Unit.percent(20),
          ),
          repeat: BackgroundRepeat.noRepeat,
          size: BackgroundSize.cover,
        );

        expect(
          styles.styles,
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
        var styles = const Styles.box(
          padding: EdgeInsets.all(Unit.pixels(20)),
          margin: EdgeInsets.zero,
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
          opacity: 0.5,
          transform: Transform.scale(2),
          shadow: BoxShadow(offsetX: Unit.zero, offsetY: Unit.zero, blur: Unit.pixels(10)),
          cursor: Cursor.crosshair,
          transition: Transition('width', duration: 500),
        );

        expect(
          styles.styles,
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
        var styles = const Styles.flexbox(
          direction: FlexDirection.column,
          wrap: FlexWrap.nowrap,
          justifyContent: JustifyContent.center,
          alignItems: AlignItems.start,
        );

        expect(
          styles.styles,
          equals({
            'display': 'flex',
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
        var styles = const Styles.flexItem(
          flex: Flex(grow: 2, shrink: 1, basis: FlexBasis.auto),
          order: 2,
          alignSelf: AlignSelf.start,
        );

        expect(
          styles.styles,
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
        var styles = const Styles.grid(
          template: GridTemplate(
              areas: GridAreas([
            'header header',
            'side content',
            'side content',
          ])),
          gap: GridGap(row: Unit.pixels(20)),
          autoRows: [TrackSize(Unit.percent(20)), TrackSize.auto],
          autoColumns: [TrackSize(Unit.pixels(100)), TrackSize.auto, TrackSize.auto],
        );

        expect(
          styles.styles,
          equals({
            'display': 'grid',
            'grid-template-areas': '"header header"\n'
                '"side content"\n'
                '"side content"',
            'grid-auto-rows': '20% auto',
            'grid-auto-columns': '100px auto auto'
          }),
        );
      });
    });

    group('griditem', () {
      test('outputs all properties', () {
        var styles = const Styles.gridItem(
          placement: GridPlacement.area('content'),
        );

        expect(
          styles.styles,
          equals({
            'grid-area': 'content',
          }),
        );
      });
    });
  });
}
