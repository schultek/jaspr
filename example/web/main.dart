import 'dart:html';

import 'package:dart_web/dart_web.dart';
import 'package:dart_web_example/components/app.dart';

void main() {
  var d = window.performance.now();
  // provide an entry component and an id to attach it to
  runApp(App.new, id: 'app');
  AppBinding.instance!.firstBuild.whenComplete(() {
    print("FIRST RENDER TOOK ${window.performance.now() - d} ms");
  });
}
