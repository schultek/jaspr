import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

void main() {
  group('HeadingAnchorsExtension', () {
    final page = Page(
      path: '/some/path.md',
      url: '/some/path',
      content: '',
      config: PageConfig(),
      loader: FilesystemLoader('_'),
    );

    test('generates heading anchors from basic headers', () async {
      final nodes = [
        ElementNode('h2', {'id': 'header-1'}, [TextNode('Header 1')]),
        ElementNode('p', {}, [TextNode('Paragraph under Header 1')]),
        ElementNode('h3', {'id': 'subheader-1-1'}, [TextNode('Subheader 1.1')]),
        ElementNode('p', {}, [TextNode('Paragraph under Subheader 1.1')]),
        ElementNode('h2', {'id': 'header-2'}, [TextNode('Header 2')]),
        ElementNode('p', {}, [TextNode('Paragraph under Header 2')]),
      ];

      final extension = HeadingAnchorsExtension();
      final output = await extension.apply(page, nodes);

      expect(output.length, 7); // 6 original nodes + 1 style nodes
      expect(output[0], isA<ComponentNode>()); // Style node
      expect(output[1], isHeaderWithAnchor('h2', 'header-1', 'Header 1'));
      expect(output[2], isElementWithTag('p')); // Paragraph under Header 1
      expect(output[3], isHeaderWithAnchor('h3', 'subheader-1-1', 'Subheader 1.1'));
      expect(output[4], isElementWithTag('p')); // Paragraph under Subheader 1.1
      expect(output[5], isHeaderWithAnchor('h2', 'header-2', 'Header 2'));
      expect(output[6], isElementWithTag('p')); // Paragraph under Header 2
    });

    test('ignores headers without IDs', () async {
      final nodes = [
        ElementNode('h2', {}, [TextNode('Header without ID')]),
        ElementNode('h2', {'id': 'header-with-id'}, [TextNode('Header with ID')]),
      ];

      final extension = HeadingAnchorsExtension();
      final output = await extension.apply(page, nodes);

      expect(output.length, 3); // 2 original nodes + 1 style node
      expect(output[0], isA<ComponentNode>()); // Style node
      expect(output[1], isElementWithTag('h2', {'id': isNull})); // Header without ID
      expect(output[2], isHeaderWithAnchor('h2', 'header-with-id', 'Header with ID'));
    });

    test('ignores headers with no_anchors class', () async {
      final nodes = [
        ElementNode('h2', {'id': 'header-1', 'class': 'no_anchors'}, [TextNode('Header 1')]),
        ElementNode('h2', {'id': 'header-2'}, [TextNode('Header 2')]),
      ];

      final extension = HeadingAnchorsExtension();
      final output = await extension.apply(page, nodes);

      expect(output.length, 3); // 2 original nodes + 1 style node
      expect(output[0], isA<ComponentNode>()); // Style node
      expect(output[1], isElementWithTag('h2', {'id': 'header-1'})); // Header 1 without anchor
      expect(output[2], isHeaderWithAnchor('h2', 'header-2', 'Header 2'));
    });

    test('recurses into child nodes', () async {
      final nodes = [
        ElementNode('div', {}, [
          ElementNode('h2', {'id': 'header-1'}, [TextNode('Header 1')]),
          ElementNode('p', {}, [TextNode('Paragraph under Header 1')]),
        ]),
      ];

      final extension = HeadingAnchorsExtension();
      final output = await extension.apply(page, nodes);

      expect(output.length, 2); // 1 original div node + 1 style node
      expect(output[0], isA<ComponentNode>()); // Style node
      expect(output[1], isElementWithTag('div'));

      final divNode = output[1] as ElementNode;
      expect(divNode.children!.length, 2);

      expect(divNode.children![0], isHeaderWithAnchor('h2', 'header-1', 'Header 1'));
      expect(divNode.children![1], isElementWithTag('p')); // Paragraph under Header 1
    });
  });
}

Matcher isElementWithTag(String tag, [Map<String, Object?>? attributes]) {
  return predicate((node) {
    return node is ElementNode &&
        node.tag == tag &&
        (attributes == null ||
            attributes.entries.every((entry) {
              return entry.value is Matcher
                  ? (entry.value as Matcher).matches(node.attributes[entry.key], {})
                  : node.attributes[entry.key] == entry.value;
            }));
  }, 'is ElementNode with tag <$tag>');
}

Matcher isHeaderWithAnchor(String tag, String id, String text) {
  return predicate((node) {
    if (node is! ElementNode) return false;
    if (node.tag != tag) return false;
    if (node.attributes['id'] != id) return false;
    if (node.children == null || node.children!.length != 2) return false;

    final spanNode = node.children![0];
    final anchorNode = node.children![1];

    if (spanNode is! ElementNode || spanNode.tag != 'span') return false;
    if (spanNode.children == null ||
        spanNode.children!.length != 1 ||
        spanNode.children![0] is! TextNode ||
        (spanNode.children![0] as TextNode).text != text) {
      return false;
    }

    if (anchorNode is! ComponentNode) return false;

    return true;
  }, 'is header <$tag> with id="$id" and anchor');
}
