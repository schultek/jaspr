import 'dart:async';

import 'package:jaspr/jaspr.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../binding.dart';
import '../finders.dart';

@isTest
void testComponents(
  String description,
  FutureOr<void> Function(ComponentTester tester) callback, {
  Uri? uri,
  bool isClient = false,
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  test(
    description,
    () async {
      var binding = TestComponentsBinding(uri, isClient);
      var tester = ComponentTester._(binding);

      return binding.runTest(() async {
        await callback(tester);
      });
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
  );
}

/// Tests any jaspr component in a simulated testing environment.
///
/// Unit-test components using the [pumpComponent] method and
/// simulate dom events using the [click] method.
class ComponentTester {
  ComponentTester._(this.binding);

  final TestComponentsBinding binding;

  Future<void> pumpComponent(Component component) {
    return binding.attachRootComponent(component);
  }

  /// Simulates a 'click' event on the given element
  /// and pumps the next frame.
  Future<void> click(Finder finder, {bool pump = true}) async {
    dispatchEvent(finder, 'click', null);
    if (pump) {
      await pumpEventQueue();
    }
  }

  Future<void> pump() async {
    await pumpEventQueue();
  }

  /// Simulates [event] on the given element.
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

    DomElement? foundElement;

    void findFirstDomElement(Element e) {
      if (e is DomElement) {
        foundElement = e;
        return;
      }
      e.visitChildren(findFirstDomElement);
    }

    findFirstDomElement(element);

    if (foundElement == null) {
      throw 'The finder "$finder" could not find a dom element.';
    }

    return foundElement!;
  }
}

class TestComponentsBinding extends AppBinding with ComponentsBinding {
  TestComponentsBinding(this._currentUri, this._isClient);

  final Uri? _currentUri;
  @override
  Uri get currentUri => _currentUri ?? (throw 'Did not call setUp() with currentUri provided.');

  final bool _isClient;
  @override
  bool get isClient => _isClient;

  @override
  Renderer createRenderer() {
    return TestDomRenderer();
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

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    Future.microtask(frameCallback);
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
  DomNodeData get testData => renderData ??= DomNodeData();
}

class TestDomRenderer extends Renderer {
  RenderElement? root;

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
  void attachNode(RenderElement? parent, RenderElement child, RenderElement? after) {
    if (parent == null) {
      root = child;
      return;
    }
    var children = parent.testData.children;
    children.remove(child);
    if (after == null) {
      children.insert(0, child);
    } else {
      var index = children.indexOf(after);
      children.insert(index + 1, child);
    }
  }

  @override
  void finalizeNode(RenderElement element) {}

  @override
  void removeChild(RenderElement parent, RenderElement child) {
    parent.testData.children.remove(child);
  }

  @override
  void skipContent(RenderElement element) {
    // noop
  }
}
