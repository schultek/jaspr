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
      return div(classes: 'file-tree not-content', [child]);
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
    final content = nodes.map((n) => n.innerText).join();
    final isHighlight = nodes.firstOrNull is ElementNode && (nodes.firstOrNull as ElementNode).tag == 'strong';
    final [fileOrDirectory, ...comments] = content.split(' ');

    isFolder |= fileOrDirectory.endsWith('/');

    final iconName = isFolder ? 'seti:folder' : getIconName(fileOrDirectory);

    return span(classes: 'tree-entry', [
      span(classes: isHighlight ? 'highlight' : null, [
        if (iconName != null) buildIcon(iconName),
        text(fileOrDirectory),
      ]),
      if (comments.isNotEmpty)
        span(classes: 'comment', [
          text(' ${comments.join(' ')}'),
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

  @css
  static List<StyleRule> get styles => [
    css('.file-tree', [
      css('&').styles(
        display: Display.block,
        padding: Padding.all(1.rem),
        fontSize: 0.8125.rem,
        backgroundColor: ContentColors.preBg,
        color: ContentColors.preCode,
        margin: Margin.only(top: 1.71.em, bottom: 1.71.em),
        radius: BorderRadius.circular(0.375.rem),
        fontFamily: ContentTheme.defaultCodeFont,
        lineHeight: 1.375.rem
      ),
      css('ul').styles(
        listStyle: ListStyle.none,
        margin: Margin.only(left: .5.rem),
        border: Border.only(
          left: BorderSide.solid(width: 1.px, color: ContentColors.bullets),
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
          margin: Margin.only(left: 1.25.rem),
        ),
        css('svg').styles(
          display: Display.inline,
          margin: Margin.only(left: .25.rem, right: .375.rem),
          width: .875.rem,
          height: .875.rem,
          color: ContentColors.bullets,
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
            css('> summary').styles(
              margin: Margin.only(left: (-1.5).rem),
              padding: Padding.symmetric(horizontal: .625.rem),
              maxWidth: 100.percent,
            ),
            css('> summary::marker').styles(
              color: ContentColors.bullets,
            ),
          ]),
        ]),
      ]),
      css('.tree-entry', [
        css('&').styles(
          display: Display.inlineFlex,
          alignItems: AlignItems.center,
          gap: Gap.all(0.5.rem),
        ),
        css('.comment').styles(
          color: ContentColors.captions,
          fontStyle: FontStyle.italic,
        ),
        css('.highlight').styles(
          backgroundColor: ContentColors.primary,
          padding: Padding.symmetric(horizontal: 0.25.rem),
          radius: BorderRadius.circular(0.25.rem),
        ),
      ]),
    ]),
  ];
}
