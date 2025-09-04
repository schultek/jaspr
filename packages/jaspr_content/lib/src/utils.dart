import 'package:watcher/watcher.dart';
import 'package:yaml/yaml.dart' as yaml;

extension YamlMapNormalize on yaml.YamlMap {
  Map<String, Object?> normalize() => {
        for (final entry in nodes.entries) entry.key.toString(): entry.value.normalize(),
      };
}

extension YamlListNormalize on yaml.YamlList {
  List<Object?> normalize() => [
        for (final node in nodes) node.normalize(),
      ];
}

extension YamlNodeNormalize on yaml.YamlNode {
  Object? normalize() => switch (this) {
        final yaml.YamlMap map => map.normalize(),
        final yaml.YamlList list => list.normalize(),
        final yaml.YamlScalar scalar => scalar.value,
        final value => value,
      };
}

typedef DirectoryWatcherFactory = DirectoryWatcher Function(String path);
