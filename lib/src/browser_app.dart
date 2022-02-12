import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:domino/browser.dart' hide DomComponent;

import 'framework/framework.dart';

/// Main entry point for the browser app
void runApp(Component Function() setup, {required String id}) {
  BrowserAppBinding.ensureInitialized().attachRootComponent(setup(), to: id);
}

/// Global app binding for the browser
class BrowserAppBinding extends AppBinding {
  static AppBinding ensureInitialized() {
    if (AppBinding.instance == null) {
      BrowserAppBinding();
    }
    return AppBinding.instance!;
  }

  @override
  Map<String, dynamic> loadStateData() {
    var body = document.body!;
    return jsonDecode(body.attributes.remove('data-app') ?? '{}');
  }

  @override
  void attachRootElement(BuildScheduler element, {required String to}) async {
    await firstBuild;
    element.view = registerView(
      root: document.getElementById(to)!,
      builderFn: element.render,
    );
  }

  @override
  Uri get currentUri => Uri.parse(window.location.toString());

  @override
  FutureOr<void> performRebuild(Element? child) {
    if (child is StatefulElement && child.state is DeferRenderMixin && isFirstBuild) {
      return Future.sync(() async {
        await (child.state as DeferRenderMixin).defer;
        return super.performRebuild(child);
      });
    } else {
      return super.performRebuild(child);
    }
  }
}
