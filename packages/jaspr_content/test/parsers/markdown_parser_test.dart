import 'package:jaspr_content/jaspr_content.dart';
import 'package:test/test.dart';

void main() {
  group('MarkdownParser', () {
    List<Node> parseMarkdown(String content) {
      return MarkdownParser().parsePage(
        Page(
          url: '/test',
          path: 'test.md',
          content: content,
          initialData: {},
          config: PageConfig(),
          loader: FilesystemLoader('_'),
        ),
      );
    }

    group('Basic Markdown', () {
      test('should parse a simple markdown string', () {
        final nodes = parseMarkdown('# Hello World\n\nThis is a test.');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'hello-world'}, [TextNode('Hello World')]),
            ElementNode('p', {}, [TextNode('This is a test.')]),
          ]),
        );
      });

      test('should parse common markdown syntax', () {
        // Tests headers, lists, emphasis, links, images, blockquotes, code blocks, and horizontal rules.
        final nodes = parseMarkdown('''
# Header 1
## Header 2

- List item 1
- List item 2
  - List item 2.1

**Bold Text** and *Italic Text*. Also `inline <code>`.

[Link](https://example.com) and ![Image](https://example.com/image.png).

> Blockquote text.

```dart
void main() {
  print('Hello, World!');
}
```

---
''');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'header-1'}, [TextNode('Header 1')]),
            ElementNode('h2', {'id': 'header-2'}, [TextNode('Header 2')]),
            ElementNode('ul', {}, [
              ElementNode('li', {}, [TextNode('List item 1')]),
              ElementNode('li', {}, [
                TextNode('List item 2'),
                ElementNode('ul', {}, [
                  ElementNode('li', {}, [TextNode('List item 2.1')]),
                ]),
              ]),
            ]),
            ElementNode('p', {}, [
              ElementNode('strong', {}, [TextNode('Bold Text')]),
              TextNode(' and '),
              ElementNode('em', {}, [TextNode('Italic Text')]),
              TextNode('. Also '),
              ElementNode('code', {}, [TextNode('inline <code>')]),
              TextNode('.'),
            ]),
            ElementNode('p', {}, [
              ElementNode('a', {'href': 'https://example.com'}, [TextNode('Link')]),
              TextNode(' and '),
              ElementNode('img', {'src': 'https://example.com/image.png', 'alt': 'Image'}, []),
              TextNode('.'),
            ]),
            ElementNode('blockquote', {}, [
              ElementNode('p', {}, [TextNode('Blockquote text.')]),
            ]),
            ElementNode('pre', {}, [
              ElementNode(
                'code',
                {'class': 'language-dart'},
                [TextNode("void main() {\n  print('Hello, World!');\n}\n")],
              ),
            ]),
            ElementNode('hr', {}, []),
          ]),
        );
      });

      test('should not encode HTML characters in markdown', () {
        final nodes = parseMarkdown('''
2 > 1

0x5 & 0x3 = 0x1

Hello &lt;World&gt;
''');
        expect(
          nodes,
          matchNodes([
            ElementNode('p', {}, [TextNode('2 > 1')]),
            ElementNode('p', {}, [TextNode('0x5 & 0x3 = 0x1')]),
            ElementNode('p', {}, [TextNode('Hello <World>')]),
          ]),
        );
      });
    });

    group("HTML in Markdown", () {
      test('should parse embedded HTML within markdown', () {
        final nodes = parseMarkdown('''
# Hello World

<div class="custom-html">This is custom HTML.</div>

A normal paragraph.

```html
<div>HTML code block</div>
```

Some <sub>inline</sub> HTML.<br>Span with <strong>bold</strong> text.
''');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'hello-world'}, [TextNode('Hello World')]),
            ElementNode('div', {'class': 'custom-html'}, [TextNode('This is custom HTML.')]),
            ElementNode('p', {}, [TextNode('A normal paragraph.')]),
            ElementNode('pre', {}, [
              ElementNode('code', {'class': 'language-html'}, [TextNode('<div>HTML code block</div>\n')]),
            ]),
            ElementNode('p', {}, [
              TextNode('Some '),
              ElementNode('sub', {}, [TextNode('inline')]),
              TextNode(' HTML.'),
              ElementNode('br', {}, []),
              TextNode('Span with '),
              ElementNode('strong', {}, [TextNode('bold')]),
              TextNode(' text.'),
            ]),
          ]),
        );
      });

      test('should parse markdown with HTML tags', () {
        final nodes = parseMarkdown('''
# Markdown with HTML
<div class="inline-html">This is **not** markdown.</div>

<div class="block-html">

  This **is** markdown.
</div>

<div class="quote">

  > Some quoted text.
</div>
''');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'markdown-with-html'}, [TextNode('Markdown with HTML')]),
            ElementNode('div', {'class': 'inline-html'}, [TextNode('This is **not** markdown.')]),
            ElementNode(
              'div',
              {'class': 'block-html'},
              [
                ElementNode('p', {}, [
                  TextNode('  This '),
                  ElementNode('strong', {}, [TextNode('is')]),
                  TextNode(' markdown.'),
                ]),
              ],
            ),
            ElementNode(
              'div',
              {'class': 'quote'},
              [
                ElementNode('blockquote', {}, [
                  ElementNode('p', {}, [TextNode('Some quoted text.')]),
                ]),
              ],
            ),
          ]),
        );
      });

      test('should handle self-closing HTML tags', () {
        final nodes = parseMarkdown('''
# Self-Closing Tags
<img src="image.png" alt="Image">

Some text after the image.

<br>

<a href="/world" class="link">
  <img src="/assets/the-world.png" alt="The World">
  <span>Hello world!</span>
</a>
''');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'self-closing-tags'}, [TextNode('Self-Closing Tags')]),
            ElementNode('img', {'src': 'image.png', 'alt': 'Image'}, []),
            ElementNode('p', {}, [TextNode('Some text after the image.')]),
            ElementNode('br', {}, []),
            ElementNode(
              'a',
              {'href': '/world', 'class': 'link'},
              [
                TextNode('\n  '),
                ElementNode('img', {'src': '/assets/the-world.png', 'alt': 'The World'}, []),
                TextNode('\n  '),
                ElementNode('span', {}, [TextNode('Hello world!')]),
                TextNode('\n'),
              ],
            ),
          ]),
        );
      });

      test('should parse comments and processing instructions as comments', () {
        final nodes = parseMarkdown('''
# HTML Comments and Processing Instructions
<!-- This is a comment -->
<?php echo "Hello, World!"; ?>
Content after comment and processing instruction.
''');
        expect(
          nodes,
          matchNodes([
            ElementNode(
              'h1',
              {'id': 'html-comments-and-processing-instructions'},
              [TextNode('HTML Comments and Processing Instructions')],
            ),
            TextNode('<!-- This is a comment -->', raw: true),
            TextNode('\n'),
            TextNode('<!--php echo "Hello, World!"; -->', raw: true),
            ElementNode('p', {}, [TextNode('Content after comment and processing instruction.')]),
          ]),
        );
      });

      test('should parse tags with line-breaks', () {
        final nodes = parseMarkdown('''
# HTML with Line-Breaks

<div id="foo"
  class="bar">

  Some content here.
</div>
''');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'html-with-line-breaks'}, [TextNode('HTML with Line-Breaks')]),
            ElementNode(
              'div',
              {'id': 'foo', 'class': 'bar'},
              [
                ElementNode('p', {}, [TextNode('  Some content here.')]),
              ],
            ),
          ]),
        );
      });

      test('should handle code blocks within html tags', () {
        final nodes = parseMarkdown('''
# Code Blocks in HTML

<div>

```dart
void method<T>(T t) {
  print(t);
}
```
</div>''');
        expect(
          nodes,
          matchNodes([
            ElementNode('h1', {'id': 'code-blocks-in-html'}, [TextNode('Code Blocks in HTML')]),
            ElementNode('div', {}, [
              ElementNode('pre', {}, [
                ElementNode('code', {'class': 'language-dart'}, [TextNode('void method<T>(T t) {\n  print(t);\n}\n')]),
              ]),
            ]),
          ]),
        );
      });
    });
  });
}

Matcher matchNodes(List<Node> expected) {
  return equals([for (final node in expected) matchNode(node)]);
}

Matcher matchNode(Node expected) {
  if (expected is TextNode) {
    return isA<TextNode>().having((n) => n.text, 'text', expected.text).having((n) => n.raw, 'raw', expected.raw);
  } else if (expected is ElementNode) {
    return isA<ElementNode>()
        .having((n) => n.tag, 'tag', expected.tag)
        .having((n) => n.attributes, 'attributes', expected.attributes)
        .having((n) => n.children, 'children', matchNodes(expected.children ?? []));
  }
  throw ArgumentError('Unsupported node type: ${expected.runtimeType}');
}
