import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:build/build.dart';
import 'package:build_runner/src/internal.dart';
import 'package:build_test/build_test.dart';
import 'package:build_test/src/internal_test_reader_writer.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:jaspr_builder/src/styles/styles_standalone_module_builder.dart';
import 'package:jaspr_builder/src/styles/styles_standalone_output_builder.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

import 'sources/bundle.dart';
import 'sources/styles_class.dart';
import 'sources/styles_global.dart';
import 'sources/styles_standalone.dart';

void main() {
  group('standalone styles', () {
    late InternalTestReaderWriter reader;
    late Directory tempDir;

    String createPubspec() {
      final jasprPath = path.normalize(path.join(Directory.current.path, '..', 'jaspr'));
      return '''
          name: site
          environment:
            sdk: ">=3.8.0 <4.0.0"
          dependencies:
            jaspr:
              path: $jasprPath
        ''';
    }

    Future<void> preparePackage(Map<String, String> sources) async {
      for (final entry in sources.entries) {
        final id = AssetId.parse(entry.key);
        final file = File(path.join(tempDir.path, id.path));
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(entry.value);
      }

      File(path.join(tempDir.path, 'pubspec.yaml')).writeAsStringSync(createPubspec());

      final result = Process.runSync('dart', ['pub', 'get'], workingDirectory: tempDir.path);
      if (result.exitCode != 0) {
        throw Exception('dart pub get failed: ${result.stderr}');
      }
    }

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('jaspr_styles_test_');

      reader = InternalTestReaderWriter.using(
        assetsRead: {},
        assetsWritten: {},
        assetFinder: ScopedAssetFinder('site', tempDir),
        assetPathProvider: ScopedAssetPathProvider('site', tempDir),
        buildCachePackage: 'site',
        generatedAssetHider: const NoopGeneratedAssetHider(),
        filesystem: IoInMemoryFilesystem(tempDir, 'site'),
        cache: const PassthroughFilesystemCache(),
        onDelete: null,
        onCanReadController: StreamController(),
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('generates css file for server entrypoint', () async {
      final sources = {
        ...stylesClassSources,
        ...stylesGlobalSources,
        ...stylesBundleOutputs,
        ...stylesStandaloneServerSources,
      };
      await preparePackage(sources);

      final moduleBuilder = StylesStandaloneModuleBuilder(BuilderOptions({}));

      await testBuilders(
        [moduleBuilder],
        sources,
        postProcessBuilders: [
          StylesStandaloneOutputBuilder(BuilderOptions({'working_directory': tempDir.path})),
        ],
        appliesBuilders: {
          moduleBuilder: ['StylesStandaloneOutputBuilder'],
        },
        outputs: stylesStandaloneServerOutputs,
        readerWriter: reader,
      );
    });

    test('generates css file for client entrypoint', () async {
      final sources = {
        ...stylesClassSources,
        ...stylesGlobalSources,
        ...stylesBundleOutputs,
        ...stylesStandaloneClientSources,
      };
      await preparePackage(sources);

      final moduleBuilder = StylesStandaloneModuleBuilder(BuilderOptions({}));

      await testBuilders(
        [moduleBuilder],
        sources,
        postProcessBuilders: [
          StylesStandaloneOutputBuilder(BuilderOptions({'working_directory': tempDir.path})),
        ],
        appliesBuilders: {
          moduleBuilder: ['StylesStandaloneOutputBuilder'],
        },
        outputs: stylesStandaloneClientOutputs,
        readerWriter: reader,
      );
    });
  });
}

class ScopedAssetPathProvider implements AssetPathProvider {
  final String rootPackage;
  final Directory tempDir;
  ScopedAssetPathProvider(this.rootPackage, this.tempDir);

  @override
  String pathFor(AssetId id, {required bool hide, bool checkDeleteAllowed = false}) {
    return path.join(tempDir.path, id.path);
  }
}

class ScopedAssetFinder implements AssetFinder {
  final String rootPackage;
  final Directory tempDir;
  ScopedAssetFinder(this.rootPackage, this.tempDir);

  @override
  Stream<AssetId> find(Glob glob, {required String package}) {
    if (package != rootPackage) return Stream.empty();
    return glob
        .list(root: tempDir.path)
        .where((e) => e is File)
        .cast<File>()
        .map((e) => AssetId(package, path.relative(e.path, from: tempDir.path)));
  }
}

class IoInMemoryFilesystem extends InMemoryFilesystem {
  final Directory tempDir;
  final String rootPackage;
  IoInMemoryFilesystem(this.tempDir, this.rootPackage);

  @override
  bool existsSync(String path) => File(path).existsSync();

  @override
  Uint8List readAsBytesSync(String path) => File(path).readAsBytesSync();

  @override
  String readAsStringSync(String path, {Encoding encoding = utf8}) => File(path).readAsStringSync(encoding: encoding);

  @override
  void deleteSync(String path) {
    final file = File(path);
    if (file.existsSync()) file.deleteSync();
  }

  @override
  void deleteDirectorySync(String path) {
    final directory = Directory(path);
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  }

  @override
  void writeAsBytesSync(String path, List<int> contents) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(contents);
  }

  @override
  void writeAsStringSync(String path, String contents, {Encoding encoding = utf8}) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents, encoding: encoding);
  }

  @override
  Iterable<String> get filePaths {
    return tempDir
        .listSync(recursive: true)
        .whereType<File>()
        .map((f) => '$rootPackage|${path.relative(f.path, from: tempDir.path)}');
  }
}
