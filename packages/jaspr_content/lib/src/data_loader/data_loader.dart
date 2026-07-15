/// @docImport 'filesystem_data_loader.dart';
/// @docImport 'memory_data_loader.dart';
library;

import 'dart:convert';
import 'package:path/path.dart' as path;
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

  /// Whether a file with the specified [name] can be parsed by [DataLoader.parseData].
  ///
  /// Files with other extensions are not recognized as data sources
  /// and will be skipped by the default [FilesystemDataLoader] implementation.
  static bool canParse(String name) {
    return const {'.json', '.yaml', '.yml'}.contains(path.extension(name));
  }

  /// Parses the raw data from a source with the given [name].
  ///
  /// Currently supports parsing .json and .yaml data. All other data is returned as is.
  static Object? parseData(String name, String data) {
    return switch (path.extension(name)) {
      '.json' => jsonDecode(data),
      '.yaml' || '.yml' => yaml.loadYamlNode(data).normalize(),
      _ => data,
    };
  }
}
