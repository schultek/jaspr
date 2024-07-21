import 'package:jaspr/jaspr.dart';

// The main styles for this app.
//
// By using the @css annotation, these will be rendered automatically to css inside the <head> of your page.
// Must be a variable or getter (top-level or static ) that returns a [List<StyleRule>].
@css
final styles = [
  // Each style rule takes a valid css selector and a set of styles.
  // Styles are defined using type-safe css bindings and can be freely chained and nested.
  css('html, body')
      .text(fontFamily: const FontFamily.list([FontFamily('Roboto'), FontFamilies.sansSerif]))
      .box(width: 100.percent, minHeight: 100.vh)
      .box(margin: EdgeInsets.zero, padding: EdgeInsets.zero),
  css('h1').text(fontSize: 4.rem).box(margin: EdgeInsets.unset),
  // Special css import rule to include to another css file.
  css.import('https://fonts.googleapis.com/css?family=Roboto'),
];

// As your css styles are defined using just Dart, you can also use
// variables or methods for common things like e.g. colors.
const primaryColor = Color.hex('#01589B');
