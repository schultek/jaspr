import 'package:jaspr/server.dart';
import 'components/app.dart';

void main() {
  runApp(Document.app(
    title: 'platform_test',
    styles: [
      StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
      StyleRule(
        selector: const Selector.list([Selector.tag('html'), Selector.tag('body')]),
        styles: Styles.combine([
          const Styles.text(
            fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
          ),
          Styles.box(
            width: 100.percent,
            height: 100.percent,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
          ),
        ]),
      ),
    ],
    body: App(),
  ));
}