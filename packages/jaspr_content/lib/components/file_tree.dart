import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import '../theme.dart';
import '_internal/file_tree_icons.dart';

/// A file tree component for displaying a directory structure.
class FileTree extends CustomComponent {
  const FileTree() : super.base();

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node is ElementNode && node.tag == 'FileTree') {
      final child = buildFileTree(node.children ?? [], builder);
      return div(classes: 'file-tree not-content', [child]);
    }
    return null;
  }

  @override
  FileTreeTheme get theme => FileTreeTheme();

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
    final isPlaceholder = name == '...';

    final iconName = isFolder
        ? 'seti:folder'
        : isPlaceholder
        ? null
        : getIconName(name);

    return span(classes: 'tree-entry', [
      span(classes: 'tree-entry-name${isHighlight ? ' highlight' : ''}', [
        if (iconName != null) buildIcon(iconName),
        text(isPlaceholder ? '…' : name),
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
    return 'seti:default';
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
        backgroundColor: Color.variable(FileTreeTheme._backgroundVariable),
        color: Color.variable(FileTreeTheme._textVariable),
        lineHeight: 1.375.rem,
      ),
      css('ul').styles(
        listStyle: ListStyle.none,
        margin: Margin.only(left: .5.rem),
        border: Border.only(
          left: BorderSide.solid(
            width: 1.px,
            color: Color.variable(FileTreeTheme._iconVariable),
          ),
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
          color: Color.variable(FileTreeTheme._iconVariable),
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
                margin: Margin.only(left: (-1.5).rem, bottom: Unit.zero),
              ),
              css('&::marker').styles(
                color: Color.variable(FileTreeTheme._iconVariable),
              ),
              css('&:hover', [
                css('&').styles(
                  cursor: Cursor.pointer,
                  color: Color.variable(FileTreeTheme._highlightVariable),
                ),
                css('svg').styles(color: Color.variable(FileTreeTheme._highlightVariable)),
                css('.highlight svg').styles(color: Color.variable(FileTreeTheme._backgroundVariable)),
                css('~ul').styles(
                  border: Border.only(left: BorderSide(color: Color.variable(FileTreeTheme._highlightVariable))),
                ),
              ]),
            ]),
          ]),
        ]),
      ]),
      css('.tree-entry', [
        css('&').styles(
          display: Display.inlineFlex,
          alignItems: AlignItems.start,
          gap: Gap.all(0.5.rem),
          raw: {'vertical-align': 'middle'},
        ),
        css('.tree-entry-name').styles(
          display: Display.inlineFlex,
          alignItems: AlignItems.center,
        ),
        css('.comment').styles(
          padding: Padding.only(left: 1.5.rem),
          color: Color.variable(FileTreeTheme._iconVariable),
          fontStyle: FontStyle.italic,
        ),
        css('.highlight', [
          css('&').styles(
            padding: Padding.symmetric(horizontal: 0.25.rem),
            radius: BorderRadius.circular(0.25.rem),
            alignItems: AlignItems.center,
            color: Color.variable(FileTreeTheme._backgroundVariable),
            backgroundColor: Color.variable(FileTreeTheme._highlightVariable),
          ),
          css('svg').styles(
            color: Color.variable(FileTreeTheme._backgroundVariable),
          ),
        ]),
      ]),
    ]),
  ];
}

class FileTreeTheme extends ThemeExtension<FileTreeTheme> {
  FileTreeTheme({
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.highlightColor,
    this.radius,
  });

  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? highlightColor;
  final Unit? radius;

  static const _backgroundVariable = '--file-tree-bg';
  static const _textVariable = '--file-tree-text';
  static const _iconVariable = '--file-tree-icon';
  static const _highlightVariable = '--file-tree-highlight';
  static const _radiusVariable = '--file-tree-radius';

  @override
  ThemeExtension<FileTreeTheme> copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    Color? highlightColor,
    Unit? radius,
  }) {
    return FileTreeTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      iconColor: iconColor ?? this.iconColor,
      highlightColor: highlightColor ?? this.highlightColor,
      radius: radius ?? this.radius,
    );
  }

  @override
  Map<String, Object> buildVariables(ContentTheme theme) {
    return {
      _backgroundVariable: backgroundColor ?? ThemeColor(ThemeColors.gray.$200, dark: ThemeColors.gray.$900),
      _textVariable: textColor ?? ThemeColor(ThemeColors.gray.$800, dark: ThemeColors.gray.$100),
      _iconVariable: iconColor ?? ThemeColor(ThemeColors.gray.$600, dark: ThemeColors.gray.$400),
      _highlightVariable: highlightColor ?? ContentColors.primary,
      _radiusVariable: radius ?? 0.375.rem,
    };
  }

  @override
  List<StyleRule> buildStyles(ContentTheme theme) {
    return [
      css('.file-tree').styles(
        margin: Margin.only(top: 1.71.em, bottom: 1.71.em),
        radius: BorderRadius.circular(Unit.variable(FileTreeTheme._radiusVariable)),
        fontFamily: ContentTheme.currentCodeFont,
      ),
    ];
  }
}
