import 'package:jaspr/server.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../components/icon.dart';
import '../components/menu_button.dart';
import '../components/theme_toggle.dart';
import '../src/content/content.dart';
import '../src/page.dart';
import '../src/page_extension/table_of_contents_extension.dart';
import '../src/page_layout/page_layout.dart';
import '../src/themes/reset.dart';

class DocsLayout implements PageLayout {
  const DocsLayout({
    required this.title,
    required this.logo,
    this.favicon,
    this.sidebar,
  });

  final String title;
  final String logo;
  final String? favicon;
  final Component? sidebar;

  @override
  String get name => 'docs';

  @override
  Component buildLayout(Page page, Component child) {
    return Document(
      title: switch ((page.data['title'], page.data['titleBase'])) {
        (String title, String base) => '$title | $base',
        (String title, _) => title,
        (_, String base) => base,
        _ => '',
      },
      lang: page.data['lang'] ?? 'en',
      styles: _styles,
      head: [
        if (favicon != null) link(rel: 'icon', type: 'image/png', href: favicon!),
      ],
      body: div(classes: 'docs', [
        header([
          div([
            MenuButton(),
            a(href: '/', [
              img(src: logo, alt: 'Logo'),
              span([text(title)]),
            ]),
            ThemeToggle(),
          ])
        ]),
        div(classes: 'main-container', [
          div(classes: 'sidebar-barrier', attributes: {'role': 'button'}, []),
          if (sidebar case final sidebar?)
            div(classes: 'sidebar-container', [
              sidebar,
            ]),
          main_([
            div([
              div(classes: 'content-container', [
                div(classes: 'content-header', [
                  h1([
                    text(page.data['title'] ?? 'Documentation'),
                  ]),
                  if (page.data['description'] case String description) p([text(description)]),
                  if (page.data['image'] case String image) img(src: image, alt: page.data['imageAlt']),
                ]),
                Content(children: [
                  child,
                ]),
              ]),
              if (page.data['toc'] case List<TocEntry> toc)
                aside(classes: 'toc', [
                  div([
                    h3([text('On this page')]),
                    ul([..._buildToc(toc)]),
                  ]),
                ]),
            ]),
          ]),
        ]),
      ]),
    );
  }

  Iterable<Component> _buildToc(List<TocEntry> toc, [int indent = 0]) sync* {
    for (final entry in toc) {
      yield li(styles: Styles(padding: Padding.only(left: (0.75 * indent).em)), [
        Builder(builder: (context) sync* {
          var route = RouteState.of(context);
          yield a(href: '${route.path}#${entry.id}', [text(entry.text)]);
        }),
      ]);
      if (entry.children.isNotEmpty) {
        yield* _buildToc(entry.children, indent + 1);
      }
    }
  }

  static List<StyleRule> get _styles => [
        ...resetStyles,
        css('body').styles(
          color: ContentTheme.text,
          backgroundColor: ContentTheme.background,
        ),
        css('.docs', [
          css('header', [
            css('&').styles(
                position: Position.fixed(top: Unit.zero, left: Unit.zero, right: Unit.zero),
                zIndex: ZIndex(10),
                raw: {
                  'backdrop-filter': 'blur(8px)',
                }),
            css('> div').styles(
              height: 4.rem,
              display: Display.flex,
              alignItems: AlignItems.center,
              gap: Gap(column: 1.rem),
              maxWidth: 90.rem,
              padding: Padding.symmetric(horizontal: 2.5.rem, vertical: .25.rem),
              margin: Margin.symmetric(horizontal: Unit.auto),
              border: Border.only(bottom: BorderSide(color: Color('#0000000d'), width: 1.px)),
            ),
            css('a', [
              css('&').styles(
                flex: Flex(grow: 1),
                display: Display.inlineFlex,
                alignItems: AlignItems.center,
                gap: Gap(column: .75.rem),
              )
            ]),
            css('img').styles(
              height: 1.5.rem,
              width: Unit.auto,
            ),
            css('span').styles(
              fontWeight: FontWeight.w700,
            ),
          ]),
          css('.main-container', [
            css('&').styles(
              padding: Padding.zero,
              margin: Margin.symmetric(horizontal: Unit.auto),
              maxWidth: 90.rem,
            ),
            css.media(MediaQuery.all(minWidth: 768.px), [
              css('&').styles(padding: Padding.symmetric(horizontal: 1.25.rem)),
            ]),
            css('.sidebar-barrier', [
              css('&').styles(
                position: Position.absolute(),
                zIndex: ZIndex(9),
                backgroundColor:ContentTheme.background,
                opacity: 0,
                pointerEvents: PointerEvents.none,
                raw: {'inset': '0'},
              ),
              css('&:has(+ .sidebar-container.open)').styles(
                opacity: 0.5,
                pointerEvents: PointerEvents.auto,
              ),
            ]),
            css('.sidebar-container', [
              css('&').styles(
                position: Position.fixed(bottom: Unit.zero, top: 4.rem),
                zIndex: ZIndex(10),
                width: 17.rem,
                overflow: Overflow.only(y: Overflow.auto),
                transform: Transform.translate(x: (-100).percent),
                transition: Transition('transform', duration: 150, curve: Curve.easeInOut),
              ),
              css.media(MediaQuery.all(minWidth: 768.px), [
                css('&').styles(
                  margin: Margin.only(left: (-1.25).rem),
                ),
              ]),
              css.media(MediaQuery.all(minWidth: 1024.px), [
                css('&').styles(
                  margin: Margin.only(left: Unit.zero),
                  transform: Transform.translate(x: Unit.zero),
                ),
              ]),
              css.media(MediaQuery.all(maxWidth: 1023.px), [
                css('&').styles(
                  backgroundColor: ContentTheme.background,
                  position: Position.fixed(top: Unit.zero),
                  border: Border.only(right: BorderSide(width: 1.px, color: Color('#0000000d'))),
                ),
              ]),
              css('&.open').styles(
                transform: Transform.translate(x: Unit.zero),
              ),
            ]),
            css('main', [
              css('&').styles(
                position: Position.relative(),
                padding: Padding.only(top: 4.rem),
              ),
              css.media(MediaQuery.all(minWidth: 1024.px), [
                css('&').styles(padding: Padding.only(left: 17.rem)),
              ]),
              css('> div', [
                css('&').styles(
                  padding: Padding.only(top: 2.rem, left: 1.rem, right: 1.rem),
                  display: Display.flex,
                ),
                css.media(MediaQuery.all(minWidth: 1024.px), [
                  css('&').styles(padding: Padding.only(left: 4.rem)),
                ]),
                css('.content-container', [
                  css('&').styles(
                    flex: Flex(grow: 1, shrink: 1, basis: 0.percent),
                    minWidth: Unit.zero,
                    padding: Padding.only(right: Unit.zero),
                  ),
                  css.media(MediaQuery.all(minWidth: 1280.px), [
                    css('&').styles(padding: Padding.only(right: 3.rem)),
                  ]),
                  css('.content-header', [
                    css('&').styles(
                      margin: Margin.only(bottom: 2.rem),
                    ),
                    css('h1').styles(
                      fontSize: 1.875.rem,
                      lineHeight: 2.25.rem,
                    ),
                    css('p').styles(
                      fontSize: 1.125.rem,
                      lineHeight: 1.75.rem,
                      margin: Margin.only(top: 1.rem),
                    ),
                    css('img').styles(
                      margin: Margin.only(top: 1.rem),
                      radius: BorderRadius.circular(0.375.rem),
                    )
                  ]),
                ]),
                css('aside.toc', [
                  css('&').styles(
                    display: Display.none,
                    position: Position.relative(),
                    width: 17.rem,
                  ),
                  css.media(MediaQuery.all(minWidth: 1280.px), [
                    css('&').styles(display: Display.block),
                  ]),
                  css('> div', [
                    css('&').styles(
                      position: Position.sticky(top: 6.rem),
                    ),
                  ]),
                  css('h3').styles(
                    opacity: 0.75,
                    fontWeight: FontWeight.w600,
                    fontSize: .875.rem,
                    lineHeight: 1.25.rem,
                    margin: Margin.only(bottom: .5.rem),
                  ),
                  css('ul').styles(
                    margin: Margin.only(top: 1.rem),
                  ),
                  css('li').styles(
                    margin: Margin.only(top: .5.rem),
                    fontSize: 14.px,
                  ),
                ]),
              ])
            ]),
          ]),
        ]),
      ];
}

class SidebarGroup {
  SidebarGroup({
    this.title,
    required this.items,
  });

  final String? title;
  final List<SidebarItem> items;
}

class SidebarItem {
  SidebarItem({
    required this.text,
    required this.href,
  });

  final String text;
  final String href;
}

class Sidebar extends StatelessComponent {
  const Sidebar({required this.groups});

  final List<SidebarGroup> groups;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    var currentPath = context.page.path.replaceFirst(RegExp(r'(index)?\..*$'), '');
    if (currentPath.endsWith('/')) currentPath = currentPath.substring(0, currentPath.length - 1);
    if (!currentPath.startsWith('/')) currentPath = '/$currentPath';

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
              for (final item in group.items)
                li([
                  div(classes: currentPath == item.href ? 'active' : null, [
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
