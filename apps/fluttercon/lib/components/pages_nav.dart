import 'package:jaspr/jaspr.dart';

class PagesNav extends StatelessComponent {
  const PagesNav({this.day, super.key});

  final int? day;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield nav([
      a(href: '/day-1', classes: day == 1 ? 'active' : '', [text("Day 1")]),
      a(href: '/day-2', classes: day == 2 ? 'active' : '', [text("Day 2")]),
      a(href: '/day-3', classes: day == 3 ? 'active' : '', [text("Day 3")]),
      a(href: '/favorites', classes: day == null ? 'active' : '', [text('Favorites')]),
    ]);
    ;
  }

  static get styles => [
        css('nav', [
          css('&').box(padding: EdgeInsets.all(40.px)).flexbox(justifyContent: JustifyContent.center),
          css('a', [
            css('&')
                .box(
                  display: Display.block,
                  padding: EdgeInsets.symmetric(horizontal: 8.px, vertical: 4.px),
                  border: Border.all(BorderSide.solid()),
                  margin: EdgeInsets.symmetric(horizontal: 2.px),
                )
                .text(decoration: TextDecoration.none, color: Color.initial),
            css('&:first-child').box(radius: BorderRadius.horizontal(left: Radius.circular(0.6.em))),
            css('&:last-child').box(radius: BorderRadius.horizontal(right: Radius.circular(0.6.em))),
            css('&.active').background(color: Color.hex('#0002')),
            css('&:hover').background(color: Color.hex('#0001')),
          ]),
        ]),
      ];
}
