import 'dart:math';

import 'package:universal_web/js_interop.dart';
import 'package:universal_web/web.dart' as web;

import '../../../client.dart';
import '../../../dom.dart';
import 'element_properties.dart';

enum HighlightStyle { client, server, boundary }

class HighlightedElement extends StatefulComponent {
  final Element element;
  final HighlightStyle style;
  final bool showLabel;
  final bool showProperties;
  final bool showOnHover;
  final List<DiagnosticsProperty>? properties;

  HighlightedElement(
    this.element,
    this.style, {
    this.showLabel = true,
    this.showProperties = true,
    this.showOnHover = false,
    this.properties,
  }) : super(key: ValueKey((element, style)));

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

class _HighlightedElementState extends State<HighlightedElement> {
  final highlightKey = GlobalNodeKey<web.HTMLElement>();
  final tooltipKey = GlobalNodeKey<web.HTMLElement>();

  web.DOMRect? rect;
  late Element targetElement;
  String tooltipLocation = 'top';

  bool get showTooltip => component.showProperties && properties.isNotEmpty;

  @override
  void initState() {
    super.initState();

    rect = _getElementBoundingRect(component.element);
    targetElement = _findTargetElement();
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
    final newRect = _getElementBoundingRect(component.element);
    if (!_rectEquals(rect, newRect)) {
      setState(() {
        rect = newRect;
        targetElement = _findTargetElement();
        tooltipLocation = _getTooltipLocation();
      });
    }
  }

  Element _findTargetElement() {
    final visited = [component.element];
    var current = component.element;
    var parent = current.parent;
    while (parent != null) {
      if (parent is RenderObjectElement) {
        final parentRect = _getRenderObjectBoundingRect(parent.renderObject);
        if (!_rectEquals(parentRect, rect)) {
          break;
        }
      }
      current = parent;
      parent = current.parent;
      if (!(current.component is DomComponent && current is InheritedElement)) {
        visited.add(current);
      }
    }
    return visited.last;
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

  String get label {
    return labelFor(targetElement);
  }

  List<DiagnosticsProperty> get properties {
    return component.properties ?? targetElement.component.debugFillProperties();
  }

  String labelFor(Element element) {
    if (element.component case DomComponent(:final tag)) {
      return '<$tag>';
    }
    return element.component.runtimeType.toString();
  }

  bool _rectEquals(web.DOMRect? a, web.DOMRect? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    return a.top == b.top && a.left == b.left && a.width == b.width && a.height == b.height;
  }

  static web.DOMRect? _getElementBoundingRect(Element element) {
    final renderObject = element.slot.target?.renderObject;
    if (renderObject == null) return null;

    return _getRenderObjectBoundingRect(renderObject);
  }

  static web.DOMRect? _getRenderObjectBoundingRect(RenderObject renderObject) {
    if (renderObject is RenderElement) {
      return renderObject.node?.getBoundingClientRect();
    } else if (renderObject is DomRenderFragment) {
      final childRects = <web.DOMRect>[];

      var currentNode = renderObject.firstChildNode;
      while (currentNode != null) {
        if (currentNode.isA<web.Element>()) {
          childRects.add((currentNode as web.Element).getBoundingClientRect());
        }
        if (currentNode == renderObject.lastChildNode) break;
        currentNode = currentNode.nextSibling;
      }

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
    } else if (renderObject.parent case final parent?) {
      return _getRenderObjectBoundingRect(parent);
    }
    return null;
  }

  @override
  Component build(BuildContext context) {
    final rect = this.rect;
    if (rect == null) return Component.empty();

    return div(
      key: highlightKey,
      classes: 'jaspr-dev-toolbar-highlight ${component.style.name} ${component.showProperties ? '' : 'no-tint'}',
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
