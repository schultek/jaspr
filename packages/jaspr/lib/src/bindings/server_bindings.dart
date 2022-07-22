import 'dart:async';
import 'dart:convert';

import 'package:domino/markup.dart' hide DomComponent, DomElement;
import 'package:html/parser.dart';

import '../foundation/basic_types.dart';
import '../foundation/binding.dart';
import '../foundation/scheduler.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';
import '../server/server_app.dart';

/// Main entry point on the server
void runApp(Component app, {String attachTo = 'body'}) {
  runServer(app, attachTo: attachTo);
}

/// Same as [runApp] but returns an instance of [ServerApp] to control aspects of the http server
ServerApp runServer(Component app, {String attachTo = 'body'}) {
  return ServerApp.run(() {
    AppBinding.ensureInitialized().attachRootComponent(app, attachTo: attachTo);
  });
}

/// Global component binding for the server
class AppBinding extends BindingBase with ComponentsBinding, SyncBinding, SchedulerBinding {
  static AppBinding ensureInitialized() {
    if (ComponentsBinding.instance == null) {
      AppBinding();
    }
    return ComponentsBinding.instance! as AppBinding;
  }

  @override
  Uri get currentUri => _currentUri!;
  Uri? _currentUri;

  void setCurrentUri(Uri uri) {
    _currentUri = uri;
  }

  String? _targetId;

  @override
  bool get isClient => false;

  final rootCompleter = Completer.sync();

  @override
  void didAttachRootElement(BuildScheduler element, {required String to}) {
    _targetId = to;
    rootCompleter.complete();
  }

  Future<String> render(String rawHtml) async {
    await rootCompleter.future;

    var document = parse(rawHtml);
    var appElement = document.querySelector(_targetId!)!;
    appElement.innerHtml = renderMarkup(builderFn: rootElements.values.first.render);

    document.body!.attributes['state-data'] = stateCodec.encode(getStateData());
    return document.outerHtml;
  }

  Future<String> data() async {
    await rootCompleter.future;
    return jsonEncode(getStateData());
  }

  @override
  dynamic getRawState(String id) => null;

  @override
  Future<Map<String, String>> fetchState(String url) {
    throw 'Cannot fetch state on the server';
  }

  @override
  void updateRawState(String id, dynamic state) {}

  @override
  DomView registerView(dynamic root, DomBuilderFn builderFn, bool initialRender) {
    return NullDomView();
  }

  @override
  void scheduleBuild(VoidCallback buildCallback) {
    throw UnsupportedError('Scheduling a build is not supported on the server, and should never happen.');
  }
}

class NullDomView implements DomView {
  @override
  Future<void>? dispose() => null;

  @override
  Future<void>? invalidate() => null;

  @override
  void update() {}
}
