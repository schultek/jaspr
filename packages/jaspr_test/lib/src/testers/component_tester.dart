import 'dart:async';

import 'package:jaspr/jaspr.dart';
// ignore: implementation_imports
import 'package:jaspr/src/server/async_build_owner.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:universal_web/web.dart' as web;

import '../binding.dart';
import '../finders.dart';

@isTest
void testComponents(
  String description,
  FutureOr<void> Function(ComponentTester tester) callback, {
  String? url,
  bool isClient = true,
  bool? skip,
  Timeout? timeout,
  dynamic tags,
}) {
  test(
    description,
    () async {
      var binding = TestComponentsBinding(url ?? '/', isClient);
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

  void pumpComponent(Component component) {
    binding.attachRootComponent(component);
  }

  /// Simulates a 'click' event on the given element
  /// and pumps the next frame.
  Future<void> click(Finder finder, {bool pump = true}) async {
    dispatchEvent(finder, 'click');
    if (pump) {
      await pumpEventQueue();
    }
  }

  Future<void> pump() async {
    await pumpEventQueue();
  }

  /// Simulates [event] on the given element.
  void dispatchEvent(Finder finder, String event, [web.Event? data]) {
    var renderObject = _findDomElement(finder).renderObject as TestRenderObject;
    renderObject.events?[event]?.call(data ?? web.Event(event));
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
  TestComponentsBinding(this.currentUrl, this.isClient);

  @override
  final bool isClient;
  @override
  final String currentUrl;

  @override
  void scheduleFrame(VoidCallback frameCallback) {
    Future.microtask(frameCallback);
  }

  @override
  RenderObject createRootRenderObject() {
    return TestRenderObject();
  }

  @override
  BuildOwner createRootBuildOwner() {
    if (!isClient) {
      return AsyncBuildOwner();
    }
    return super.createRootBuildOwner();
  }
}

class TestRenderObject extends RenderObject {
  String? tag;
  String? id;
  String? classes;
  Map<String, String>? styles;
  Map<String, String>? attributes;
  Map<String, EventCallback>? events;
  String? text;
  bool? rawHtml;
  List<TestRenderObject> children = [];

  @override
  TestRenderObject? parent;
  @override
  web.Node? get node => null;

  @override
  RenderObject createChildRenderObject() {
    return TestRenderObject()..parent = this;
  }

  @override
  void updateElement(String tag, String? id, String? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    this
      ..tag = tag
      ..id = id
      ..classes = classes
      ..styles = styles
      ..attributes = attributes
      ..events = events;
  }

  @override
  void updateText(String text, [bool rawHtml = false]) {
    this
      ..text = text
      ..rawHtml = rawHtml;
  }

  @override
  void skipChildren() {
    // noop
  }

  @override
  void attach(TestRenderObject child, {TestRenderObject? after}) {
    child.parent = this;

    children.remove(child);
    if (after == null) {
      children.insert(0, child);
    } else {
      var index = children.indexOf(after);
      children.insert(index + 1, child);
    }
  }

  @override
  void remove(TestRenderObject child) {
    children.remove(child);
    child.parent = null;
  }
}
