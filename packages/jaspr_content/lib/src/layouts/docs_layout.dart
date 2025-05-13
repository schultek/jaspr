/// @docImport '../components/header.dart';
/// @docImport '../components/sidebar.dart';
library;

import 'package:jaspr/server.dart' as jaspr;
import 'package:jaspr/server.dart';

import '../page.dart';
import '../page_extension/table_of_contents_extension.dart';
import '../theme/theme.dart';
import 'page_layout.dart';

/// A layout for documentation pages.
///
/// This layout includes a sidebar and a header.
/// It also renders a table of contents when the [TableOfContentsExtension] is applied to the page.
///
/// It supports light and dark mode and custom theme colors.
///
/// The sidebar is usually a [Sidebar] component but may be any custom component.
/// The header is usually a [Header] component but may be any custom component.
class DocsLayout extends PageLayoutBase {
  const DocsLayout({
    this.sidebar,
    this.header,
    this.footer,
  });

  /// The sidebar component to render, usually a [Sidebar].
  final Component? sidebar;

  /// The header component to render, usually a [Header].
  final Component? header;

  /// The footer component to render below the content.
  final Component? footer;

  @override
  String get name => 'docs';

  @override
  Iterable<Component> buildHead(Page page) sync* {
    yield* super.buildHead(page);
    yield Style(styles: _styles);
  }

  @override
  Component buildBody(Page page, Component child) {
    final pageData = page.data['page'] ?? {};

    return div(classes: 'docs', [
      if (header case final header?)
        div(classes: 'header-container', attributes: {
          if (sidebar != null) 'data-has-sidebar': ''
        }, [
          header,
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
                if (pageData['title'] case String title) h1([text(title)]),
                if (pageData['description'] case String description) p([text(description)]),
                if (pageData['image'] case String image) img(src: image, alt: pageData['imageAlt']),
              ]),
              child,
              if (footer case final footer?)
                div(classes: 'content-footer', [
                  footer,
                ]),
            ]),
            aside(classes: 'toc', [
              if (page.data['toc'] case TableOfContents toc)
                div([
                  h3([text('On this page')]),
                  toc.build(),
                ]),
            ]),
          ]),
        ]),
      ]),
    ]);
  }

  static List<StyleRule> get _styles => [
        css('.docs', [
          css('.header-container', [
            css('&').styles(
              position: Position.fixed(top: Unit.zero, left: Unit.zero, right: Unit.zero),
              zIndex: ZIndex(10),
              raw: {
                'backdrop-filter': 'blur(8px)',
              },
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
                backgroundColor: ContentColors.background,
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
                  backgroundColor: ContentColors.background,
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
                      color: ContentColors.headings,
                    ),
                    css('h1').styles(
                      fontSize: 2.rem,
                      lineHeight: 2.25.rem,
                    ),
                    css('p').styles(
                      fontSize: 1.25.rem,
                      lineHeight: 1.25.rem,
                      margin: Margin.only(top: .75.rem),
                    ),
                    css('img').styles(
                      margin: Margin.only(top: 1.rem),
                      radius: BorderRadius.circular(0.375.rem),
                    )
                  ]),
                  css('.content-footer', [
                    css('&').styles(
                      margin: Margin.only(top: 2.rem),
                    ),
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
