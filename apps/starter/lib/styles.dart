import 'package:jaspr/jaspr.dart';

import 'app.dart';
import 'components/counter.dart';
import 'components/header.dart';

const primaryColor = Color.hex('#01589B');
const secondaryColor = Color.hex('#41C3FE');

/// The main styles for this app.
final styles = [
  StyleRule.import('https://fonts.googleapis.com/css?family=Roboto'),
  css('html, body')
      .text(fontFamily: FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
      .box(width: 100.percent, constraints: BoxConstraints(minHeight: 100.vh))
      .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
  ...App.styles,
  ...Header.styles,
  ...Counter.styles,
];
