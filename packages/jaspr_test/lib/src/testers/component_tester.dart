import 'dart:async';

import 'package:jaspr/jaspr.dart';

import '../../jaspr_test.dart';

class ComponentTester {
  ComponentTester._(this.binding);

  final TestComponentsBinding binding;

  static ComponentTester setUp({Uri? currentUri, bool isClient = false}) {
    tearDown();
    var binding = TestComponentsBinding(currentUri, isClient);
    return ComponentTester._(binding);
  }

  static void tearDown() {
    if (ComponentsBinding.instance is TestComponentsBinding) {
      // TODO release any resources
    }
  }

  Future<void> pumpComponent(Component component) {
    return binding.attachRootComponent(component, attachTo: 'body');
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
    element.testData.events?[event]?.call(data);
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

class TestComponentsBinding extends BindingBase with SchedulerBinding, ComponentsBinding, SyncBinding {
  static TestComponentsBinding get instance => ComponentsBinding.instance as TestComponentsBinding;

  TestComponentsBinding(this._currentUri, this._isClient);

  final Uri? _currentUri;
  @override
  Uri get currentUri => _currentUri ?? (throw 'Did not call setUp() with currentUri provided.');

  final bool _isClient;
  @override
  bool get isClient => _isClient;

  RenderElement? get rootElement => rootElements['body'];

  @override
  Renderer attachRenderer(String to) {
    return TestDomRenderer();
  }

  @override
  void didAttachRootElement(Element element, {required String to}) {}

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

  @override
  void scheduleBuild(VoidCallback buildCallback) {
    Future(() => handleFrame(buildCallback));
  }
}

class DomNodeData {
  String? tag;
  String? id;
  List<String>? classes;
  Map<String, String>? styles;
  Map<String, String>? attributes;
  Map<String, EventCallback>? events;
  String? text;
  bool? rawHtml;
  List<RenderElement> children = [];
}

extension TestDomNodeData on RenderElement {
  DomNodeData get testData => getData() ?? setData(DomNodeData());
}

class TestDomRenderer extends Renderer {
  RenderElement? root;

  @override
  void setRootNode(RenderElement element) {
    root = element;
  }

  @override
  void renderNode(RenderElement element, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    element.testData
      ..tag = tag
      ..id = id
      ..classes = classes
      ..styles = styles
      ..attributes = attributes
      ..events = events;
  }

  @override
  void renderTextNode(RenderElement element, String text, [bool rawHtml = false]) {
    element.testData
      ..text = text
      ..rawHtml = rawHtml;
  }

  @override
  void renderChildNode(RenderElement element, RenderElement child, RenderElement? after) {
    var children = element.testData.children;
    children.remove(child);
    if (after == null) {
      children.insert(0, child);
    } else {
      var index = children.indexOf(after);
      children.insert(index + 1, child);
    }
  }

  @override
  void didPerformRebuild(RenderElement element) {}

  @override
  void removeChild(RenderElement parent, RenderElement child) {
    parent.testData.children.remove(child);
  }

  @override
  void skipContent(RenderElement element) {
    // noop
  }
}
