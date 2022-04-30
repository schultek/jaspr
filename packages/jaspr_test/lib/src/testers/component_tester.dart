import 'dart:async';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:jaspr/jaspr.dart';

import '../../jaspr_test.dart';
import '../dom_tester.dart';

class ComponentTester {
  ComponentTester._(this.binding);

  final TestComponentsBinding binding;

  static ComponentTester setUp({String? html, String id = 'app', Uri? currentUri, bool isClient = false}) {
    tearDown();
    var binding = TestComponentsBinding(html, id, currentUri, isClient);
    return ComponentTester._(binding);
  }

  static void tearDown() {
    if (ComponentsBinding.instance is TestComponentsBinding) {
      // TODO release any resources
    }
  }

  Future<void> pumpComponent(Component component) {
    binding.attachRootComponent(component, attachTo: binding._id);
    return binding.firstBuild;
  }

  Future<void> click(Finder finder, {bool pump = true}) async {
    dispatchEvent(finder, 'click', null);
    if (pump) {
      await pumpEventQueue();
    }
  }

  Future<void> pump() async {
    await pumpEventQueue();
  }

  void dispatchEvent(Finder finder, String event, dynamic data) {
    var element = _findDomElement(finder);

    var source = element.source as dom.Element;
    var data = source.getData();

    data?.events?[event]?.dispatch(data);
  }

  DomElement _findDomElement(Finder finder) {
    var elements = finder.evaluate();

    if (elements.isEmpty) {
      throw 'The finder "$finder" could not find any matching components.';
    }
    if (elements.length > 1) {
      throw 'The finder "$finder" ambiguously found multiple matching components.';
    }

    var element = elements.single;

    if (element is DomElement) {
      return element;
    }

    DomElement? _foundElement;

    void _findFirstDomElement(Element e) {
      if (e is DomElement) {
        _foundElement = e;
        return;
      }
      e.visitChildren(_findFirstDomElement);
    }

    _findFirstDomElement(element);

    if (_foundElement == null) {
      throw 'The finder "$finder" could not find a dom element.';
    }

    return _foundElement!;
  }
}

class TestComponentsBinding extends ComponentsBinding {
  static TestComponentsBinding get instance => ComponentsBinding.instance as TestComponentsBinding;

  TestComponentsBinding(this._html, this._id, this._currentUri, this._isClient);

  final String? _html;
  final String _id;

  final Uri? _currentUri;
  @override
  Uri get currentUri => _currentUri ?? (throw 'Did not call setUp() with currentUri provided.');

  final bool _isClient;
  @override
  bool get isClient => _isClient;

  Completer? _rootViewCompleter;

  @override
  Future<void> get firstBuild => _rootViewCompleter!.future;

  @override
  void attachRootComponent(Component app, {required String attachTo}) {
    _rootViewCompleter = Completer();
    super.attachRootComponent(app, attachTo: attachTo);
  }

  @override
  void didAttachRootElement(BuildScheduler element, {required String to}) async {
    await super.firstBuild;

    var document = parse(_html ?? '<html><head></head><body><div id="$to"></div></body></html>');

    element.view = registerView(
      document: document,
      root: document.getElementById(to)!,
      builderFn: element.render,
    );

    _rootViewCompleter!.complete();
  }

  @override
  Future<Map<String, String>> fetchState(String url) {
    throw UnimplementedError();
  }

  @override
  String? getRawState(String id) {
    throw UnimplementedError();
  }

  @override
  void updateRawState(String id, dynamic state) {}
}
