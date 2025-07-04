import 'package:yaml/yaml.dart' as yaml;

extension YamlNormalize on yaml.YamlNode {
  Object normalize() {
    if (this case yaml.YamlMap(:final nodes)) {
      return {
        for (final entry in nodes.entries) entry.key.toString(): entry.value.normalize(),
      };
    } else if (this case yaml.YamlList(:final nodes)) {
      return [
        for (final node in nodes) node.normalize(),
      ];
    } else {
      return value;
    }
  }
}
