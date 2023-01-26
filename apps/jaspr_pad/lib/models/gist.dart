import 'package:dart_mappable/dart_mappable.dart';

part 'gist.mapper.dart';

@MappableClass()
class GistData with GistDataMappable {
  final String? id;
  final String? description;
  final Map<String, GistFile> files;

  GistData(this.id, this.description, this.files);
}

@MappableClass()
class GistFile with GistFileMappable {
  @MappableField(key: 'filename')
  String name;
  String content;
  String type;

  GistFile(this.name, this.content, this.type);
}
