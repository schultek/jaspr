part of 'layout.dart';

class SidebarGroup {
  SidebarGroup({
    this.title,
    required this.links,
  });

  final String? title;
  final List<SidebarLink> links;
}

class SidebarLink {
  SidebarLink({
    required this.text,
    required this.href,
  });

  final String text;
  final String href;
}

/// A sidebar component that renders groups of links.
class Sidebar extends StatelessComponent {
  const Sidebar({required this.groups});

  final List<SidebarGroup> groups;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var currentRoute = context.page.url;

    yield Document.head(children: [
      Style(styles: _styles),
    ]);

    yield nav(classes: 'sidebar', [
      button(classes: 'sidebar-close', [
        CloseIcon(size: 20),
      ]),
      div([
        for (final group in groups)
          div(classes: 'sidebar-group', [
            if (group.title != null) h3([text(group.title!)]),
            ul([
              for (final item in group.links)
                li([
                  div(classes: currentRoute == item.href ? 'active' : null, [
                    a(href: item.href, [
                      text(item.text),
                    ]),
                  ]),
                ]),
            ]),
          ]),
      ]),
    ]);
  }

  static List<StyleRule> get _styles => [
        css('.sidebar', [
          css('&').styles(
            position: Position.relative(),
            fontSize: 0.875.rem,
            lineHeight: 1.25.rem,
            padding: Padding.only(left: 0.5.rem, bottom: 1.25.rem, top: 0.75.rem),
          ),
          css.media(MediaQuery.all(minWidth: 1024.px), [
            css('&').styles(
              padding: Padding.only(top: Unit.zero),
            ),
          ]),
          css('.sidebar-close', [
            css('&').styles(
              position: Position.absolute(top: 0.75.rem, right: 0.75.rem),
            ),
            css.media(MediaQuery.all(minWidth: 1024.px), [
              css('&').styles(display: Display.none),
            ]),
          ]),
          css('.sidebar-group', [
            css('&').styles(
              padding: Padding.only(top: 1.5.rem, right: 0.75.rem),
            ),
            css('h3').styles(
              fontWeight: FontWeight.w600,
              fontSize: 14.px,
              padding: Padding.only(left: 0.75.rem),
              margin: Margin.only(bottom: 1.rem, top: Unit.zero),
            ),
            css('ul').styles(
              listStyle: ListStyle.none,
              margin: Margin.zero,
              padding: Padding.zero,
            ),
            css('li', [
              css('div', [
                css('&').styles(
                  opacity: 0.75,
                  margin: Margin.only(bottom: 1.px),
                  whiteSpace: WhiteSpace.noWrap,
                  overflow: Overflow.hidden,
                  textOverflow: TextOverflow.ellipsis,
                  radius: BorderRadius.circular(.375.rem),
                  display: Display.flex,
                  transition: Transition('all', duration: 150, curve: Curve.easeInOut),
                ),
                css('&:hover').styles(
                  opacity: 1,
                  backgroundColor: Color('#0000000d'),
                ),
                css('&.active').styles(
                  opacity: 1,
                  color: ContentTheme.primary,
                  fontWeight: FontWeight.w700,
                  backgroundColor: Color('color-mix(in srgb, currentColor 15%, transparent)'),
                ),
              ]),
              css('a').styles(
                padding: Padding.only(left: 12.px, top: .5.rem, bottom: .5.rem),
                display: Display.inlineFlex,
                flex: Flex(grow: 1),
              ),
            ]),
          ]),
        ]),
      ];
}
