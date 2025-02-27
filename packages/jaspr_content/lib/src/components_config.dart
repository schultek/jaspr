import 'package:jaspr/jaspr.dart';

abstract class ComponentsConfig {
  factory ComponentsConfig({required Map<String, ComponentsConfigCallback> components}) = BaseComponentsConfig;

  Component? buildComponent(String tag, Map<String, String> attributes, Component child);
}

typedef ComponentsConfigCallback = Component Function(Map<String, String> attributes, Component child);

class BaseComponentsConfig implements ComponentsConfig {
  BaseComponentsConfig({required this.components});

  final Map<String, ComponentsConfigCallback> components;

  @override
  Component? buildComponent(String tag, Map<String, String> attributes, Component child) {
    var builder = components[tag];
    if (builder != null) {
      return builder(attributes, child);
    }
    return null;
  }
}
