import 'dart:html';

import 'package:dart_web/src/web_app.dart';
import 'package:domino/browser.dart' hide DomComponent;

import '../../dart_web.dart';

export '../../dart_web.dart';

class BrowserWebApp extends WebApp {
  BrowserWebApp(this.view);

  final DomView view;
}

Future<BrowserWebApp> runApp(Component app, {required String id}) async {
  var root = StateStore(child: DomComponent(tag: 'div', id: id, child: app));

  root.parse(document.body!.attributes['data-app'] ?? '{}');
  document.body!.attributes.remove('data-app');

  var rootElement = root.createElement();

  await rootElement.mount(null);
  await rootElement.rebuild();

  var view = registerView(root: document.body!, builderFn: rootElement.render);

  return BrowserWebApp(view);
}
