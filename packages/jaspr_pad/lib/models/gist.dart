import 'package:dart_mappable/dart_mappable.dart';

@MappableClass()
class GistData {
  final String? id;
  final String? description;
  final Map<String, GistFile> files;

  GistData(this.id, this.description, this.files);
}

@MappableClass()
class GistFile {
  @MappableField(key: 'filename')
  String name;
  String content;
  String type;

  GistFile(this.name, this.content, this.type);
}
