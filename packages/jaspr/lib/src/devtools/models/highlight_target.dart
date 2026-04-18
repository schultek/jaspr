import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../client/dom_render_object.dart';
import '../../foundation/diagnostics.dart';
import '../../framework/framework.dart';
import 'tree_element.dart';

sealed class HighlightTarget {
  TreeElement get element;

  HighlightTarget? get parent;

  bool get isRenderTarget;

  bool get allowHighlighting;

  List<web.Element> getElementsToHighlight();

  String get label;

  List<DiagnosticsProperty> get properties;
}

class LocalHighlightTarget extends HighlightTarget {
  @override
  final LocalElement element;

  LocalHighlightTarget(this.element);

  @override
  String get label {
    if (element.element.component case DomComponent(:final tag)) {
      return '<$tag>';
    }
    return element.element.component.runtimeType.toString();
  }

  @override
  List<DiagnosticsProperty> get properties => element.element.component.debugFillProperties();

  @override
  HighlightTarget? get parent {
    if (element.element.parent case final parent?) {
      return LocalHighlightTarget(LocalElement(parent));
    }
    return null;
  }

  @override
  bool get isRenderTarget => element.element is RenderObjectElement;

  @override
  bool get allowHighlighting => element.element.component is! DomComponent || element.element is! InheritedElement;

  @override
  List<web.Element> getElementsToHighlight() {
    if (element.element case RenderObjectElement(:final renderObject)) {
      return _getElementsToHighlight(renderObject);
    }

    final renderObject = element.element.slot.target?.renderObject;
    if (renderObject == null) return [];

    return _getElementsToHighlight(renderObject);
  }

  List<web.Element> _getElementsToHighlight(RenderObject renderObject) {
    if (renderObject is RenderElement) {
      return [?renderObject.node];
    } else if (renderObject is DomRenderFragment) {
      final elements = <web.Element>[];

      var currentNode = renderObject.firstChildNode;
      while (currentNode != null) {
        if (currentNode.isA<web.Element>()) {
          elements.add(currentNode as web.Element);
        }
        if (currentNode == renderObject.lastChildNode) break;
        currentNode = currentNode.nextSibling;
      }

      return elements;
    } else if (renderObject.parent case final parent?) {
      return _getElementsToHighlight(parent);
    }

    return [];
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is LocalHighlightTarget && other.element == element);
  }

  @override
  int get hashCode => element.hashCode;
}

class RemoteHighlightTarget extends HighlightTarget {
  @override
  final RemoteElement element;

  RemoteHighlightTarget(this.element);

  @override
  String get label {
    return element.properties.where((prop) => prop.name == 'type').firstOrNull?.value.toString() ?? element.name;
  }

  @override
  List<DiagnosticsProperty> get properties =>
      element.properties.where((prop) => prop.name == 'component').firstOrNull?.properties ?? [];

  @override
  HighlightTarget? get parent {
    if (element.parent case final parent?) {
      return RemoteHighlightTarget(parent);
    }
    return null;
  }

  @override
  bool get isRenderTarget =>
      element.name == 'DomElement' || element.name == '_FragmentElement' || element.name == 'TextElement';

  @override
  bool get allowHighlighting => true;

  @override
  List<web.Element> getElementsToHighlight() {
    List<web.Element> visitChild(RemoteElement child) {
      if (child.node case final node?) {
        return [node];
      }
      if (child.children.isEmpty) return [];
      return child.children.expand(visitChild).nonNulls.toList();
    }

    return visitChild(element);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is RemoteHighlightTarget && other.element == element);
  }

  @override
  int get hashCode => element.hashCode;
}
