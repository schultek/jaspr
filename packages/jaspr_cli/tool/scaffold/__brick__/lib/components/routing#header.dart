import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';
{{#server}}
import '../constants/theme.dart';{{/server}}

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var activePath = {{^multipage}}RouteState.of(context).location{{/multipage}}{{#multipage}}context.binding.currentUri.path{{/multipage}};

    yield header([
      nav([
        for (var route in [
          (label: 'Home', path: '/'),
          (label: 'About', path: '/about'),
        ])
          div(classes: activePath == route.path ? 'active' : null, [
            Link(to: route.path, [text(route.label)])
          ]),
      ]),
    ]);
  }{{#server}}

  @css
  static final styles = [
    css('header', [
      css('&').flexbox(justifyContent: JustifyContent.center).box(padding: EdgeInsets.all(1.em)),
      css('nav', [
        css('&')
            .background(color: primaryColor)
            .box(height: 3.em, radius: BorderRadius.all(Radius.circular(10.px)), overflow: Overflow.clip)
            .flexbox(justifyContent: JustifyContent.spaceBetween),
        css('a', [
          css('&')
              .text(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                decoration: const TextDecoration(line: TextDecorationLine.none),
              )
              .box(height: 100.percent, padding: EdgeInsets.symmetric(horizontal: 2.em))
              .flexbox(alignItems: AlignItems.center),
          css('&:hover').background(color: const Color.hex('#0005')),
        ]),
        css('div.active', [
          css('&').box(position: const Position.relative()),
          css('&::before')
              .raw({'content': '""'})
              .box(
                display: Display.block,
                position: Position.absolute(bottom: 0.5.em, left: 20.px, right: 20.px),
                radius: BorderRadius.circular(1.px),
                height: 2.px,
              )
              .background(color: Colors.white)
        ])
      ]),
    ]),
  ];{{/server}}
}
