import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:universal_web/web.dart' as web;

import '../jaspr_router.dart';

/// A drop-in replacement for the `<a>` tag.
///
/// When available, it uses client-side navigation (no page reload on click) and falls back to the default
/// server-side navigation.
///
/// Clicks that the browser would not handle as a plain navigation in the current tab are left to the browser:
/// clicks with a modifier key (such as Ctrl or Cmd to open a new tab) or a button other than the primary one,
/// clicks whose default action was already prevented, and clicks on links with a [target] other than
/// [Target.self] or with a `download` attribute.
class Link extends StatelessComponent {
  const Link({
    required this.to,
    this.replace = false,
    this.extra,
    this.preload = true,
    this.target,
    this.referrer,
    this.classes,
    this.styles,
    this.attributes,
    this.child,
    this.children,
    super.key,
  });

  /// The url to navigate to.
  final String to;

  /// Whether to replace the route instead of pushing.
  ///
  /// Only affects client-side routing.
  final bool replace;

  /// The extra data to attach to the new route.
  ///
  /// Only affects client-side routing.
  final Object? extra;

  /// Whether to preload the target route when the link is hovered.
  ///
  /// Only affects client-side routing when using lazy routes.
  final bool preload;

  /// The `target` attribute value applied to the anchor element.
  ///
  /// Any value other than [Target.self] leaves the click to the browser instead of using client-side navigation.
  final Target? target;

  /// The `referrerpolicy` attribute value applied to the anchor element.
  final ReferrerPolicy? referrer;

  /// The `class` attribute value applied to the anchor element.
  final String? classes;

  /// The `style` attribute value applied to the anchor element.
  final Styles? styles;

  /// Other attribute values applied to the anchor element.
  final Map<String, String>? attributes;

  /// Child component to render inside the anchor element.
  final Component? child;

  /// Child components to render inside the anchor element.
  final List<Component>? children;

  @override
  Component build(BuildContext context) {
    final resolvedUrl = () {
      if (to.startsWith('/') && !to.startsWith('//')) {
        final basePath = context.binding.basePath;
        final prefix = basePath.endsWith('/') ? basePath.substring(0, basePath.length - 1) : basePath;
        return prefix + to;
      }
      return to;
    }();

    return a(
      href: resolvedUrl,
      target: target,
      referrerPolicy: referrer,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: {
        if (preload)
          'mouseover': (event) {
            final router = Router.maybeOf(context);
            if (router != null) {
              router.preload(to);
            }
          },
        'click': (event) {
          final router = Router.maybeOf(context);
          if (router != null && !_isHandledByBrowser(event)) {
            event.preventDefault();
            if (!replace) {
              router.push(to, extra: extra);
            } else {
              router.replace(to, extra: extra);
            }
          }
        },
      },
      [?child, ...?children],
    );
  }

  /// Whether the browser should handle [event] itself, for example to open the link in a new tab or window,
  /// or to download it.
  bool _isHandledByBrowser(web.Event event) {
    if (event.defaultPrevented) {
      return true;
    }
    final mouseEvent = event as web.MouseEvent;
    if (mouseEvent.button != 0 ||
        mouseEvent.ctrlKey ||
        mouseEvent.metaKey ||
        mouseEvent.shiftKey ||
        mouseEvent.altKey) {
      return true;
    }
    // Read from the element, since `target` and `download` can also be set through [attributes].
    final anchor = event.currentTarget as web.Element;
    final target = anchor.getAttribute('target');
    if (target != null && target.isNotEmpty && target != '_self') {
      return true;
    }
    return anchor.hasAttribute('download');
  }
}
