@TestOn('vm')
library;

import 'package:jaspr/dom.dart';
import 'package:jaspr_test/jaspr_test.dart';

void main() {
  group('style', () {
    group('combine', () {
      test('combines raw styles', () {
        final styles = const Styles.combine([
          Styles(raw: {'a': 'b', 'c': 'd'}),
          Styles(raw: {'c': 'e', 'f': 'g'}),
        ]);

        expect(styles.properties, equals({'a': 'b', 'c': 'e', 'f': 'g'}));
      });

      test('combines typed styles', () {
        final styles = const Styles.combine([
          Styles(fontSize: Unit.pixels(12), fontFamily: FontFamily('Roboto')),
          Styles(fontSize: Unit.pixels(14)),
        ]);

        expect(styles.properties, equals({'font-size': '14px', 'font-family': "'Roboto'"}));
      });
    });

    group('properties', () {
      final styles = const Styles(
        all: All.initial,
        // Box Styles
        content: 'test',
        display: Display.inlineBlock,
        position: Position.absolute(top: Unit.pixels(100)),
        zIndex: ZIndex(100),
        width: Unit.percent(80),
        height: Unit.percent(70),
        minWidth: Unit.pixels(100),
        minHeight: Unit.em(2),
        maxWidth: Unit.pixels(1000),
        maxHeight: Unit.vh(100),
        aspectRatio: AspectRatio(1, 2),
        padding: Padding.all(Unit.pixels(20)),
        margin: Margin.zero,
        boxSizing: BoxSizing.borderBox,
        border: Border.only(
          top: BorderSide(style: BorderStyle.solid, color: Colors.green),
        ),
        radius: BorderRadius.circular(Unit.pixels(20)),
        outline: Outline(color: Colors.yellow),
        opacity: 0.5,
        visibility: Visibility.visible,
        overflow: Overflow.visible,
        appearance: Appearance.baseSelect,
        shadow: BoxShadow(offsetX: Unit.zero, offsetY: Unit.zero, blur: Unit.pixels(10)),
        filter: Filter.grayscale(0.5),
        backdropFilter: Filter.blur(Unit.pixels(6)),
        cursor: Cursor.crosshair,
        userSelect: UserSelect.none,
        pointerEvents: PointerEvents.fill,
        animation: Animation(duration: Duration(milliseconds: 100), name: 'slide'),
        transition: Transition('width', duration: Duration(milliseconds: 500)),
        transform: Transform.scale(2),
        // Flexbox Styles
        flexDirection: FlexDirection.column,
        flexWrap: FlexWrap.nowrap,
        justifyContent: JustifyContent.center,
        alignItems: AlignItems.start,
        alignContent: AlignContent.center,
        // Grid Styles
        gridTemplate: GridTemplate(areas: GridAreas(['header header', 'side content', 'side content'])),
        autoRows: [TrackSize(Unit.percent(20)), TrackSize.auto],
        autoColumns: [TrackSize(Unit.pixels(100)), TrackSize.auto, TrackSize.auto],
        justifyItems: JustifyItems.center,
        gap: Gap.row(Unit.pixels(20)),
        // Flex Item Styles
        flex: Flex(grow: 2, shrink: 1, basis: Unit.auto),
        order: 2,
        alignSelf: AlignSelf.start,
        justifySelf: JustifySelf.start,
        gridPlacement: GridPlacement.area('content'),
        // List Styles
        listStyle: ListStyle.circle,
        listImage: ImageStyle.url('abc.png'),
        listPosition: ListStylePosition.inside,
        // Text Styles
        color: Colors.blue,
        textAlign: TextAlign.center,
        fontFamily: FontFamily('Roboto'),
        fontSize: Unit.pixels(12),
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        textDecoration: TextDecoration(line: TextDecorationLine.underline),
        textTransform: TextTransform.lowerCase,
        textIndent: Unit.pixels(8),
        letterSpacing: Unit.em(0.5),
        wordSpacing: Unit.points(10),
        lineHeight: Unit.rem(1.5),
        textShadow: TextShadow(offsetX: Unit.zero, offsetY: Unit.zero, blur: Unit.pixels(10)),
        textOverflow: TextOverflow.ellipsis,
        whiteSpace: WhiteSpace.noWrap,
        quotes: Quotes(('<', '>')),
        // Background Styles
        backgroundColor: Colors.red,
        backgroundImage: ImageStyle.url('abc.png'),
        backgroundOrigin: BackgroundOrigin.contentBox,
        backgroundPosition: BackgroundPosition(
          alignX: BackgroundAlignX.left,
          alignY: BackgroundAlignY.center,
          offsetX: Unit.percent(20),
        ),
        backgroundAttachment: BackgroundAttachment.fixed,
        backgroundRepeat: BackgroundRepeat.noRepeat,
        backgroundSize: BackgroundSize.cover,
        backgroundClip: BackgroundClip.borderBox,
        // Raw Styles
        raw: {'other': 'value'},
      );

      test('outputs all properties', () {
        expect(
          styles.properties,
          equals({
            'all': 'initial',
            // Box Styles
            'content': '"test"',
            'display': 'inline-block',
            'position': 'absolute',
            'top': '100px',
            'z-index': '100',
            'width': '80%',
            'height': '70%',
            'min-width': '100px',
            'min-height': '2em',
            'max-width': '1000px',
            'max-height': '100vh',
            'aspect-ratio': '1/2',
            'padding': '20px',
            'margin': '0',
            'box-sizing': 'border-box',
            'border-top-style': 'solid',
            'border-top-color': 'green',
            'border-radius': '20px',
            'outline-color': 'yellow',
            'opacity': '0.5',
            'visibility': 'visible',
            'overflow': 'visible',
            'appearance': 'base-select',
            'box-shadow': '0 0 10px',
            'filter': 'grayscale(0.5)',
            'backdrop-filter': 'blur(6px)',
            'cursor': 'crosshair',
            'user-select': 'none',
            '-webkit-user-select': 'none',
            'pointer-events': 'fill',
            'animation': '100ms slide',
            'transition': 'width 500ms',
            'transform': 'scale(2)',
            // Flexbox Styles
            'flex-direction': 'column',
            'flex-wrap': 'nowrap',
            'justify-content': 'center',
            'align-items': 'start',
            'align-content': 'center',
            // Grid Styles
            'grid-template-areas':
                '"header header"\n'
                '"side content"\n'
                '"side content"',
            'grid-auto-rows': '20% auto',
            'grid-auto-columns': '100px auto auto',
            'justify-items': 'center',
            'row-gap': '20px',
            // Flex Item Styles
            'flex-grow': '2',
            'flex-shrink': '1',
            'flex-basis': 'auto',
            'order': '2',
            'align-self': 'start',
            'justify-self': 'start',
            'grid-area': 'content',
            // List Styles
            'list-style-type': 'circle',
            'list-style-image': 'url(abc.png)',
            'list-style-position': 'inside',
            // Text Styles
            'color': 'blue',
            'text-align': 'center',
            'font-family': "'Roboto'",
            'font-size': '12px',
            'font-weight': 'bold',
            'font-style': 'italic',
            'text-decoration': 'underline',
            'text-transform': 'lowercase',
            'text-indent': '8px',
            'letter-spacing': '0.5em',
            'word-spacing': '10pt',
            'line-height': '1.5rem',
            'text-shadow': '0 0 10px',
            'text-overflow': 'ellipsis',
            'white-space': 'nowrap',
            'quotes': '"<" ">"',
            // Background Styles
            'background-color': 'red',
            'background-image': 'url(abc.png)',
            'background-origin': 'content-box',
            'background-position': 'left 20% center',
            'background-attachment': 'fixed',
            'background-repeat': 'no-repeat',
            'background-size': 'cover',
            'background-clip': 'border-box',
            // Raw Styles
            'other': 'value',
          }),
        );
      });

      test('renders all properties in correct order', () {
        expect(
          StyleRule(selector: Selector('div'), styles: styles).toCss(),
          equals(
            'div {\n'
            '  all: initial;\n'
            '  content: "test";\n'
            '  display: inline-block;\n'
            '  position: absolute;\n'
            '  top: 100px;\n'
            '  z-index: 100;\n'
            '  width: 80%;\n'
            '  height: 70%;\n'
            '  min-width: 100px;\n'
            '  min-height: 2em;\n'
            '  max-width: 1000px;\n'
            '  max-height: 100vh;\n'
            '  aspect-ratio: 1/2;\n'
            '  padding: 20px;\n'
            '  margin: 0;\n'
            '  box-sizing: border-box;\n'
            '  border-top-style: solid;\n'
            '  border-top-color: green;\n'
            '  border-radius: 20px;\n'
            '  outline-color: yellow;\n'
            '  opacity: 0.5;\n'
            '  visibility: visible;\n'
            '  overflow: visible;\n'
            '  appearance: base-select;\n'
            '  box-shadow: 0 0 10px;\n'
            '  filter: grayscale(0.5);\n'
            '  backdrop-filter: blur(6px);\n'
            '  cursor: crosshair;\n'
            '  user-select: none;\n'
            '  -webkit-user-select: none;\n'
            '  pointer-events: fill;\n'
            '  animation: 100ms slide;\n'
            '  transition: width 500ms;\n'
            '  transform: scale(2);\n'
            '  flex-direction: column;\n'
            '  flex-wrap: nowrap;\n'
            '  justify-content: center;\n'
            '  align-items: start;\n'
            '  align-content: center;\n'
            '  grid-template-areas: "header header"\n'
            '"side content"\n'
            '"side content";\n'
            '  grid-auto-rows: 20% auto;\n'
            '  grid-auto-columns: 100px auto auto;\n'
            '  justify-items: center;\n'
            '  row-gap: 20px;\n'
            '  flex-grow: 2;\n'
            '  flex-shrink: 1;\n'
            '  flex-basis: auto;\n'
            '  order: 2;\n'
            '  align-self: start;\n'
            '  justify-self: start;\n'
            '  grid-area: content;\n'
            '  list-style-type: circle;\n'
            '  list-style-image: url(abc.png);\n'
            '  list-style-position: inside;\n'
            '  color: blue;\n'
            '  text-align: center;\n'
            '  font-family: \'Roboto\';\n'
            '  font-size: 12px;\n'
            '  font-weight: bold;\n'
            '  font-style: italic;\n'
            '  text-decoration: underline;\n'
            '  text-transform: lowercase;\n'
            '  text-indent: 8px;\n'
            '  letter-spacing: 0.5em;\n'
            '  word-spacing: 10pt;\n'
            '  line-height: 1.5rem;\n'
            '  text-shadow: 0 0 10px;\n'
            '  text-overflow: ellipsis;\n'
            '  white-space: nowrap;\n'
            '  quotes: "<" ">";\n'
            '  background-color: red;\n'
            '  background-image: url(abc.png);\n'
            '  background-origin: content-box;\n'
            '  background-position: left 20% center;\n'
            '  background-attachment: fixed;\n'
            '  background-repeat: no-repeat;\n'
            '  background-size: cover;\n'
            '  background-clip: border-box;\n'
            '  other: value;\n'
            '}',
          ),
        );
      });
    });
  });
}
