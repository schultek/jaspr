import 'package:jaspr/jaspr.dart';

@Import.onWeb(
  'dart:html',
  show: [#window, #document, #HtmlDocument, #Element, #CustomEvent, #MouseEvent, #KeyboardEvent, #Event, #InputElement],
)
export 'html.imports.dart';
