import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import '../theme.dart';
import '_internal/file_tree_icons.dart';

/// A file tree component for displaying a directory structure.
class FileTree implements CustomComponent {
  const FileTree();

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node is ElementNode && node.tag == 'FileTree') {
      final child = buildFileTree(node.children ?? [], builder);
      return Builder(
        builder: (context) {
          final children = <Component>[];
          final theme = Content.themeOf(context);

          if (theme.enabled) {
            final defaultColors = [
              FileTree.backgroundColor,
              FileTree.textColor,
              FileTree.iconColor,
            ].subtract(theme.colors);
            if (defaultColors.isNotEmpty) {
              children.add(Document.head(children: [Style(styles: defaultColors.build())]));
            }
          }

          children.add(div(classes: 'file-tree not-content', [child]));
          return Component.fragment(children);
        },
      );
    }
    return null;
  }

  Component buildFileTree(List<Node> nodes, NodesBuilder builder) {
    if (nodes case [ElementNode(tag: 'ul', :final children)]) {
      List<Component> items = [];

      for (final child in children ?? <Node>[]) {
        items.add(buildFileTreeItem(child, builder));
      }

      return ul(items);
    }

    throw Exception('Invalid FileTree structure, must contain a single list.');
  }

  Component buildFileTreeItem(Node node, NodesBuilder builder) {
    if (node case ElementNode(tag: 'li', :final children)) {
      if (children case [...final inner, ElementNode(tag: 'ul', :final children)]) {
        List<Component> subItems = [];

        for (final subChild in children ?? <Node>[]) {
          subItems.add(buildFileTreeItem(subChild, builder));
        }

        return li(classes: 'directory', [
          details(open: true, [
            summary([
              buildFileTreeEntry(inner, builder, isFolder: true),
            ]),
            ul(subItems),
          ]),
        ]);
      }

      return li(classes: 'file', [buildFileTreeEntry(children ?? <Node>[], builder)]);
    }

    throw Exception('Invalid FileTree item structure, must be a list item.');
  }

  Component buildFileTreeEntry(List<Node> nodes, NodesBuilder builder, {bool isFolder = false}) {

    String? name;
    List<Node> comment = [];
    bool isHighlight = false;

    for (final node in nodes) {
      if (name == null) {
        if (node is ElementNode && node.tag == 'strong') {
          isHighlight = true;
          name = node.innerText;
          continue;
        } else if (node is TextNode) {
          final [namePart, ...commentParts] = node.text.split(' ');
          name = namePart;
          if (commentParts.isNotEmpty) {
            comment.add(TextNode(commentParts.join(' ')));
          }
        } else {
          name = node.innerText;
        }
      } else {
        comment.add(node);
      }
    }

    isFolder |= name!.endsWith('/');

    final iconName = isFolder ? 'seti:folder' : getIconName(name);

    return span(classes: 'tree-entry', [
      span(classes: 'tree-entry-name${isHighlight ? ' highlight' : ''}', [
        if (iconName != null) buildIcon(iconName),
        text(name),
      ]),
      if (comment.isNotEmpty)
        span(classes: 'comment', [
          builder.build(comment),
        ]),
    ]);
  }

  String? getIconName(String fileName) {
    String? icon = definitions['files']![fileName];
    if (icon != null) {
      return icon;
    }
    icon = getFileIconTypeFromExtension(fileName);
    if (icon != null) return icon;
    for (final MapEntry(key: partial, value: partialIcon) in definitions['partials']!.entries) {
      if (fileName.contains(partial)) return partialIcon;
    }
    return null;
  }

  String? getFileIconTypeFromExtension(String fileName) {
    final firstDotIndex = fileName.indexOf('.');
    if (firstDotIndex == -1) return null;
    var extension = fileName.substring(firstDotIndex);
    while (extension != '') {
      final icon = definitions['extensions']![extension];
      if (icon != null) return icon;
      final nextDotIndex = extension.indexOf('.', 1);
      if (nextDotIndex == -1) return null;
      extension = extension.substring(nextDotIndex);
    }
    return null;
  }

  Component buildIcon(String iconName) {
    return svg(
      viewBox: '0 0 24 24',
      attributes: {'fill': 'currentColor', 'width': '16', 'height': '16'},
      [
        raw(fileIcons[iconName] ?? ''),
      ],
    );
  }

  static ColorToken get backgroundColor =>
      ColorToken('file-tree-bg', ThemeColors.gray.$200, dark: ThemeColors.gray.$900);
  static ColorToken get textColor => ColorToken('file-tree-text', ThemeColors.gray.$800, dark: ThemeColors.gray.$100);
  static ColorToken get iconColor => ColorToken('file-tree-icon', ThemeColors.gray.$600, dark: ThemeColors.gray.$400);

  @css
  static List<StyleRule> get styles => [
    css('.file-tree', [
      css('&').styles(
        display: Display.block,
        padding: Padding.all(1.rem),
        fontSize: 0.8125.rem,
        backgroundColor: backgroundColor,
        color: textColor,
        margin: Margin.only(top: 1.71.em, bottom: 1.71.em),
        radius: BorderRadius.circular(0.375.rem),
        fontFamily: ContentTheme.defaultCodeFont,
        lineHeight: 1.375.rem,
      ),
      css('ul').styles(
        listStyle: ListStyle.none,
        margin: Margin.only(left: .5.rem),
        border: Border.only(
          left: BorderSide.solid(width: 1.px, color: iconColor),
        ),
        padding: Padding.only(left: .125.rem),
      ),
      css('> ul').styles(
        padding: Padding.zero,
        margin: Margin.zero,
        border: Border.none,
      ),
      css('li', [
        css('&').styles(
          margin: Margin.symmetric(vertical: 0.125.rem),
        ),
        css('&.file').styles(
          display: Display.flex,
          margin: Margin.only(left: 1.25.rem),
        ),
        css('svg').styles(
          display: Display.inline,
          margin: Margin.only(left: .25.rem, right: .375.rem),
          width: .875.rem,
          height: .875.rem,
          color: iconColor,
          raw: {
            'vertical-align': 'middle',
          },
        ),
        css('&.directory', [
          css('> details', [
            css('&').styles(
              padding: Padding.only(left: 1.5.rem),
              border: Border.none,
              backgroundColor: Colors.transparent,
            ),
            css('> summary', [
              css('&').styles(
                maxWidth: 100.percent,
                padding: Padding.symmetric(horizontal: .625.rem),
                margin: Margin.only(left: (-1.5).rem),
              ),
              css('&::marker').styles(
                color: iconColor,
              ),
              css('&:hover', [
                css('&').styles(
                  cursor: Cursor.pointer,
                  color: ContentColors.primary,
                ),
                css('svg').styles(color: ContentColors.primary),
                css('~ul').styles(
                  border: Border.only(left: BorderSide(color: ContentColors.primary)),
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
      css('.tree-entry', [
        css('&').styles(
          display: Display.inlineFlex,
          alignItems: AlignItems.center,
          gap: Gap.all(0.5.rem),
          raw: {'vertical-align': 'middle'},
        ),
        css('.tree-entry-name').styles(
          display: Display.inlineFlex,
          alignItems: AlignItems.center,
        ),
        css('.comment').styles(
          padding: Padding.only(left: 1.5.rem),
          color: iconColor,
          fontStyle: FontStyle.italic,
        ),
        css('.highlight', [
          css('&').styles(
            padding: Padding.symmetric(horizontal: 0.25.rem),
            radius: BorderRadius.circular(0.25.rem),
            alignItems: AlignItems.center,
            color: backgroundColor,
            backgroundColor: ContentColors.primary,
          ),
          css('svg').styles(color: backgroundColor),
        ]),
      ]),
    ]),
  ];
}
