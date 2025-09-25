import 'package:jaspr/jaspr.dart';

class PagesNav extends StatelessComponent {
  const PagesNav({this.day, super.key});

  final int? day;

  @override
  Component build(BuildContext context) {
    return nav([
      a(href: '/day-1', classes: day == 1 ? 'active' : '', [text("Day 1")]),
      a(href: '/day-2', classes: day == 2 ? 'active' : '', [text("Day 2")]),
      a(href: '/day-3', classes: day == 3 ? 'active' : '', [text("Day 3")]),
      a(href: '/favorites', classes: day == null ? 'active' : '', [text('Favorites')]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('nav', [
      css('&').styles(display: Display.flex, padding: Padding.all(40.px), justifyContent: JustifyContent.center),
      css('a', [
        css('&').styles(
          display: Display.block,
          padding: Padding.symmetric(horizontal: 8.px, vertical: 4.px),
          margin: Margin.symmetric(horizontal: 2.px),
          border: Border(),
          color: Color.initial,
          textDecoration: TextDecoration.none,
        ),
        css('&:first-child').styles(radius: BorderRadius.horizontal(left: Radius.circular(0.6.em))),
        css('&:last-child').styles(radius: BorderRadius.horizontal(right: Radius.circular(0.6.em))),
        css('&.active').styles(backgroundColor: Color('#0002')),
        css('&:hover').styles(backgroundColor: Color('#0001')),
      ]),
    ]),
  ];
}
