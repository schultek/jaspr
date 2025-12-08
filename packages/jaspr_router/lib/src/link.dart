import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../jaspr_router.dart';

/// A drop-in replacement for the `<a>` tag.
///
/// When available, it uses client-side navigation (no page reload on click) and falls back to the default
/// server-side navigation.
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
    return a(
      href: to,
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
          if (router != null) {
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
}
