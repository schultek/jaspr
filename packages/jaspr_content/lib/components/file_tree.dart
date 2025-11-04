import 'package:jaspr/jaspr.dart';

import '../jaspr_content.dart';
import '../theme.dart';
import '_internal/file_tree_icons.dart';

/// A file tree component for displaying a directory structure.
///
/// Use [FileTree.new] to use as a [CustomComponent] for jaspr_content, or [FileTree.from] to create a
/// normal [Component].
class FileTree extends CustomComponent {
  /// Creates a file tree [CustomComponent].
  ///
  /// The contents of a `<FileTree>` tag will be parsed as a file tree structure, and must be a single
  /// unordered list, with each item representing a file or folder. The following rules apply:
  /// - Folders can contain nested lists of files/folders.
  /// - Entries ending with a `/` are also treated as folders, but with no sub-list.
  /// - Folders starting with a `^` are closed by default.
  /// - Bold text indicates highlighted entries.
  /// - Comments can be added after the name of the file/folder.
  const FileTree() : super.base();

  /// Creates a file tree [Component] from the given list of [items].
  static Component from({required List<FileTreeItem> items, Key? key}) {
    return _FileTree(items: items, key: key);
  }

  @override
  Component? create(Node node, NodesBuilder builder) {
    if (node is ElementNode && node.tag == 'FileTree') {
      if (node.children case [ElementNode(tag: 'ul', :final children)]) {
        List<FileTreeItem> items = [];

        for (final child in children ?? <Node>[]) {
          items.add(buildFileTreeItem(child, builder));
        }

        return _FileTree(items: items);
      }

      throw Exception('Invalid FileTree structure, must contain a single list.');
    }
    return null;
  }

  @override
  FileTreeTheme get theme => FileTreeTheme();

  FileTreeItem buildFileTreeItem(Node node, NodesBuilder builder) {
    if (node case ElementNode(tag: 'li', :final children)) {
      List<Node> nodes = [...children ?? <Node>[]];

      String? name;
      List<Node> comment = [];
      bool isOpen = true;
      bool isHighlight = false;
      List<FileTreeItem> subItems = [];

      if (nodes case [..._, ElementNode(tag: 'ul', :final children)]) {
        for (final subChild in children ?? <Node>[]) {
          subItems.add(buildFileTreeItem(subChild, builder));
        }

        nodes.removeLast();
      }

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

      if (name!.startsWith('^')) {
        isOpen = false;
        name = name.substring(1);
      }

      return FileTreeItem(
        name: name,
        isFolder: subItems.isNotEmpty || name.endsWith('/'),
        isOpen: subItems.isNotEmpty && isOpen,
        isHighlight: isHighlight,
        comment: comment.isNotEmpty ? builder.build(comment) : null,
        children: subItems,
      );
    }

    throw Exception('Invalid FileTree item structure, must be a list item.');
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

class _FileTree extends StatelessComponent {
  const _FileTree({required this.items, super.key});

  final List<FileTreeItem> items;

  @override
  Component build(BuildContext context) {
    return div(classes: 'file-tree not-content', [
      ul([
        for (final item in items) buildFileTreeItem(item),
      ]),
    ]);
  }

  Component buildFileTreeItem(FileTreeItem item) {
    if (item.children.isNotEmpty) {
      return li(classes: 'directory', [
        details(open: item.isOpen, [
          summary([
            buildFileTreeEntry(item),
          ]),
          ul([
            for (final child in item.children) buildFileTreeItem(child),
          ]),
        ]),
      ]);
    }

    return li(classes: 'file', [buildFileTreeEntry(item)]);
  }

  Component buildFileTreeEntry(FileTreeItem item) {
    final isPlaceholder = item.name == '...';

    final iconName = item.isFolder
        ? 'seti:folder'
        : isPlaceholder
        ? null
        : getIconName(item.name);

    return span(classes: 'tree-entry', [
      span(classes: 'tree-entry-name${item.isHighlight ? ' highlight' : ''}', [
        if (iconName != null) buildIcon(iconName),
        text(isPlaceholder ? '…' : item.name),
      ]),
      if (item.comment case final comment?) span(classes: 'comment', [comment]),
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
      [raw(fileIcons[iconName] ?? '')],
    );
  }
}

class FileTreeItem {
  const FileTreeItem({
    required this.name,
    this.isFolder = false,
    this.isOpen = false,
    this.isHighlight = false,
    this.comment,
    this.children = const [],
  }) : assert(children.length > 0 || !isOpen, 'Only items with children can be open.');

  final String name;
  final bool isFolder;
  final bool isOpen;
  final bool isHighlight;
  final Component? comment;
  final List<FileTreeItem> children;
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
