import 'package:jaspr/server.dart';
import 'package:jaspr/html.dart';

import 'components/demo_controls.dart';
import 'components/flutter_target.dart';

void main() {
  runApp(Document(
    title: 'Element embedding',
    meta: {
      'description': 'A Flutter Web Element embedding demo.',
    },
    head: [
      DomComponent(tag: 'script', attributes: {'src': 'flutter.js', 'defer': ''}),
      DomComponent(tag: 'link', attributes: {'rel': 'stylesheet', 'href': 'css/style.css', 'type': 'text/css'}),
    ],
    scriptName: 'main_jaspr',
    body: section(classes: [
      'contents'
    ], [
      FlutterTarget(),
      aside(id: 'demo_controls', [DemoControls()]),
    ]),
  ));
}
