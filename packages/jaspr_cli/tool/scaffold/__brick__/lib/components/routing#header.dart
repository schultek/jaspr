import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
{{#server}}
import '../constants/theme.dart';{{/server}}

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var activePath = {{^multipage}}RouteState.of(context).location{{/multipage}}{{#multipage}}context.url{{/multipage}};

    yield header([
      nav([
        for (var route in [
          (label: 'Home', path: '/'),
          (label: 'About', path: '/about'),
        ])
          div(classes: activePath == route.path ? 'active' : null, [
            Link(to: route.path, child: text(route.label)),
          ]),
      ]),
    ]);
  }{{#server}}

  @css
  static final styles = [
    css('header', [
      css('&').styles(
        display: Display.flex,
        padding: Padding.all(1.em),
        justifyContent: JustifyContent.center,
      ),
      css('nav', [
        css('&').styles(
          display: Display.flex,
          height: 3.em,
          radius: BorderRadius.all(Radius.circular(10.px)), 
          overflow: Overflow.clip,
          justifyContent: JustifyContent.spaceBetween,
          backgroundColor: primaryColor,
        ),
        css('a', [
          css('&').styles(
            display: Display.flex,
            height: 100.percent,
            padding: Padding.symmetric(horizontal: 2.em),
            alignItems: AlignItems.center,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            textDecoration: const TextDecoration(line: TextDecorationLine.none),
          ),
          css('&:hover').styles(
            backgroundColor: const Color.hex('#0005'),
          ),
        ]),
        css('div.active', [
          css('&').styles(position: const Position.relative()),
          css('&::before').styles(
            content: '',
            display: Display.block,
            position: Position.absolute(bottom: 0.5.em, left: 20.px, right: 20.px),
            height: 2.px,
            radius: BorderRadius.circular(1.px),
            backgroundColor: Colors.white,
          ),
        ])
      ]),
    ]),
  ];{{/server}}
}
