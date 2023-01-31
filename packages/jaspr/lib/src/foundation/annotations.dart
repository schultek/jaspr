import '../framework/framework.dart';

class AppAnnotation {
  const AppAnnotation._();
}

/// Used to annotate an app component
const app = AppAnnotation._();

class IslandAnnotation {
  const IslandAnnotation._();
}

/// Used to annotate an island component
const island = IslandAnnotation._();

enum ImportPlatform { web, server }

/// Define a platform specific import with auto-generated stubbing.
///
/// You can use the [Import.onWeb] or [Import.onServer] variants for
/// web and server specific imports, respectively.
///
/// The following example is equivalent to `import 'dart:html' show window`,
/// but does not lead to a compilation error on the server:
///
/// ```
/// @Import.onWeb('dart:html', show: [#window])
/// import 'file.import.dart';
/// ```
///
/// 1. Put the actual import in the annotation.
/// 3. Define what elements or types to 'show' as symbols (prefixed by #).
///   - This is required to reduce the amount of stubbing needed.
/// 2. Import the file '<current filename>.import.dart'.
///
/// The associated file will be generated the next time you run `jaspr serve`.
///
/// Make sure to use the imported elements and types only after the appropriate platform check
/// using `kIsWeb`, e.g.:
/// ```
/// if (kIsWeb) {
///   print(window.name);
/// }
/// ```
///
/// Accessing your imported elements on the wrong platform will result in runtime exceptions.
class Import {
  const Import.onWeb(this.import, {required this.show}) : platform = ImportPlatform.web;
  const Import.onServer(this.import, {required this.show}) : platform = ImportPlatform.server;

  final ImportPlatform platform;
  final String import;
  final List<dynamic> show;
}

abstract class ComponentEntryMixin<T extends Component> {
  ComponentEntry<T> get entry;
}

class ComponentEntry<T extends Component> {
  final String name;
  final ComponentEntryType type;
  final Map<String, dynamic>? params;

  ComponentEntry.app(this.name, {this.params}) : type = ComponentEntryType.app;
  ComponentEntry.island(this.name, {this.params}) : type = ComponentEntryType.island;
  ComponentEntry.appAndIsland(this.name, {this.params}) : type = ComponentEntryType.appAndIsland;

  bool get isApp => type == ComponentEntryType.app || type == ComponentEntryType.appAndIsland;
  bool get isIsland => type == ComponentEntryType.island || type == ComponentEntryType.appAndIsland;
}

enum ComponentEntryType {
  app(true, false),
  island(false, true),
  appAndIsland(true, true);

  final bool isApp;
  final bool isIsland;

  const ComponentEntryType(this.isApp, this.isIsland);
}
