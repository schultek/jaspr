import 'package:csslib/parser.dart' as css;
import 'package:csslib/visitor.dart';
import 'package:jaspr/jaspr.dart';

class PageStyle extends StatefulComponent {
  PageStyle({required this.child, required this.style});

  final Component child;
  final String style;

  @override
  State<StatefulComponent> createState() => PageStyleState();
}

class PageStyleState extends State<PageStyle> {
  late final String id;
  late final String style;

  @override
  void initState() {
    super.initState();
    style = _generateScopedStyle();
  }

  @override
  void didUpdateComponent(covariant PageStyle oldComponent) {
    super.didUpdateComponent(oldComponent);
    style = _generateScopedStyle();
  }

  String _generateScopedStyle() {
    var printer = CssPrinter();
    css.parse(component.style).visit(printer);
    return printer.toString();
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'style', child: Text(style));
    yield component.child;
  }
}