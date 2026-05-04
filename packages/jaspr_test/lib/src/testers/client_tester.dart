import 'dart:async';
import 'dart:js_interop';

import 'package:jaspr/client.dart';
// ignore: implementation_imports
import 'package:jaspr/src/dom/type_checks.dart';
// ignore: implementation_imports, invalid_use_of_visible_for_testing_member
import 'package:jaspr/src/framework/framework.dart' show GlobalComponentsBinding;
import 'package:meta/meta.dart';
import 'package:test/test.dart';
import 'package:universal_web/web.dart' as web;

import '../binding.dart';
import '../finders.dart';

@isTest
void testClient(
  String description,
  FutureOr<void> Function(ClientTester tester) callback, {
  String location = '/',
  bool? skip,
  Timeout? timeout,
  Object? tags,
}) {
  test(
    description,
    () async {
      if (web.window.location.pathname != location) {
        web.window.history.replaceState(null, 'Test', location);
      }

      final binding = ClientAppBinding();
      final tester = ClientTester._(binding);

      await binding.runTest(() async {
        await callback(tester);
      });

      // Clear all nodes
      web.document.body?.replaceChildren(<web.Node>[].toJS);

      // ignore: invalid_use_of_visible_for_testing_member
      GlobalComponentsBinding.clearGlobalKeys();
    },
    skip: skip,
    timeout: timeout,
    tags: tags,
  );
}

/// Tests Jaspr app in a headless browser environment.
class ClientTester {
  ClientTester._(this.binding);

  final ClientAppBinding binding;

  void pumpComponent(Component component, {String attachTo = 'body'}) {
    binding.attachRootComponent(component, attachTo: attachTo);
  }

  Future<void> click(Finder finder, {bool pump = true}) async {
    await dispatchEvent(finder, web.MouseEvent('click'), pump: pump);
  }

  Future<void> input(Finder finder, {bool? checked, double? valueAsNumber, String? value, bool pump = true}) async {
    await _dispatchInputEvent(
      finder,
      'input',
      checked: checked,
      valueAsNumber: valueAsNumber,
      value: value,
      pump: pump,
    );
  }

  Future<void> change(Finder finder, {bool? checked, double? valueAsNumber, String? value, bool pump = true}) async {
    await _dispatchInputEvent(
      finder,
      'change',
      checked: checked,
      valueAsNumber: valueAsNumber,
      value: value,
      pump: pump,
    );
  }

  Future<void> _dispatchInputEvent(
    Finder finder,
    String type, {
    bool? checked,
    double? valueAsNumber,
    String? value,
    bool pump = true,
  }) async {
    dispatchEvent(
      finder,
      web.InputEvent(type),
      before: (e) {
        if (checked != null) (e as web.HTMLInputElement).checked = checked;
        if (valueAsNumber != null) (e as web.HTMLInputElement).valueAsNumber = valueAsNumber;
        if (value != null) (e as web.HTMLInputElement).value = value;
      },
      pump: pump,
    );
  }

  Future<void> dispatchEvent(
    Finder finder,
    web.Event event, {
    void Function(web.Element)? before,
    bool pump = true,
  }) async {
    final element = _findDomElement(finder);

    final source = (element.renderObject as DomRenderObject).node;
    if (source.isElement) {
      before?.call(source as web.Element);
      (source as web.Element).dispatchEvent(event);
    }

    if (pump) {
      await pumpEventQueue();
    }
  }

  @optionalTypeArgs
  T? findNode<T extends web.Node>(Finder finder) {
    final element = _findDomElement(finder);
    return (element.renderObject as DomRenderObject).node as T?;
  }

  DomElement _findDomElement(Finder finder) {
    final elements = finder.evaluate();

    if (elements.isEmpty) {
      throw 'The finder "$finder" could not find any matching components.';
    }
    if (elements.length > 1) {
      throw 'The finder "$finder" ambiguously found multiple matching components.';
    }

    final element = elements.single;

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
