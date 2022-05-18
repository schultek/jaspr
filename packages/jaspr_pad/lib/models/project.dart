import 'package:dart_mappable/dart_mappable.dart';

import '../main.mapper.g.dart';
import 'gist.dart';

@MappableClass(discriminatorKey: 'type')
class ProjectData {
  final String? id;
  final String? description;

  final String? htmlFile;
  final String? cssFile;
  final String mainDartFile;
  final Map<String, String> dartFiles;

  ProjectData({
    this.id,
    this.description,
    this.htmlFile,
    this.cssFile,
    required this.mainDartFile,
    this.dartFiles = const {},
  });

  factory ProjectData.fromGist(GistData gist) {
    var htmlFile = gist.files['index.html'];
    if (htmlFile != null && htmlFile.type != 'text/html') {
      print('[WARNING] index.html has wrong type "${htmlFile.type}"');
      htmlFile = null;
    }

    var cssFile = gist.files['styles.css'];
    if (cssFile != null && cssFile.type != 'text/css') {
      print('[WARNING] styles.css has wrong type "${cssFile.type}"');
      cssFile = null;
    }

    var dartFile = gist.files['main.dart'];
    if (dartFile == null) throw 'Missing main.dart file';
    if (dartFile.type != 'application/vnd.dart') throw 'main.dart has wrong type "${dartFile.type}"';

    var dartFiles = Map.fromEntries(gist.files.entries
        .where((e) => e.value.type == 'application/vnd.dart' && e.key != 'main.dart')
        .map((e) => MapEntry(e.key, e.value.content)));

    return ProjectData(
      id: gist.id,
      description: gist.description,
      htmlFile: htmlFile?.content,
      cssFile: cssFile?.content,
      mainDartFile: dartFile.content,
      dartFiles: dartFiles,
    );
  }

  List<String> get fileNames =>
      ['main.dart', ...dartFiles.keys, if (htmlFile != null) 'index.html', if (cssFile != null) 'styles.css'];

  Map<String, String> get allDartFiles => {'main.dart': mainDartFile, ...dartFiles};

  ProjectData copy() => copyWith();

  String? fileContentFor(String key) {
    return switchFile(
      key,
      onMain: () => mainDartFile,
      onHtml: () => htmlFile,
      onCss: () => cssFile,
      onDart: () => dartFiles[key],
    );
  }

  ProjectData updateContent(String key, String? content) {
    return switchFile(
      key,
      onMain: () => copyWith(mainDartFile: content),
      onHtml: () => copyWith(htmlFile: content),
      onCss: () => copyWith(cssFile: content),
      onDart: () => copyWith(dartFiles: content != null ? {...dartFiles, key: content} : ({...dartFiles}..remove(key))),
    );
  }

  static T switchFile<T>(
    String key, {
    required T Function() onMain,
    required T Function() onHtml,
    required T Function() onCss,
    required T Function() onDart,
  }) {
    switch (key) {
      case 'main.dart':
        return onMain();
      case 'index.html':
        return onHtml();
      case 'styles.css':
        return onCss();
      default:
        return onDart();
    }
  }

  bool isDart(String key) {
    return key == 'main.dart' || dartFiles.keys.contains(key);
  }

  static bool canDelete(String key) {
    return switchFile(key, onMain: () => false, onHtml: () => true, onCss: () => true, onDart: () => true);
  }
}
