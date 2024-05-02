import '../../jaspr.dart';
import 'head/head_client.dart' if (dart.library.io) 'head/head_server.dart';

class Head extends StatelessComponent {
  const Head({this.title, this.meta, this.children, super.key});

  final String? title;
  final Map<String, String>? meta;
  final List<Component>? children;

  @override
  Iterable<Component> build(BuildContext context) sync* {
    yield PlatformHead(key: key, children: [
      if (title != null) DomComponent(tag: 'title', child: Text(title!)),
      if (meta != null)
        for (var e in meta!.entries) DomComponent(tag: 'meta', attributes: {'name': e.key, 'content': e.value}),
      ...?children,
    ]);
  }
}
