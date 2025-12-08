/// Used to annotate a client component.
const client = ClientAnnotation._();

/// Use with [client] to annotate a client component.
final class ClientAnnotation {
  const ClientAnnotation._();
}

/// Used to annotate an encoder function for a custom model.
const encoder = EncoderAnnotation._();

/// Use with [encoder] to annotate an encoder function for a custom model.
final class EncoderAnnotation {
  const EncoderAnnotation._();
}

/// Used to annotate an decoder function for a custom model.
const decoder = DecoderAnnotation._();

/// Use with [decoder] to annotate an decoder function for a custom model.
final class DecoderAnnotation {
  const DecoderAnnotation._();
}

/// Define a platform specific import with auto-generated stubbing.
///
/// You can use the [Import.onWeb] or [Import.onServer] variants for
/// web and server specific imports, respectively.
///
/// The following example is equivalent to `import 'dart:html' show window`,
/// but does not lead to a compilation error on the server:
///
/// ```dart
/// @Import.onWeb('dart:html', show: [#window])
/// import 'file.imports.dart';
/// ```
///
/// 1. Put the actual import in the annotation.
/// 3. Define what elements or types to 'show' as symbols (prefixed by #).
///   - This is required to reduce the amount of stubbing needed.
/// 2. Import the file '&lt;current filename&gt;.imports.dart'.
///
/// The associated file will be generated the next time you run `jaspr serve`.
///
/// Make sure to use the imported elements and types only after
/// the appropriate platform check using `kIsWeb`. For example:
///
/// ```dart
/// if (kIsWeb) {
///   print(window.name);
/// }
/// ```
///
/// Accessing your imported elements on the wrong platform will result in runtime exceptions.
final class Import {
  const Import.onWeb(this.import, {required this.show}) : platform = ImportPlatform.web;
  const Import.onServer(this.import, {required this.show}) : platform = ImportPlatform.server;

  final ImportPlatform platform;
  final String import;
  final List<dynamic> show;
}

enum ImportPlatform { web, server }
