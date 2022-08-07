import '../../jaspr.dart';
import '../../styles.dart';

class Document extends StatefulComponent {
  const Document({
    this.title,
    this.base,
    this.viewport = 'width=device-width, initial-scale=1.0',
    this.meta,
    this.styles,
    this.scriptName = 'main',
    required this.body,
    super.key,
  });

  final String? title;
  final String? base;
  final String? viewport;
  final Map<String, String>? meta;
  final List<StyleRule>? styles;
  final String? scriptName;
  final Component body;

  @override
  State<Document> createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  // only allow a single document
  static const _documentKey = GlobalKey();

  String? get _normalizedBase {
    var base = component.base;
    if (base == null) return null;
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';
    return base;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      key: _documentKey,
      tag: 'html',
      children: [
        DomComponent(
          tag: 'head',
          children: [
            DomComponent(tag: 'meta', attributes: {'charset': 'utf-8'}),
            if (component.base != null) //
              DomComponent(tag: 'base', attributes: {'href': _normalizedBase!}),
            if (component.viewport != null)
              DomComponent(tag: 'meta', attributes: {'name': 'viewport', 'content': component.viewport!}),
            if (component.meta != null)
              for (var e in component.meta!.entries)
                DomComponent(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
            if (component.title != null) //
              DomComponent(tag: 'title', child: Text(component.title!)),
            if (component.styles != null) //
              Style(styles: component.styles!),
            if (component.scriptName != null)
              DomComponent(tag: 'script', attributes: {'defer': '', 'src': '${component.scriptName}.dart.js'}),
          ],
        ),
        DomComponent(
          tag: 'body',
          child: component.body,
        ),
      ],
    );
  }
}
