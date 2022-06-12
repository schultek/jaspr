import 'package:jaspr/jaspr.dart';
import 'package:jaspr_ui/src/core/styles/base.dart';

class StyleElement extends StatelessComponent {
  final Component? child;
  final List<StyleGroup> styles;

  const StyleElement({this.child, required this.styles});

  String getStyles() => styles.map((e) => e.getStyles()).join('\n');

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(tag: 'style', child: Text(getStyles()));
    if (child != null) yield child!;
  }
}

class StyleGroup {
  final Selectors? _selectors;
  final Selector? _selector;
  final List<BaseStyle> styles;

  const StyleGroup({
    Selector? selector,
    Selectors? selectors,
    required this.styles,
  })  : _selector = selector,
        _selectors = selectors;

  Selectors get selectors => _selector != null ? Selectors.one(_selector!) : _selectors ?? Selectors('');

  String getStyles() => '${selectors.selectors} {\n${styles.map((e) => e.getStyle()).join('\n')}\n}';
}

class Selector {
  final String name;

  const Selector(this.name);

  factory Selector.id(String selector) => Selector('#$selector');

  factory Selector.element(String selector) => Selector(selector);

  factory Selector.classHtml(String selector, {String? element}) => Selector('${element ?? ''}.$selector');

  factory Selector.own(String selector) => Selector('#$selector');
}

class Selectors {
  final String selectors;

  const Selectors(this.selectors);

  factory Selectors.all() => Selectors('*');

  factory Selectors.one(Selector selector) => Selectors(selector.name);

  factory Selectors.descendant(List<Selector> selectors) => Selectors(selectors.map((e) => e.name).join(' '));

  factory Selectors.child(List<Selector> selectors) => Selectors(selectors.map((e) => e.name).join(' > '));

  factory Selectors.sibling(List<Selector> selectors) => Selectors(selectors.map((e) => e.name).join(' + '));

  factory Selectors.generalSibling(List<Selector> selectors) => Selectors(selectors.map((e) => e.name).join(' ~ '));

  factory Selectors.group(List<Selector> selectors) => Selectors(selectors.map((e) => e.name).join(', '));
}
