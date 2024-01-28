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

  static final styles = [
    StyleRule(
      selector: Selector('header'),
      styles: Styles.flexbox(justifyContent: JustifyContent.spaceBetween),
    ),
    StyleRule(
      selector: Selector('.corner'),
      styles: Styles.box(width: 3.em, height: 3.em),
    ),
    StyleRule(
      selector: Selector('header .corner a'),
      styles: Styles.combine([
        Styles.box(width: 100.percent, height: 100.percent),
        Styles.flexbox(justifyContent: JustifyContent.center, alignItems: AlignItems.center),
      ]),
    ),
    StyleRule(
      selector: Selector('header .corner img'),
      styles: Styles.box(width: 2.em, height: 2.em),
    ),
    StyleRule(
      selector: Selector('nav'),
      styles: Styles.combine([
        Styles.background(color: primaryColor),
        Styles.box(radius: BorderRadius.vertical(bottom: Radius.circular(10.px))),
        Styles.flexbox(justifyContent: JustifyContent.spaceBetween),
      ]),
    ),
    StyleRule(
      selector: Selector('nav a'),
      styles: Styles.combine([
        Styles.text(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration(line: TextDecorationLine.none),
        ),
        Styles.box(
          height: 100.percent,
          padding: EdgeInsets.symmetric(horizontal: 1.em),
        ),
        Styles.flexbox(alignItems: AlignItems.center),
      ]),
    ),
    StyleRule(
      selector: Selector('nav a:hover'),
      styles: Styles.combine([
        Styles.text(color: secondaryColor),
      ]),
    ),
  ];
}
