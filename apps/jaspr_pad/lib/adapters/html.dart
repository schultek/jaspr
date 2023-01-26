import 'package:jaspr/jaspr.dart';

@Import.onWeb('dart:html', show: [
  #window,
  #document,
  #HtmlDocument,
  #CustomEvent,
  #MouseEvent,
  #Event,
])
export 'html.imports.dart';
