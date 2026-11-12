@TestOn('vm')
library;

import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:jaspr/server.dart';
import 'package:jaspr/src/server/adapters/document_structure_helper.dart';
import 'package:test/test.dart';

void main() {
  group('render adapters', () {
    test('creates a body when the head is nested in a marked fragment', () async {
      final document = await _renderDocument(
        .element(
          tag: 'html',
          children: [
            .element(tag: 'aside', children: []),
            _marked(
              .fragment([
                .text('before'),
                _marked(.element(tag: 'head', children: [])),
                .text('after'),
              ]),
            ),
            .element(tag: 'main', children: [.text('content')]),
          ],
        ),
      );
      expect(_describeNodes(document.documentElement!), ['<!--boundary-->', '<head>', '<!--/boundary-->', '<body>']);
      expect(_describeNodes(document.body!), [
        '<aside>',
        '<!--boundary-->',
        'beforeafter',
        '<!--/boundary-->',
        '<main>',
      ]);
    });

    test('keeps other content in the body when the head shares a nested fragment with it', () async {
      final document = await _renderDocument(
        .element(
          tag: 'html',
          children: [
            _marked(
              .fragment([
                .fragment([.element(tag: 'head', children: []), .text('stray')]),
              ]),
            ),
            .element(tag: 'main', children: [.text('content')]),
          ],
        ),
      );
      expect(_describeNodes(document.documentElement!), ['<head>', '<body>']);
      expect(_describeNodes(document.body!), ['<!--boundary-->', 'stray', '<!--/boundary-->', '<main>']);
    });

    for (final (name, wrapHead) in <(String, Component Function(Component head))>[
      ('nested marked components', (head) => _marked(_marked(head))),
      (
        'marked fragments that only contain it',
        (head) => _marked(
          .fragment([
            _marked(.fragment([head])),
          ]),
        ),
      ),
    ]) {
      test('keeps the head boundaries of $name together when creating the document body', () async {
        final document = await _renderDocument(
          .element(
            tag: 'html',
            children: [
              wrapHead(.element(tag: 'head', children: [])),
              .element(tag: 'main', children: [.text('content')]),
            ],
          ),
        );
        expect(_describeNodes(document.documentElement!), [
          '<!--boundary-->',
          '<!--boundary-->',
          '<head>',
          '<!--/boundary-->',
          '<!--/boundary-->',
          '<body>',
        ]);
        expect(_describeNodes(document.body!), ['<main>']);
      });
    }

    test('keeps existing groups consistent when creating a body around existing contents', () {
      final root = RootMarkupRenderObject();
      final html = root.createChildRenderElement('html');
      root.children.insertAfter(html);
      final head = html.createChildRenderElement('head');
      final content = html.createChildRenderText('content');
      html.children
        ..insertBefore(head)
        ..insertBefore(content);
      final captured = html.children.capture();
      html.children.insertAfter(captured);

      final document = createDocumentStructure(root);
      expect(document.head, same(head));
      expect(html.children.toList(), [head, document.body]);
      expect(document.body.children.toList(), [content]);
      // The group still contains what it did, minus the head moved out of it.
      expect(captured.children.toList(), [content]);
      expect(createDocumentStructure(root), document);
    });

    test('nests boundaries by priority when marking while preparing', () async {
      final output = await _render(
        Builder(
          builder: (context) {
            for (final priority in [1, 3, 0, 2]) {
              (context.binding as ServerAppBinding).addRenderAdapter(
                _MarkingAdapter(context as Element, label: '$priority', priority: priority, duringPrepare: true),
              );
            }
            return .fragment([]);
          },
        ),
        standalone: true,
      );
      expect(parseFragment(output).nodes.whereType<dom.Comment>().map((node) => node.data), [
        '3',
        '2',
        '1',
        '0',
        '/0',
        '/1',
        '/2',
        '/3',
      ]);
    });

    test('marks a component whose output is an empty fragment', () async {
      final output = parseFragment(await _render(_marked(.fragment([])), standalone: true));
      expect(output.nodes.whereType<dom.Comment>().map((node) => node.data), ['boundary', '/boundary']);
      expect(output.children, isEmpty);
      expect(output.text!.trim(), isEmpty);
    });

    test('marks a component nested in fragments whose output has multiple children', () async {
      final output = parseFragment(
        await _render(
          .element(
            tag: 'div',
            children: [
              .fragment([
                .text('before'),
                .fragment([
                  _marked(.fragment([.element(tag: 'span', children: []), .text('inside')])),
                ]),
                .text('after'),
              ]),
            ],
          ),
          standalone: true,
        ),
      );
      expect(output.children.single.innerHtml, 'before<!--boundary--><span></span>inside<!--/boundary-->after');
    });

    test('awaits preparation, prepares newly registered adapters, and applies in reverse order', () async {
      final events = <String>[];
      final output = await _render(
        Builder(
          builder: (context) {
            (context.binding as ServerAppBinding)
              ..addRenderAdapter(_PreparingAdapter(events))
              ..addRenderAdapter(_MarkingAdapter(context as Element, events: events));
            return .element(tag: 'p', children: [.text('Some content')]);
          },
        ),
        standalone: true,
      );
      expect(events, [
        'preparing.prepare',
        'preparing.ready',
        'marking.prepare',
        'extra.prepare',
        'extra.apply',
        'marking.apply',
        'preparing.apply',
      ]);
      expect(output, '<!--boundary-->\n<p>Some content</p>\n<!--/boundary-->\n');
    });
  });

  group('document head', () {
    test('flattens fragments and replaces keyed elements of shallower declarations', () async {
      final document = await _renderDocument(
        .element(
          tag: 'main',
          children: [
            Document.head(
              title: 'outer',
              meta: {'description': 'outer'},
              children: [
                .fragment([
                  .element(tag: 'link', id: 'shared', attributes: {'href': '/outer.css'}),
                  .element(tag: 'meta', attributes: {'name': 'unique', 'content': 'retained'}),
                ]),
              ],
            ),
            .element(
              tag: 'section',
              children: [
                Document.head(
                  title: 'inner',
                  meta: {'description': 'inner'},
                  children: [
                    .fragment([
                      .element(tag: 'link', id: 'shared', attributes: {'href': '/inner.css'}),
                      .fragment([_script('first'), _script('second')]),
                    ]),
                  ],
                ),
                .text('visible'),
              ],
            ),
          ],
        ),
      );
      expect(_describeHead(document), [
        'title: inner',
        'meta: description=inner',
        'link: /inner.css',
        'meta: unique=retained',
        'script: /first.js',
        'script: /second.js',
      ]);
      expect(document.body!.text.trim(), 'visible');
    });

    test('adds the elements of nested heads after the enclosing head, like the client', () async {
      final document = await _renderDocument(
        .element(
          tag: 'main',
          children: [
            Document.head(
              children: [
                _script('first'),
                Document.head(children: [_script('nested')]),
                _script('last'),
              ],
            ),
            .text('body'),
          ],
        ),
      );
      expect(_describeHead(document), ['script: /first.js', 'script: /last.js', 'script: /nested.js']);
      expect(document.body!.text.trim(), 'body');
    });
  });

  group('template document', () {
    test('wraps component boundaries in a template and replaces target contents', () async {
      final output = await _renderDocument(
        Document.template(
          attachTo: '#content',
          child: _marked(
            label: 'outer',
            .fragment([
              _marked(label: 'empty', .fragment([])),
              _marked(
                label: 'content',
                .element(tag: 'p', children: [.text('Some content')]),
              ),
            ]),
          ),
        ),
        files: {
          'index.template.html':
              '<!DOCTYPE html><html><head><title>Template title</title></head>'
              '<body><main id="content" data-label="Main content"><p>placeholder</p></main>'
              '<footer>Footer content</footer></body></html>',
        },
      );
      expect(output.nodes.whereType<dom.DocumentType>().single.name, 'html');
      expect(output.head!.children.map((node) => node.outerHtml), ['<title>Template title</title>']);
      expect(output.body!.children.map((node) => node.localName), ['main', 'footer']);
      final target = output.querySelector('main#content')!;
      expect(target.attributes, {'id': 'content', 'data-label': 'Main content'});
      expect(
        target.innerHtml,
        '<!--outer--><!--empty--><!--/empty--><!--content--><p>Some content</p><!--/content--><!--/outer-->',
      );
      expect(output.querySelector('footer')!.outerHtml, '<footer>Footer content</footer>');
    });

    test('reports the name of a missing template', () async {
      await expectLater(
        _render(Document.template(name: 'missing', child: .text('content'))),
        throwsA(isA<TemplateNotFoundError>().having((error) => error.name, 'name', 'missing')),
      );
    });

    test(
      'reports the selector of a missing attach target',
      () async {
        await expectLater(
          _render(
            Document.template(attachTo: '#missing', child: .text('content')),
            files: {'index.template.html': '<html><body></body></html>'},
          ),
          throwsA(
            allOf(
              isNot(isA<TypeError>()),
              predicate<Object>((error) => '$error'.contains('#missing'), 'mentions the selector'),
            ),
          ),
        );
      },
      // TODO: Enable when a missing attach target reports a descriptive error.
      // Currently `TemplateDocumentAdapter` null-asserts the `querySelector` result,
      // so rendering fails with "Null check operator used on a null value".
      skip: true,
    );

    test(
      'preserves significant whitespace in template text',
      () async {
        final output = parse(
          await _render(
            Document.template(attachTo: '#app', child: .text('content')),
            files: {
              'index.template.html':
                  '<html><body><p id="inline">Hello <b>world</b></p>'
                  '<p id="between"><a href="#">one</a> <a href="#">two</a></p>'
                  '<pre>  keep\n  indentation</pre><div id="app"></div></body></html>',
            },
          ),
        );
        expect(output.querySelector('#inline')!.text, 'Hello world');
        expect(output.querySelector('#between')!.text, 'one two');
        expect(output.querySelector('pre')!.text, '  keep\n  indentation');
      },
      // TODO: Enable when template text keeps its significant whitespace.
      // Currently `TemplateDocumentAdapter` trims every text node and drops whitespace-only ones,
      // rendering "Hello<b>world</b>", "<a>one</a><a>two</a>", and "<pre>keep\n  indentation</pre>".
      skip: true,
    );

    test(
      'escapes template text instead of rendering it as markup',
      () async {
        final output = parse(
          await _render(
            Document.template(attachTo: '#app', child: .text('content')),
            files: {
              'index.template.html':
                  '<html><head><script>if (a < b && c) {}</script></head>'
                  '<body><p>a &lt;b&gt; c</p><div id="app"></div></body></html>',
            },
          ),
        );
        final paragraph = output.querySelector('p')!;
        expect(paragraph.text, 'a <b> c');
        expect(paragraph.children, isEmpty);
        // Raw text elements must not be escaped.
        expect(output.querySelector('script')!.text, 'if (a < b && c) {}');
      },
      // TODO: Enable when template text is escaped when rendered.
      // Currently `TemplateDocumentAdapter` renders the parser's decoded text as raw HTML,
      // so "a &lt;b&gt; c" is rendered as "a <b> c" and creates a `b` element.
      skip: true,
    );
  });
}

Future<String> _render(Component component, {bool standalone = false, Map<String, String> files = const {}}) async {
  final binding = ServerAppBinding((
    url: '/',
    basePath: '/',
    headers: .empty(),
  ), loadFile: (name) async => files[name]);
  addTearDown(binding.detachRootComponent);
  binding.initializeOptions(const ServerOptions());
  binding.attachRootComponent(component);
  return utf8.decode(await binding.render(standalone: standalone));
}

/// Renders [component] as a document,
/// rejecting malformed output instead of letting the parser silently repair it.
Future<dom.Document> _renderDocument(Component component, {Map<String, String> files = const {}}) async =>
    HtmlParser(await _render(component, files: files), strict: true).parse();

/// Describes the child nodes of [parent], ignoring whitespace added by formatting.
List<String> _describeNodes(dom.Node parent) => [
  for (final node in parent.nodes)
    if (node is dom.Element)
      '<${node.localName}>'
    else if (node is dom.Comment)
      '<!--${node.data}-->'
    else if (node.text!.trim() case final text when text.isNotEmpty)
      text,
];

Component _script(String name) => .element(tag: 'script', attributes: {'src': '/$name.js'}, children: []);

/// Describes the elements in the head of [document].
List<String> _describeHead(dom.Document document) => [
  for (final element in document.head!.children)
    switch (element.localName) {
      'title' => 'title: ${element.text}',
      'meta' => 'meta: ${element.attributes['name']}=${element.attributes['content']}',
      'link' => 'link: ${element.attributes['href']}',
      'script' => 'script: ${element.attributes['src']}',
      final tag => '$tag',
    },
];

Component _marked(Component child, {String label = 'boundary'}) => Builder(
  builder: (context) {
    (context.binding as ServerAppBinding).addRenderAdapter(_MarkingAdapter(context as Element, label: label));
    return child;
  },
);

/// Marks the start and end of its element's output with comments containing [label].
final class _MarkingAdapter extends ElementBoundaryAdapter {
  _MarkingAdapter(super.element, {this.label = 'boundary', super.priority, this.duringPrepare = false, this.events});

  final String label;

  /// Whether to insert the markers in [prepareBoundary] instead of [applyBoundary].
  final bool duringPrepare;

  final List<String>? events;

  @override
  void prepareBoundary(ChildGroup group) {
    events?.add('marking.prepare');
    if (duringPrepare) _mark(group);
  }

  @override
  void applyBoundary(ChildGroup group) {
    events?.add('marking.apply');
    if (!duringPrepare) _mark(group);
  }

  void _mark(ChildGroup group) {
    group.children.insertAfter(MarkupRenderText('<!--$label-->', true));
    group.children.insertBefore(MarkupRenderText('<!--/$label-->', true));
  }
}

final class _PreparingAdapter extends RenderAdapter {
  _PreparingAdapter(this.events);

  final List<String> events;

  @override
  Future<void> prepare() async {
    events.add('preparing.prepare');
    await Future<void>.value();
    events.add('preparing.ready');
    binding.addRenderAdapter(_ExtraAdapter(events));
  }

  @override
  void apply(MarkupRenderObject root) => events.add('preparing.apply');
}

final class _ExtraAdapter extends RenderAdapter {
  _ExtraAdapter(this.events);

  final List<String> events;

  @override
  void prepare() => events.add('extra.prepare');

  @override
  void apply(MarkupRenderObject root) => events.add('extra.apply');
}
