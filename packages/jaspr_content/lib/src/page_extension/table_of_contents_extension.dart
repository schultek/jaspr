import '../page.dart';
import '../page_parser/page_parser.dart';
import 'page_extension.dart';

class TocEntry {
  TocEntry(this.text, this.id, this.children);

  final String text;
  final String id;
  final List<TocEntry> children;
}

final _headerRegex = RegExp(r'^h(\d)$', caseSensitive: false);

class TableOfContentsExtension implements PageExtension {
  TableOfContentsExtension({
    this.maxHeaderDepth = 3,
  });

  final int maxHeaderDepth;

  @override
  List<Node> processNodes(List<Node> nodes, Page page) {
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

    page.data['toc'] = toc;

    return nodes;
  }

}
