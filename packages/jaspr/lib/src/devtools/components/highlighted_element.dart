import 'dart:math';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../client.dart';
import '../../../dom.dart';
import '../dev_tools_service.dart';
import 'element_properties.dart';

enum HighlightStyle { client, server, boundary }

class HighlightedElement extends StatefulComponent {
  final HighlightTargetDelegate target;
  final HighlightStyle style;
  final bool showLabel;
  final bool showProperties;
  final bool showOnHover;
  final List<DiagnosticsProperty>? properties;

  HighlightedElement(
    this.target,
    this.style, {
    this.showLabel = true,
    this.showProperties = true,
    this.showOnHover = false,
    this.properties,
  }) : super(key: ValueKey((target, style)));

  @override
  State<HighlightedElement> createState() => _HighlightedElementState();

  static List<StyleRule> get styles => [
    css('.jaspr-dev-toolbar-highlight', [
      css('&').styles(
        boxSizing: BoxSizing.borderBox,
        zIndex: ZIndex(999998),
        backgroundColor: Color.variable('--highlight-color').withOpacity(0.3),
        border: Border.all(color: Color.variable('--highlight-color'), width: 2.px),
      ),
      css('&.client').styles(raw: {'--highlight-color': '#3b82f6'}),
      css('&.server').styles(raw: {'--highlight-color': '#ff9f1b'}),
      css('&.boundary').styles(
        border: Border.all(color: Color.variable('--highlight-color'), width: 1.px, style: BorderStyle.dashed),
        raw: {'--highlight-color': '#ec4899', '--label-offset': '1'},
      ),
      css('&.no-tint').styles(
        backgroundColor: Colors.transparent,
      ),
      css('> span').styles(
        position: Position.absolute(left: Unit.expression('calc(var(--label-offset, 2) * -1px)')),
        backgroundColor: Color.variable('--highlight-color'),
        border: Border.all(color: Color.variable('--highlight-color'), width: 2.px),
      ),
      css('> span.top').styles(
        position: Position.absolute(bottom: 100.percent),
      ),
      css('> span.bottom').styles(
        position: Position.absolute(top: 100.percent),
      ),
      css('> span.inset').styles(
        position: Position.absolute(bottom: 0.px),
      ),
      css('> .jaspr-dev-toolbar-highlight-tooltip', [
        css('&').styles(
          visibility: Visibility.hidden,
          position: Position.absolute(
            left: Unit.expression('calc(var(--label-offset, 2) * -1px)'),
          ),
          zIndex: ZIndex(999999),
          backgroundColor: Color.variable('--highlight-color').withOpacity(0.5),
          backdropFilter: Filter.blur(4.px),
          border: Border.all(color: Color.variable('--highlight-color'), width: 1.px),
          radius: BorderRadius.circular(4.px),
          boxSizing: BoxSizing.borderBox,
        ),
        css('&.top').styles(
          position: Position.absolute(
            bottom: Unit.expression('calc(100% + (var(--label-offset, 2) * 1px) + 2px)'),
          ),
        ),
        css('&.bottom').styles(
          position: Position.absolute(
            top: Unit.expression('calc(100% + (var(--label-offset, 2) * 1px) + 2px)'),
          ),
        ),
        css('&.inset').styles(
          position: Position.absolute(top: 0.px),
        ),
      ]),
      css('&:hover, &:has(> .jaspr-dev-toolbar-highlight-tooltip.show)').styles(
        zIndex: ZIndex(999999),
      ),
      css('&:hover > .jaspr-dev-toolbar-highlight-tooltip, & > .jaspr-dev-toolbar-highlight-tooltip.show').styles(
        visibility: Visibility.visible,
      ),
    ]),
  ];
}

abstract class HighlightTargetDelegate {
  HighlightTargetDelegate? get parent;

  bool get isRenderTarget;

  bool get isHighlightTarget;

  List<web.Element> getElementsToHighlight();

  String get label;

  List<DiagnosticsProperty> get properties;
}

class ElementHighlightTargetDelegate extends HighlightTargetDelegate {
  final Element element;

  ElementHighlightTargetDelegate(this.element);

  @override
  String get label {
    if (element.component case DomComponent(:final tag)) {
      return '<$tag>';
    }
    return element.component.runtimeType.toString();
  }

  @override
  List<DiagnosticsProperty> get properties => element.component.debugFillProperties();

  @override
  HighlightTargetDelegate? get parent {
    if (element.parent case final parent?) {
      return ElementHighlightTargetDelegate(parent);
    }
    return null;
  }

  @override
  bool get isRenderTarget => element is RenderObjectElement;

  @override
  bool get isHighlightTarget => !(element.component is DomComponent && element is InheritedElement);

  @override
  List<web.Element> getElementsToHighlight() {
    if (element case RenderObjectElement(:final renderObject)) {
      return _getElementsToHighlight(renderObject);
    }

    final renderObject = element.slot.target?.renderObject;
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
    return identical(this, other) || (other is ElementHighlightTargetDelegate && other.element == element);
  }

  @override
  int get hashCode => element.hashCode;
}

class ServerElementHighlightTargetDelegate extends HighlightTargetDelegate {
  final ServerElement element;

  ServerElementHighlightTargetDelegate(this.element);

  @override
  String get label {
    return element.properties?.where((prop) => prop.name == 'type').firstOrNull?.value.toString() ?? element.name;
  }

  @override
  List<DiagnosticsProperty> get properties =>
      element.properties?.where((prop) => prop.name == 'component').firstOrNull?.properties ?? [];

  @override
  HighlightTargetDelegate? get parent {
    if (element.parent case final parent?) {
      return ServerElementHighlightTargetDelegate(parent);
    }
    return null;
  }

  @override
  bool get isRenderTarget =>
      element.name == 'DomElement' || element.name == '_FragmentElement' || element.name == 'TextElement';

  @override
  bool get isHighlightTarget => true;

  @override
  List<web.Element> getElementsToHighlight() {
    List<web.Element> visitChild(ServerElement child) {
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
    return identical(this, other) || (other is ServerElementHighlightTargetDelegate && other.element == element);
  }

  @override
  int get hashCode => element.hashCode;
}

class _HighlightedElementState extends State<HighlightedElement> {
  final highlightKey = GlobalNodeKey<web.HTMLElement>();
  final tooltipKey = GlobalNodeKey<web.HTMLElement>();

  web.DOMRect? rect;
  String tooltipLocation = 'top';

  bool get showTooltip => component.showProperties && properties.isNotEmpty;

  @override
  void initState() {
    super.initState();

    rect = _getDelegateBoundingRect(component.target);
    context.binding.addPostFrameCallback(() {
      setState(() {
        tooltipLocation = _getTooltipLocation();
      });
    });
    _trackUpdates();
  }

  @override
  void didUpdateComponent(covariant HighlightedElement oldComponent) {
    super.didUpdateComponent(oldComponent);

    if (component.showProperties != oldComponent.showProperties) {
      context.binding.addPostFrameCallback(() {
        setState(() {
          tooltipLocation = _getTooltipLocation();
        });
      });
    }
  }

  void _trackUpdates() {
    web.window.requestAnimationFrame(
      (num time) {
        if (!mounted) return;
        maybeUpdate();

        _trackUpdates();
      }.toJS,
    );
  }

  void maybeUpdate() {
    final newRect = _getDelegateBoundingRect(component.target);
    if (!_rectEquals(rect, newRect)) {
      setState(() {
        rect = newRect;
        tooltipLocation = _getTooltipLocation();
      });
    }
  }

  String _getTooltipLocation() {
    final rect = this.rect;
    final node = tooltipKey.currentNode;
    if (rect == null || node == null) return 'top';

    final tooltipRect = node.getBoundingClientRect();
    if (rect.top > tooltipRect.height + 4) return 'top';
    if (rect.bottom < web.window.innerHeight - tooltipRect.height - 4) return 'bottom';
    return 'inset';
  }

  String get label => component.target.label;

  List<DiagnosticsProperty> get properties {
    return component.properties ?? component.target.properties;
  }

  bool _rectEquals(web.DOMRect? a, web.DOMRect? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    return a.top == b.top && a.left == b.left && a.width == b.width && a.height == b.height;
  }

  static web.DOMRect? _getDelegateBoundingRect(HighlightTargetDelegate delegate) {
    final elements = delegate.getElementsToHighlight();
    if (elements.isEmpty) return null;
    if (elements.length == 1) return elements.first.getBoundingClientRect();

    final childRects = <web.DOMRect>[
      for (final element in elements) element.getBoundingClientRect(),
    ];

    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;

    for (final rect in childRects) {
      minX = minX < rect.left ? minX : rect.left;
      minY = minY < rect.top ? minY : rect.top;
      maxX = maxX > rect.right ? maxX : rect.right;
      maxY = maxY > rect.bottom ? maxY : rect.bottom;
    }

    minX = max(minX, 0);
    minY = max(minY, 0);
    maxX = min(maxX, web.window.innerWidth.toDouble());
    maxY = min(maxY, web.window.innerHeight.toDouble());

    return web.DOMRect(minX, minY, maxX - minX, maxY - minY);
  }

  @override
  Component build(BuildContext context) {
    final rect = this.rect;
    if (rect == null) return Component.empty();

    return div(
      key: highlightKey,
      classes: 'jaspr-dev-toolbar-highlight ${component.style.name} ${component.showLabel ? '' : 'no-tint'}',
      styles: Styles(
        position: Position.fixed(left: rect.left.px, top: rect.top.px),
        width: rect.width.px,
        height: rect.height.px,
        pointerEvents: !component.showProperties || !component.showOnHover ? PointerEvents.none : PointerEvents.auto,
      ),
      [
        if (component.showLabel)
          span(
            classes: showTooltip && !component.showOnHover
                ? tooltipLocation == 'top'
                      ? 'bottom'
                      : tooltipLocation == 'bottom' && rect.top > 20
                      ? 'top'
                      : 'inset'
                : rect.bottom < web.window.innerHeight - 20
                ? 'bottom'
                : 'inset',
            [
              Component.text(label),
            ],
          ),
        if (showTooltip)
          div(
            key: tooltipKey,
            classes: 'jaspr-dev-toolbar-highlight-tooltip ${!component.showOnHover ? 'show' : ''} $tooltipLocation',
            [
              ElementPropertiesTooltip(properties),
            ],
          ),
      ],
    );
  }
}
