import '../framework/framework.dart';
import 'constants.dart';
import 'sync.dart';

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


abstract class ComponentEntryMixin<T extends Component> {
  ComponentEntry<T> get entry;
}

class ComponentEntry<T extends Component> {
  final String name;
  final ComponentEntryType type;
  final Map<String, dynamic>? params;

  ComponentEntry.app(this.name, {this.params}): type = ComponentEntryType.app;
  ComponentEntry.island(this.name, {this.params}): type = ComponentEntryType.island;
  ComponentEntry.appAndIsland(this.name, {this.params}): type = ComponentEntryType.appAndIsland;

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