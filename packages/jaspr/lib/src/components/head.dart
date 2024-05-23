import '../../jaspr.dart';
import 'head/head_client.dart' if (dart.library.io) 'head/head_server.dart';

/// A component that renders metadata and other elements inside the <head> of the document.
///
/// Any children are pulled out of the normal rendering tree of the application and rendered instead
/// inside a special section of the <head> element of the document. This is supported both on the
/// server during ssr and on the client.
///
/// The [Head] component can be used multiple times in an application where deeper or latter mounted
/// components will override duplicate elements from other [Head] components.
///
/// ```dart
/// Parent(children: [
///   Head(
///     title: "My Title",
///     meta: {"description": "My Page Description"}
///   ),
///   Child(children: [
///     Head(
///       title: "Nested Title"
///     ),
///   ]),
/// ]),
/// ```
///
/// The above configuration of components will result in these elements inside head:
///
/// ```html
/// <head>
///   <title>Nested Title</title>
///   <meta name="description" content="My Page Description">
/// </head>
/// ```
///
/// Note that 'deeper or latter' here does not result in a true DFS ordering. Components that are mounted
/// deeper but prior will override latter but shallower components.
///
/// Elements inside [Head] are overriden using the following system:
/// - elements with an `id` override other elements with the same `id`
/// - <title> and <base> elements override other <title> or <base> elements respectively
/// - <meta> elements override other <meta> elements with the same `name`
///
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
