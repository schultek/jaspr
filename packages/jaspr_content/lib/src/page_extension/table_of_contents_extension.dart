import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../page.dart';
import '../page_parser/page_parser.dart';
import 'page_extension.dart';

/// An extension that generates a table of contents from the headers in the page.
///
/// The resulting [TableOfContents] object is stored in the page's data under the 'toc' key.
/// It may be consumed by a layout to display the table of contents.
class TableOfContentsExtension implements PageExtension {
  const TableOfContentsExtension({
    this.maxHeaderDepth = 3,
  });

  final int maxHeaderDepth;

  static final _headerRegex = RegExp(r'^h(\d)$', caseSensitive: false);

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    final toc = <TocEntry>[];
    final stack = <TocEntry>[];

    for (final node in nodes) {
      if (node is! ElementNode) continue;
      final depth = _headerRegex.firstMatch(node.tag)?.group(1);
      if (depth == null) continue;
      final level = int.parse(depth) - 2;
      if (level < 0 || level > maxHeaderDepth - 2) continue;

      final id = node.attributes['id'];
      // Header can't be linked to without an id.
      if (id == null) continue;

      // Don't include if no_toc is specified as a class on the header.
      if (node.attributes['class']?.contains('no_toc') ?? false) continue;

      final text = node.innerText;
      final entry = TocEntry(text, id, []);

      while (level < stack.length) {
        stack.removeLast();
      }

      if (level > stack.length) {
        // Found h(x+1) without previous h(x) header.
        continue;
      }

      if (stack.isEmpty) {
        toc.add(entry);
        stack.add(entry);
      } else {
        stack.last.children.add(entry);
      }
    }

    page.apply(data: {'toc': TableOfContents(toc)});

    return nodes;
  }
}

class TableOfContents {
  const TableOfContents(this.entries);

  final List<TocEntry> entries;

  Component build() {
    return ul([..._buildToc(entries)]);
  }

  Iterable<Component> _buildToc(List<TocEntry> toc, [int indent = 0]) sync* {
    for (final entry in toc) {
      yield li(styles: Styles(padding: Padding.only(left: (0.75 * indent).em)), [
        Builder(builder: (context) {
          var route = RouteState.of(context);
          return a(href: '${route.path}#${entry.id}', [text(entry.text)]);
        }),
      ]);
      if (entry.children.isNotEmpty) {
        yield* _buildToc(entry.children, indent + 1);
      }
    }
  }
}

class TocEntry {
  TocEntry(this.text, this.id, this.children);

  final String text;
  final String id;
  final List<TocEntry> children;
}
