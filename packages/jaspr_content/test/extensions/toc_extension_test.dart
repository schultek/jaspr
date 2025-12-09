import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

void main() {
  group('TableOfContentsExtension', () {
    final page = Page(
      path: '/some/path.md',
      url: '/some/path',
      content: '',
      config: PageConfig(),
      loader: FilesystemLoader('_'),
    );

    test('generates TOC from basic headers', () {
      final nodes = [
        ElementNode('h2', {'id': 'header-1'}, [TextNode('Header 1')]),
        ElementNode('p', {}, [TextNode('Paragraph under Header 1')]),
        ElementNode('h3', {'id': 'subheader-1-1'}, [TextNode('Subheader 1.1')]),
        ElementNode('p', {}, [TextNode('Paragraph under Subheader 1.1')]),
        ElementNode('h2', {'id': 'header-2'}, [TextNode('Header 2')]),
        ElementNode('p', {}, [TextNode('Paragraph under Header 2')]),
      ];

      final extension = TableOfContentsExtension();
      extension.apply(page, nodes);

      final toc = page.data['toc'] as TableOfContents;
      expect(toc.entries.length, 2);
      expect(toc.entries[0].text, 'Header 1');
      expect(toc.entries[0].children.length, 1);
      expect(toc.entries[0].children[0].text, 'Subheader 1.1');
      expect(toc.entries[1].text, 'Header 2');
    });

    test('ignores headers without IDs', () {
      final nodes = [
        ElementNode('h2', {}, [TextNode('Header without ID')]),
        ElementNode('h2', {'id': 'header-with-id'}, [TextNode('Header with ID')]),
      ];

      final extension = TableOfContentsExtension();
      extension.apply(page, nodes);

      final toc = page.data['toc'] as TableOfContents;
      expect(toc.entries.length, 1);
      expect(toc.entries[0].text, 'Header with ID');
    });

    test('respects maxHeaderDepth', () {
      final nodes = [
        ElementNode('h2', {'id': 'header-1'}, [TextNode('Header 1')]),
        ElementNode('h3', {'id': 'subheader-1-1'}, [TextNode('Subheader 1.1')]),
        ElementNode('h4', {'id': 'subsubheader-1-1-1'}, [TextNode('Subsubheader 1.1.1')]),
      ];

      final extension = TableOfContentsExtension(maxHeaderDepth: 3);
      extension.apply(page, nodes);

      final toc = page.data['toc'] as TableOfContents;
      expect(toc.entries.length, 1);
      expect(toc.entries[0].text, 'Header 1');
      expect(toc.entries[0].children.length, 1);
      expect(toc.entries[0].children[0].text, 'Subheader 1.1');
      expect(toc.entries[0].children[0].children.length, 0); // h4 should be ignored
    });

    test('ignores headers with no_toc class', () {
      final nodes = [
        ElementNode('h2', {'id': 'header-1', 'class': 'no_toc'}, [TextNode('Header 1')]),
        ElementNode('h2', {'id': 'header-2'}, [TextNode('Header 2')]),
      ];

      final extension = TableOfContentsExtension();
      extension.apply(page, nodes);

      final toc = page.data['toc'] as TableOfContents;
      expect(toc.entries.length, 1);
      expect(toc.entries[0].text, 'Header 2');
    });

    test('recurses into child nodes', () {
      final nodes = [
        ElementNode('div', {}, [
          ElementNode('h2', {'id': 'header-1'}, [TextNode('Header 1')]),
          ElementNode('div', {}, [
            ElementNode('h3', {'id': 'subheader-1-1'}, [TextNode('Subheader 1.1')]),
          ]),
        ]),
      ];

      final extension = TableOfContentsExtension();
      extension.apply(page, nodes);

      final toc = page.data['toc'] as TableOfContents;
      expect(toc.entries.length, 1);
      expect(toc.entries[0].text, 'Header 1');
      expect(toc.entries[0].children.length, 1);
      expect(toc.entries[0].children[0].text, 'Subheader 1.1');
    });
  });
}
