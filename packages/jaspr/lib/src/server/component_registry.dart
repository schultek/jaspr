import '../foundation/constants.dart';
import '../foundation/sync.dart';
import '../framework/framework.dart';

class ComponentEntry<T extends Component> {
  final String name;
  final ComponentEntryType type;
  final Map<String, dynamic> Function(T component)? getParams;

  ComponentEntry.app(this.name, {this.getParams}): type = ComponentEntryType.app;
  ComponentEntry.island(this.name, {this.getParams}): type = ComponentEntryType.island;
  ComponentEntry.appAndIsland(this.name, {this.getParams}): type = ComponentEntryType.appAndIsland;

  bool get isApp => type == ComponentEntryType.app || type == ComponentEntryType.appAndIsland;
  bool get isIsland => type == ComponentEntryType.island || type == ComponentEntryType.appAndIsland;

  Map<String, dynamic> loadParams(Component component) {
    if (getParams != null) {
      var params = getParams!(component as T);
      return {'params': kDebugMode ? params : stateCodec.encode(params)};
    } else {
      return {};
    }
  }
}

enum ComponentEntryType {

  app(true, false),
  island(false, true),
  appAndIsland(true, true);

  final bool isApp;
  final bool isIsland;

  const ComponentEntryType(this.isApp, this.isIsland);
}

class ComponentRegistryData {
  final String target;
  final Map<Type, ComponentEntry> components;

  ComponentRegistryData(this.target, this.components);
}

class ComponentRegistry {
  static ComponentRegistryData? _data;
  static ComponentRegistryData? get data => _data;

  static void initialize(String target, {required Map<Type, ComponentEntry> components}) {
    _data = ComponentRegistryData(target, components);
  }
}