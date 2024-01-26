import 'package:jaspr/jaspr.dart';
import 'package:myapp/components/header.dart';

import 'components/home.dart';

const primaryColor = Color.hex('#01589B');
const secondaryColor = Color.hex('#41C3FE');

/// The main styles for this app.
final styles = [
  StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
  StyleRule(
    // Applies these styles to the html and body elements.
    selector: Selector.list([Selector.tag('html'), Selector.tag('body')]),
    styles: Styles.combine([
      Styles.text(
        fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]),
      ),
      Styles.box(
        width: Unit.percent(100),
        height: Unit.percent(100),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
      ),
    ]),
  ),
  ...headerStyles,
  ...homeStyles,
];
