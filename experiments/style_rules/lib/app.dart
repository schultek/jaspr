import 'package:jaspr/jaspr.dart';
import 'package:jaspr/styles.dart';

class App extends StatelessComponent {
  @override
  Iterable<Component> build(BuildContext context) sync* {
    if (kIsWeb) {
      yield SkipChildComponent();
    } else {
      yield Style(styles: [
        StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
        StyleRule(
          selector: Selector.list([Selector.tag('html'), Selector.tag('body')]),
          styles: Styles.combine([
            Styles.text(
              fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
            ),
            Styles.box(
              padding: EdgeInsets.zero,
              margin: EdgeInsets.zero,
              width: 100.percent,
              height: 100.percent,
            ),
          ]),
        ),
        StyleRule(
          selector: Selector.id('output'),
          styles: Styles.combine([
            Styles.text(align: TextAlign.center),
            Styles.box(padding: EdgeInsets.all(20.px)),
          ]),
        ),
        StyleRule(
          selector: Selector.tag('p'),
          styles: Styles.combine([
            Styles.text(color: Colors.red),
          ]),
        ),
        StyleRule(
          selector: Selector.list([
            Selector.id('header'),
            Selector.tag('p').dot('abc').sibling(Selector.tag('span')),
          ]),
          styles: Styles.background(color: Colors.blanchedAlmond),
        ),
      ]);
    }
    yield DomComponent(
      tag: 'p',
      child: Text('Hello World'),
    );
  }
}
