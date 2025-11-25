import 'package:jaspr/dom.dart';

class PagesNav extends StatelessComponent {
  const PagesNav({this.day, super.key});

  final int? day;

  @override
  Component build(BuildContext context) {
    return nav([
      a(href: '/day-1', classes: day == 1 ? 'active' : '', [.text("Day 1")]),
      a(href: '/day-2', classes: day == 2 ? 'active' : '', [.text("Day 2")]),
      a(href: '/day-3', classes: day == 3 ? 'active' : '', [.text("Day 3")]),
      a(href: '/favorites', classes: day == null ? 'active' : '', [.text('Favorites')]),
    ]);
  }

  @css
  static List<StyleRule> get styles => [
    css('nav', [
      css('&').styles(display: .flex, padding: .all(40.px), justifyContent: .center),
      css('a', [
        css('&').styles(
          display: .block,
          padding: .symmetric(horizontal: 8.px, vertical: 4.px),
          margin: .symmetric(horizontal: 2.px),
          color: .initial,
          textDecoration: .none,
        ),
        css('&:first-child').styles(radius: .horizontal(left: .circular(0.6.em))),
        css('&:last-child').styles(radius: .horizontal(right: .circular(0.6.em))),
        css('&.active').styles(backgroundColor: Color('#0002')),
        css('&:hover').styles(backgroundColor: Color('#0001')),
      ]),
    ]),
  ];
}
