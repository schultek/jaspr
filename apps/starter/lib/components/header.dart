import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../styles.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var routes = Router.of(context).component.routes.whereType<Route>();
    var state = RouteState.of(context);

    yield header([
      div(classes: 'corner', [
        a(href: 'https://docs.page/schultek/jaspr', [
          img(src: 'images/logo.png', alt: 'Jaspr'),
        ])
      ]),
      nav([
        for (var route in routes)
          div(classes: state.path == route.path ? 'active' : null, [
            a(href: route.path, [text(route.title ?? '')])
          ]),
      ]),
      div(classes: 'corner', [
        a(href: 'https://github.com/schultek/jaspr', [
          img(src: 'images/github.svg', alt: 'GitHub'),
        ])
      ]),
    ]);
  }

  static get styles => [
        css('header', [
          css('&').flexbox(justifyContent: JustifyContent.spaceBetween),
          css('.corner', [
            css('&').box(width: 3.em, height: 3.em),
            css('a')
                .box(width: 100.percent, height: 100.percent)
                .flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center),
            css('img').box(width: 2.em, height: 2.em)
          ]),
          css('nav', [
            css('&')
                .background(color: primaryColor)
                .box(radius: BorderRadius.vertical(bottom: Radius.circular(10.px)))
                .flexbox(justifyContent: JustifyContent.spaceBetween),
            css('a', [
              css('&')
                  .text(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration(line: TextDecorationLine.none),
                  )
                  .box(height: 100.percent, padding: EdgeInsets.symmetric(horizontal: 1.em))
                  .flexbox(alignItems: AlignItems.center),
              css('&:hover').box(opacity: 0.5),
            ])
          ]),
        ]),
      ];
}
