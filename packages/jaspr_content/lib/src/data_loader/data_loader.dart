/// @docImport 'filesystem_data_loader.dart';
/// @docImport 'memory_data_loader.dart';
library;


import 'dart:convert';
import 'package:yaml/yaml.dart' as yaml;

import '../page.dart';

/// A data loader that loads additional data for a page.
/// 
/// See also:
/// - [FilesystemDataLoader]
/// - [MemoryDataLoader]
abstract class DataLoader {
  /// Loads the data for the given [page].
  /// 
  /// The page's data is modified in place.
  Future<void> loadData(Page page);

  /// Parses the raw data from a source with the given [name].
  /// 
  /// Currently supports parsing .json and .yaml data. All other data is returned as is.
  static Object? parseData(String name, String data) {
    if (name.endsWith('.json')) {
      return jsonDecode(data);
    } else if (name.endsWith('.yaml')) {
      return yaml.loadYamlNode(data).normalize();
    } else {
      return data;
    }
  }
}

extension on yaml.YamlNode {
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
