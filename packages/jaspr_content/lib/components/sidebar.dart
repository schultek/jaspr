import 'package:jaspr/jaspr.dart';

import '../../theme.dart';
import '../jaspr_content.dart';
import '_internal/icon.dart';
import 'sidebar_toggle_button.dart';

/// A group of link entries in a [Sidebar] with an optional [title].
final class SidebarGroup {
  const SidebarGroup({
    this.title,
    required this.links,
  });

  /// The title of this group.
  final String? title;

  /// The link entries in this group.
  final List<SidebarLink> links;
}

/// An entry in a [Sidebar] with link [text] and a destination [href] url.
final class SidebarLink {
  const SidebarLink({
    required this.text,
    required this.href,
  });

  /// The link text for this sidebar entry.
  final String text;

  /// The link destination for this sidebar entry.
  final String href;
}

/// A sidebar component that renders groups of links.
///
/// Include a [SidebarToggleButton] in your app's [Header] or elsewhere
/// to enable toggling the sidebar in narrow layouts.
class Sidebar extends StatelessComponent {
  const Sidebar({this.currentRoute, required this.groups});

  /// The url of the route to highlight as active.
  ///
  /// If not specified, uses the url of the current [Page].
  final String? currentRoute;

  /// The sidebar groups of links to render.
  final List<SidebarGroup> groups;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    final currentRoute = this.currentRoute ?? context.page.url;

    yield Document.head(children: [
      Style(styles: _styles),
    ]);

    yield nav(classes: 'sidebar', [
      button(classes: 'sidebar-close', [
        const CloseIcon(size: 20),
      ]),
      div([
        for (final group in groups)
          div(classes: 'sidebar-group', [
            if (group.title case final groupTitle?) h3([text(groupTitle)]),
            ul([
              for (final item in group.links)
                li([
                  div(classes: currentRoute == item.href ? 'active' : null, [
                    a(href: item.href, [text(item.text)]),
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
                  color: ContentColors.primary,
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
