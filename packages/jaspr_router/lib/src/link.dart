import 'package:jaspr/jaspr.dart';

import '../jaspr_router.dart';

class Link extends StatelessComponent {
  const Link(
    this.children, {
    required this.to,
    this.replace = false,
    this.extra,
    this.preload = true,
    this.target,
    this.referrer,
    this.classes,
    this.styles,
    this.attributes,
    super.key,
  });

  final List<Component> children;
  final String to;
  final bool replace;
  final Object? extra;
  final bool preload;
  final Target? target;
  final ReferrerPolicy? referrer;
  final String? classes;
  final Styles? styles;
  final Map<String, String>? attributes;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield a(
      href: to,
      target: target,
      referrerPolicy: referrer,
      classes: classes,
      styles: styles,
      attributes: attributes,
      events: {
        if (preload)
          'mouseover': (event) {
            var router = Router.maybeOf(context);
            if (router != null) {
              router.preload(to);
            }
          },
        'click': (event) {
          var router = Router.maybeOf(context);
          if (router != null) {
            event.preventDefault();
            if (!replace) {
              router.push(to, extra: extra);
            } else {
              router.replace(to, extra: extra);
            }
          }
        }
      },
      children,
    );
  }
}
