import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

import '../page.dart';
import '../page_parser/page_parser.dart';
import 'page_extension.dart';

/// An extension that generates anchor links for headers in the page.
///
/// The resulting anchor links are appended to the headers as a clickable '#' symbol.
class HeadingAnchorsExtension implements PageExtension {
  HeadingAnchorsExtension({this.maxHeaderDepth = 3});

  /// The maximum header depth to generate anchors for.
  final int maxHeaderDepth;

  static final _headerRegex = RegExp(r'^h(\d)$', caseSensitive: false);

  @override
  Future<List<Node>> apply(Page page, List<Node> nodes) async {
    return [
      ComponentNode(Document.head(children: [Style(styles: _styles)])),
      for (final node in nodes) _processNode(node),
    ];
  }

  Node _processNode(Node node) {
    if (node is! ElementNode) return node;

    final depth = _headerRegex.firstMatch(node.tag)?.group(1);
    if (depth == null) return _processChildren(node);

    final level = int.parse(depth);
    if (level < 1 || level > maxHeaderDepth) return node;

    final id = node.attributes['id'];
    // Header can't be linked to without an id.
    if (id == null) return node;

    // Don't include if no_anchor is specified as a class on the header.
    if (node.attributes['class']?.contains('no_anchors') ?? false) return node;

    final children = node.children;

    return ElementNode(
      node.tag,
      {...node.attributes, 'anchor': 'true'},
      [
        ElementNode('span', {}, children),
        ComponentNode(
          Builder(
            builder: (context) {
              final route = RouteState.of(context);
              return a(href: '${route.path}#$id', [Component.text('#')]);
            },
          ),
        ),
      ],
    );
  }

  Node _processChildren(Node node) {
    if (node is ElementNode) {
      return ElementNode(node.tag, node.attributes, node.children?.map(_processNode).toList());
    }
    return node;
  }

  List<StyleRule> get _styles => [
    css(':is(h1, h2, h3, h4, h5, h6)[anchor="true"]', [
      css('&').styles(
        display: Display.flex,
        alignItems: AlignItems.baseline,
        gap: Gap.column(0.5.rem),
      ),
      css('> a').styles(
        textDecoration: TextDecoration.none,
        opacity: 0,
        fontSize: 0.8.em,
        transition: Transition('opacity', duration: 300.ms),
      ),
      css('&:hover > a').styles(opacity: 0.8),
      css('& > a:hover').styles(opacity: 1),
    ]),
  ];
}
