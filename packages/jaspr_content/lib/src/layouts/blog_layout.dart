/// @docImport 'package:jaspr_content/components/header.dart';
library;

import 'package:jaspr/server.dart' as jaspr;
import 'package:jaspr/server.dart';

import '../../theme.dart';
import '../page.dart';
import 'page_layout.dart';

/// A layout for blog articles.
///
/// This layout includes a header and title block.
///
/// It supports light and dark mode and custom theme colors.
class BlogLayout extends PageLayoutBase {
  const BlogLayout({
    this.header,
    this.textFont = _defaultTextFont,
  });

  /// The header component to render, usually a [Header].
  final Component? header;

  /// The font to use for the text content, excluding heading.
  final FontFamily textFont;

  static const _defaultTextFont = FontFamily.list([
    FontFamily('source-serif-pro'),
    FontFamily('Georgia'),
    FontFamily('Cambria'),
    FontFamilies.timesNewRoman,
    FontFamilies.times,
    FontFamilies.serif,
  ]);

  @override
  String get name => 'blog';

  @override
  Iterable<Component> buildHead(Page page) sync* {
    yield* super.buildHead(page);
    yield Style(styles: [
      ..._styles,
      css('.blog .content', [
        css('&').styles(
          fontSize: 1.125.rem,
          lineHeight: 2.rem,
        ),
        css('> :not(:is(h1,h2,h3,h4,h5,h6))').styles(
          fontFamily: textFont,
        ),
      ])
    ]);
  }

  @override
  Component buildBody(Page page, Component child) {
    final pageData = page.data.page;

    return div(classes: 'blog', [
      if (header case final header?)
        div(classes: 'header-container', [
          header,
        ]),
      div(classes: 'main-container', [
        main_([
          div(classes: 'content-container', [
            div(classes: 'post-header', [
              if (pageData['title'] case String title) h1([text(title)]),
              div(classes: 'post-info', [
                if (pageData['authorImage'] case String authorImage) img(src: authorImage, alt: 'Author image'),
                div([
                  span([text(pageData['author'] as String? ?? 'Unknown')]),
                  span([
                    text([
                      if (pageData['readTime'] case String readTime) '$readTime read',
                      if (pageData['date'] case String date) date,
                    ].join(' • ')),
                  ]),
                ]),
              ]),
            ]),
            hr(),
            child,
            if (pageData['tags'] case List<Object?> tags)
              div(classes: 'post-tags', [
                for (final tag in tags) span([text(tag.toString())]),
              ]),
          ]),
        ]),
      ]),
    ]);
  }

  static List<StyleRule> get _styles => [
        css('.blog', [
          css('.header-container', [
            css('&').styles(
              position: Position.sticky(top: Unit.zero, left: Unit.zero, right: Unit.zero),
              zIndex: ZIndex(10),
              backgroundColor: ContentColors.background,
            ),
          ]),
          css('.main-container', [
            css('&').styles(
              padding: Padding.zero,
            ),
            css.media(MediaQuery.all(minWidth: 768.px), [
              css('&').styles(padding: Padding.symmetric(horizontal: 1.25.rem)),
            ]),
            css('main', [
              css('&').styles(
                padding: Padding.only(top: 2.rem, left: 1.rem, right: 1.rem, bottom: 4.rem),
                margin: Margin.symmetric(horizontal: Unit.auto),
                maxWidth: Unit.expression('75ch'),
              ),
              css('.content-container', [
                css('.post-header', [
                  css('&').styles(
                    margin: Margin.only(bottom: 2.rem),
                  ),
                  css('h1').styles(
                    fontSize: 2.75.rem,
                    lineHeight: 3.25.rem,
                    color: ContentColors.headings,
                  ),
                  css('.post-info', [
                    css('&').styles(
                      margin: Margin.only(top: 2.rem),
                      display: Display.flex,
                      alignItems: AlignItems.center,
                      gap: Gap(column: 1.rem),
                    ),
                    css('> img').styles(width: 42.px, height: 42.px, radius: BorderRadius.circular(10.rem)),
                    css('> div', [
                      css('&').styles(
                        display: Display.flex,
                        flexDirection: FlexDirection.column,
                        color: ContentColors.text,
                      ),
                      css(':first-child').styles(
                        fontSize: 1.125.rem,
                      ),
                      css(':last-child').styles(
                        fontSize: 1.rem,
                        opacity: 0.85,
                      ),
                    ])
                  ]),
                ]),
                css('.post-tags', [
                  css('&').styles(
                    display: Display.flex,
                    flexDirection: FlexDirection.row,
                    flexWrap: FlexWrap.wrap,
                    gap: Gap.all(0.5.rem),
                    margin: Margin.only(top: 2.rem, bottom: 0.5.rem),
                  ),
                  css('span').styles(
                    padding: Padding.symmetric(horizontal: 0.75.rem, vertical: 0.25.rem),
                    radius: BorderRadius.circular(10.rem),
                    backgroundColor: ContentColors.hr,
                    fontSize: 0.875.rem,
                  )
                ])
              ]),
            ]),
          ]),
        ]),
      ];
}
