import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:glob/glob.dart';

final Map<String, Map<AssetId, List<int>>> _cachedPackageSources = {};

/// Creates and initializes a fresh [TestReaderWriter] preloaded with the given [packages]
/// (defaulting to `['jaspr']`).
///
/// Sources are loaded from the isolate once and cached in-memory across calls,
/// allowing fresh [TestReaderWriter] instances to be created in `<1ms` without
/// redundant disk I/O.
Future<TestReaderWriter> createTestReaderWriter({
  String rootPackage = 'site',
  List<String> packages = const ['jaspr'],
}) async {
  final reader = TestReaderWriter(rootPackage: rootPackage);
  for (final package in packages) {
    var packageFiles = _cachedPackageSources[package];
    if (packageFiles == null) {
      packageFiles = <AssetId, List<int>>{};
      final assetReader = await PackageAssetReader.currentIsolate();
      await for (final id in assetReader.findAssets(Glob('**'), package: package)) {
        packageFiles[id] = await assetReader.readAsBytes(id);
      }
      _cachedPackageSources[package] = packageFiles;
    }
    for (final entry in packageFiles.entries) {
      reader.testing.writeBytes(entry.key, entry.value);
    }
  }
  return reader;
}
