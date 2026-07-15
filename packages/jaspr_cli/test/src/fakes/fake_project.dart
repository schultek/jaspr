import 'dart:convert';
import 'dart:io';

import 'package:jaspr_cli/src/version.dart';
import 'package:mocktail/mocktail.dart';

import 'fake_io.dart';

extension FakeProject on FakeIO {
  void setupFakeProject(String name, {String mode = 'client', bool flutterEmbedding = false}) {
    fs.directory('/root/myapp').createSync();
    fs.file('/root/$name/pubspec.yaml')
      ..createSync()
      ..writeAsStringSync(fakePubspec(name, mode, flutterEmbedding));
    fs.directory('/root/$name/lib').createSync();
    fs.file('/root/$name/lib/main.client.dart')
      ..createSync()
      ..writeAsStringSync(fakeMainClientDart());
    if (mode != 'client') {
      fs.file('/root/$name/lib/main.server.dart')
        ..createSync()
        ..writeAsStringSync(fakeMainServerDart());
    }
    fs.currentDirectory = '/root/$name';
  }

  void stubDartSDK() {
    when(() => process.runSync('which', ['dart'])).thenAnswer((_) => ProcessResult(0, 0, '/fake/bin/dart', null));
    when(
      () => process.runSync('where', ['dart.bat', 'dart.exe']),
    ).thenAnswer((_) => ProcessResult(0, 0, '/fake/bin/dart', null));

    fs.file('/fake/version').createSync(recursive: true);
  }

  void stubFlutterSDK() {
    when(
      () => process.runSync('flutter', ['doctor', '--version', '--machine'], runInShell: true, stdoutEncoding: utf8),
    ).thenAnswer((_) => ProcessResult(0, 0, '{"flutterRoot":"/fake/flutter","flutterVersion":"3.35.0"}', null));
    when(
      () => process.runSync('flutter', ['precache', '--web'], runInShell: true),
    ).thenAnswer((_) => ProcessResult(0, 0, null, null));
    fs.directory('/fake/flutter/bin/cache/flutter_web_sdk').createSync(recursive: true);
  }
}

String fakePubspec(String name, String mode, bool flutterEmbedding) =>
    '''
name: $name

dependencies:
  jaspr: ^$jasprCoreVersion

dev_dependencies:
  build_web_compilers: ^4.4.6
  jaspr_builder: ^$jasprBuilderVersion

jaspr:
  mode: $mode
  ${flutterEmbedding ? 'flutter: embedded' : ''}
''';

String fakeMainClientDart() => '''
import 'package:jaspr/client.dart';
import 'package:jaspr/dom.dart';

void main() {
  runApp(div([]));
}
''';

String fakeMainServerDart() => '''
import 'package:jaspr/server.dart';
import 'package:jaspr/dom.dart';

void main() {
  runApp(Document(body: div([])));
}
''';
