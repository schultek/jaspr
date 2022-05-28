import 'dart:async';
import 'dart:html' as html;

import 'package:domino/browser.dart' show registerView;
import 'package:jaspr/jaspr_browser.dart';

import '../../jaspr_test.dart';

class BrowserTester {
  BrowserTester._(this.binding, this._attachTo);

  final TestBrowserComponentsBinding binding;
  final String _attachTo;

  static BrowserTester setUp({
    String attachTo = 'body',
    String location = '/',
    Map<String, dynamic>? initialStateData,
    Map<String, dynamic> Function(String url)? onFetchState,
  }) {
    if (initialStateData != null) {
      html.document.body!.attributes['state-data'] = stateCodec.encode(initialStateData);
    }

    if (html.window.location.pathname != location) {
      html.window.history.replaceState(null, 'Test', location);
    }

    var binding = TestBrowserComponentsBinding(onFetchState);
    return BrowserTester._(binding, attachTo);
  }

  static void tearDown() {}

  Future<void> pumpComponent(Component component) {
    return binding.attachRootComponent(component, attachTo: _attachTo);
  }

  Future<void> click(Finder finder, {bool pump = true}) async {
    dispatchEvent(finder, 'click', null);
    if (pump) {
      await pumpEventQueue();
    }
  }

  void dispatchEvent(Finder finder, String event, dynamic data) {
    var element = _findDomElement(finder);

    var source = element.source as html.Element;
    source.dispatchEvent(html.MouseEvent('click'));
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

class TestBrowserComponentsBinding extends AppBinding {
  TestBrowserComponentsBinding(this._onFetchState);

  @override
  void didAttachRootElement(BuildScheduler element, {required String to}) {
    element.view = registerView(root: html.document.querySelector(to)!, builderFn: element.render);
  }

  final Map<String, dynamic> Function(String url)? _onFetchState;

  @override
  Future<Map<String, dynamic>> fetchState(String url) async {
    return _onFetchState?.call(url) ?? {};
  }
}
