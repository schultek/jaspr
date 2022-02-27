import 'dart:async';
import 'dart:html' as html;
import 'dart:html';

import 'package:jaspr/browser.dart';
import 'package:jaspr_test/src/finders.dart';

class BrowserTester {
  BrowserTester._(this.binding, this._id);

  final BrowserComponentsBinding binding;
  final String _id;

  static BrowserTester setUp({String id = 'app', Map<String, String>? initialStateData}) {
    if (initialStateData != null) {
      for (var key in initialStateData.keys) {
        document.body!.attributes['data-state-$key'] = initialStateData[key]!;
      }
    }

    var binding = BrowserComponentsBinding.ensureInitialized() as BrowserComponentsBinding;
    return BrowserTester._(binding, id);
  }

  static void tearDown() {}

  Future<void> pumpComponent(Component component) {
    binding.attachRootComponent(component, to: _id);
    return binding.firstBuild;
  }

  Future<void> click(Finder finder) {
    dispatchEvent(finder, 'click', null);
    return binding.currentBuild;
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
