import 'dart:io';

import 'package:jaspr_cli/src/helpers/settings_helper.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test('migrates legacy .jaspr directory to data home', () {
    final tempDir = Directory.systemTemp.createTempSync('jaspr_settings_test_');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final homeDir = Directory(p.join(tempDir.path, 'home'))..createSync();
    final dataHomeDir = Directory(p.join(tempDir.path, 'data_home'))..createSync();

    // Create legacy directory with some files
    final legacyDir = Directory(p.join(homeDir.path, '.jaspr'))..createSync();
    File(p.join(legacyDir.path, 'jaspr.json')).writeAsStringSync('{"analytics": false}');
    Directory(p.join(legacyDir.path, 'some_dir')).createSync();
    File(p.join(legacyDir.path, 'some_dir', 'file.txt')).writeAsStringSync('hello');

    final settingsDir = getSettingsDirectory(
      environment: {
        'HOME': homeDir.path,
        'APPDATA': homeDir.path,
        'DART_DATA_HOME': dataHomeDir.path,
      },
    );

    expect(
      settingsDir!.path,
      equals(p.join(dataHomeDir.path, 'jaspr/')),
    );

    // New data home directory should exist
    final jasprDataDir = Directory(p.join(dataHomeDir.path, 'jaspr'));
    expect(jasprDataDir.existsSync(), isTrue);

    // Legacy dir should be deleted
    expect(legacyDir.existsSync(), isFalse);

    // Files should be moved
    final jasprJson = File(p.join(jasprDataDir.path, 'jaspr.json'));
    expect(jasprJson.existsSync(), isTrue);
    expect(jasprJson.readAsStringSync(), '{"analytics": false}');

    final fileTxt = File(p.join(jasprDataDir.path, 'some_dir', 'file.txt'));
    expect(fileTxt.existsSync(), isTrue);
    expect(fileTxt.readAsStringSync(), 'hello');
  });
}
