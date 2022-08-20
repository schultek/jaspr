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

  @override
  Element createElement() => StyleElement(this);
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
    yield component.child;
  }
}

class StyleElement extends StatefulElement {
  StyleElement(Style component) : super(component);

  @override
  void render(Renderer b) {
    if ((component as Style).scoped) {
      super.render(ScopedDomBuilder(b, state as StyleState));
    } else {
      super.render(b);
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

class ScopedDomBuilder extends Renderer {
  ScopedDomBuilder(this.builder, this.state);

  final Renderer builder;
  final StyleState state;

  @override
  void open(String tag,
      {String? key,
      String? id,
      Iterable<String>? classes,
      Map<String, String>? styles,
      Map<String, String>? attributes,
      Map<String, DomEventFn>? events,
      DomLifecycleEventFn? onCreate,
      DomLifecycleEventFn? onUpdate,
      DomLifecycleEventFn? onRemove}) {
    builder.open(tag,
        key: key,
        id: id,
        classes: classes,
        styles: styles,
        attributes: {'data-j-${state.id}': '', ...attributes ?? {}},
        events: events,
        onCreate: onCreate,
        onUpdate: onUpdate,
        onRemove: onRemove);
  }

  @override
  void close({String? tag}) => builder.close(tag: tag);

  @override
  void innerHtml(String value) => builder.innerHtml(value);

  @override
  void skipNode() => builder.skipNode();

  @override
  void skipRemainingNodes() => builder.skipRemainingNodes();

  @override
  void text(String value) => builder.text(value);
}
