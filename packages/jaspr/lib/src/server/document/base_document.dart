part of 'document.dart';

class _BaseDocument extends Document {
  const _BaseDocument({
    this.title,
    this.lang,
    this.base,
    this.charset = 'utf-8',
    this.viewport = 'width=device-width, initial-scale=1.0',
    this.meta,
    this.styles,
    this.head = const [],
    required this.body,
  }) : super._();

  final String? title;
  final String? lang;
  final String? base;
  final String? charset;
  final String? viewport;
  final Map<String, String>? meta;
  final List<StyleRule>? styles;
  final List<Component> head;
  final Component body;

  String? get _normalizedBase {
    var base = this.base;
    if (base == null) return null;
    if (!base.startsWith('/')) base = '/$base';
    if (!base.endsWith('/')) base = '$base/';
    return base;
  }

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield DomComponent(
      tag: 'html',
      attributes: {
        if (lang != null) 'lang': lang!,
      },
      children: [
        DomComponent(
          tag: 'head',
          children: [
            if (charset != null) DomComponent(tag: 'meta', attributes: {'charset': charset!}),
            if (base != null) //
              DomComponent(tag: 'base', attributes: {'href': _normalizedBase!}),
            if (viewport != null) DomComponent(tag: 'meta', attributes: {'name': 'viewport', 'content': viewport!}),
            if (meta != null)
              for (var e in meta!.entries) DomComponent(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
            if (title != null) //
              DomComponent(tag: 'title', child: Text(title!)),
            if (styles != null) //
              Style(styles: styles!),
            ...head,
          ],
        ),
        DomComponent(tag: 'body', child: body),
      ],
    );
  }
}
