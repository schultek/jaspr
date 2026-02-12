/// @docImport 'filesystem_data_loader.dart';
/// @docImport 'memory_data_loader.dart';
library;

import 'dart:convert';
import 'package:yaml/yaml.dart' as yaml;

import '../page.dart';
import '../utils.dart';

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

  static bool canParse(String name) {
    return name.endsWith('.json') || name.endsWith('.yaml') || name.endsWith('.yml');
  }

  /// Parses the raw data from a source with the given [name].
  ///
  /// Currently supports parsing .json and .yaml data. All other data is returned as is.
  static Object? parseData(String name, String data) {
    if (name.endsWith('.json')) {
      return jsonDecode(data);
    } else if (name.endsWith('.yaml') || name.endsWith('.yml')) {
      return yaml.loadYamlNode(data).normalize();
    } else {
      return data;
    }
  }
}
