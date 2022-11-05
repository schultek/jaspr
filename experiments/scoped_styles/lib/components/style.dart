import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart';
import 'package:jaspr/jaspr.dart';
import 'package:uuid/uuid.dart';

class Style extends StatefulComponent {
  Style({required this.child, this.scoped = false, required this.style});

  final Component child;
  final bool scoped;
  final String style;

  @override
  State<StatefulComponent> createState() => StyleState();
}

class StyleState extends State<Style> {
  late final String id;
  late final String style;

  @override
  void initState() {
    super.initState();
    id = Uuid().v4();
    style = _generateScopedStyle();
  }

  @override
  void didUpdateComponent(covariant Style oldComponent) {
    super.didUpdateComponent(oldComponent);
    style = _generateScopedStyle();
  }

  String _generateScopedStyle() {
    if (!component.scoped) return component.style;

    var printer = CssPrinter();

    css.parse(component.style)
      ..visit(_ScopedVisitor('data-j-$id'))
      ..visit(printer);

    return printer.toString();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'style', child: Text(style));
    if (component.scoped) {
      yield RenderScope(
        delegate: _ScopedDelegate(id),
        shallow: false,
        child: component.child,
      );
    } else {
      yield component.child;
    }
  }
}

class _ScopedVisitor extends Visitor {
  String attr;

  _ScopedVisitor(this.attr);

  @override
  void visitSelector(Selector node) {
    var sequences = node.simpleSelectorSequences;
    var i = 0;

    for (; i < sequences.length; i++) {
      if (!sequences[i].isCombinatorNone) {
        assert(i != 0);
        break;
      }
    }

    var dataSelector = AttributeSelector(Identifier(attr, node.span), css.TokenKind.NO_MATCH, null, node.span);
    node.simpleSelectorSequences.insert(i, SimpleSelectorSequence(dataSelector, node.span));
  }
}

class _ScopedDelegate extends RenderDelegate {
  _ScopedDelegate(this.id);

  final String id;
  @override
  void renderNode(RenderElement node, String tag, String? id, List<String>? classes, Map<String, String>? styles,
      Map<String, String>? attributes, Map<String, EventCallback>? events) {
    super.renderNode(node, tag, id, classes, styles, {'data-j-${id}': '', ...attributes ?? {}}, events);
  }
}
