// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'gist.dart';

class GistDataMapper extends MapperBase<GistData> {
  static MapperContainer container = MapperContainer(
    mappers: {GistDataMapper()},
  )..linkAll({GistFileMapper.container});

  @override
  GistDataMapperElement createElement(MapperContainer container) {
    return GistDataMapperElement._(this, container);
  }

  @override
  String get id => 'GistData';

  static final fromMap = container.fromMap<GistData>;
  static final fromJson = container.fromJson<GistData>;
}

class GistDataMapperElement extends MapperElementBase<GistData> {
  GistDataMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  GistData decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  GistData fromMap(Map<String, dynamic> map) => GistData(
      container.$getOpt(map, 'id'),
      container.$getOpt(map, 'description'),
      container.$get(map, 'files'));

  @override
  Function get encoder => encode;
  dynamic encode(GistData v) => toMap(v);
  Map<String, dynamic> toMap(GistData g) => {
        'id': container.$enc(g.id, 'id'),
        'description': container.$enc(g.description, 'description'),
        'files': container.$enc(g.files, 'files')
      };

  @override
  String stringify(GistData self) =>
      'GistData(id: ${container.asString(self.id)}, description: ${container.asString(self.description)}, files: ${container.asString(self.files)})';
  @override
  int hash(GistData self) =>
      container.hash(self.id) ^
      container.hash(self.description) ^
      container.hash(self.files);
  @override
  bool equals(GistData self, GistData other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.description, other.description) &&
      container.isEqual(self.files, other.files);
}

mixin GistDataMappable {
  String toJson() => GistDataMapper.container.toJson(this as GistData);
  Map<String, dynamic> toMap() =>
      GistDataMapper.container.toMap(this as GistData);
  GistDataCopyWith<GistData, GistData, GistData> get copyWith =>
      _GistDataCopyWithImpl(this as GistData, $identity, $identity);
  @override
  String toString() => GistDataMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          GistDataMapper.container.isEqual(this, other));
  @override
  int get hashCode => GistDataMapper.container.hash(this);
}

extension GistDataValueCopy<$R, $Out extends GistData>
    on ObjectCopyWith<$R, GistData, $Out> {
  GistDataCopyWith<$R, GistData, $Out> get asGistData =>
      base.as((v, t, t2) => _GistDataCopyWithImpl(v, t, t2));
}

typedef GistDataCopyWithBound = GistData;

abstract class GistDataCopyWith<$R, $In extends GistData, $Out extends GistData>
    implements ObjectCopyWith<$R, $In, $Out> {
  GistDataCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends GistData>(
      Then<GistData, $Out2> t, Then<$Out2, $R2> t2);
  MapCopyWith<$R, String, GistFile, GistFileCopyWith<$R, GistFile, GistFile>>
      get files;
  $R call({String? id, String? description, Map<String, GistFile>? files});
}

class _GistDataCopyWithImpl<$R, $Out extends GistData>
    extends CopyWithBase<$R, GistData, $Out>
    implements GistDataCopyWith<$R, GistData, $Out> {
  _GistDataCopyWithImpl(super.value, super.then, super.then2);
  @override
  GistDataCopyWith<$R2, GistData, $Out2> chain<$R2, $Out2 extends GistData>(
          Then<GistData, $Out2> t, Then<$Out2, $R2> t2) =>
      _GistDataCopyWithImpl($value, t, t2);

  @override
  MapCopyWith<$R, String, GistFile, GistFileCopyWith<$R, GistFile, GistFile>>
      get files => MapCopyWith(
          $value.files,
          (v, t) => v.copyWith.chain<$R, GistFile>($identity, t),
          (v) => call(files: v));
  @override
  $R call(
          {Object? id = $none,
          Object? description = $none,
          Map<String, GistFile>? files}) =>
      $then(GistData(or(id, $value.id), or(description, $value.description),
          files ?? $value.files));
}

class GistFileMapper extends MapperBase<GistFile> {
  static MapperContainer container = MapperContainer(
    mappers: {GistFileMapper()},
  );

  @override
  GistFileMapperElement createElement(MapperContainer container) {
    return GistFileMapperElement._(this, container);
  }

  @override
  String get id => 'GistFile';

  static final fromMap = container.fromMap<GistFile>;
  static final fromJson = container.fromJson<GistFile>;
}

class GistFileMapperElement extends MapperElementBase<GistFile> {
  GistFileMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  GistFile decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  GistFile fromMap(Map<String, dynamic> map) => GistFile(
      container.$get(map, 'filename'),
      container.$get(map, 'content'),
      container.$get(map, 'type'));

  @override
  Function get encoder => encode;
  dynamic encode(GistFile v) => toMap(v);
  Map<String, dynamic> toMap(GistFile g) => {
        'filename': container.$enc(g.name, 'name'),
        'content': container.$enc(g.content, 'content'),
        'type': container.$enc(g.type, 'type')
      };

  @override
  String stringify(GistFile self) =>
      'GistFile(name: ${container.asString(self.name)}, content: ${container.asString(self.content)}, type: ${container.asString(self.type)})';
  @override
  int hash(GistFile self) =>
      container.hash(self.name) ^
      container.hash(self.content) ^
      container.hash(self.type);
  @override
  bool equals(GistFile self, GistFile other) =>
      container.isEqual(self.name, other.name) &&
      container.isEqual(self.content, other.content) &&
      container.isEqual(self.type, other.type);
}

mixin GistFileMappable {
  String toJson() => GistFileMapper.container.toJson(this as GistFile);
  Map<String, dynamic> toMap() =>
      GistFileMapper.container.toMap(this as GistFile);
  GistFileCopyWith<GistFile, GistFile, GistFile> get copyWith =>
      _GistFileCopyWithImpl(this as GistFile, $identity, $identity);
  @override
  String toString() => GistFileMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          GistFileMapper.container.isEqual(this, other));
  @override
  int get hashCode => GistFileMapper.container.hash(this);
}

extension GistFileValueCopy<$R, $Out extends GistFile>
    on ObjectCopyWith<$R, GistFile, $Out> {
  GistFileCopyWith<$R, GistFile, $Out> get asGistFile =>
      base.as((v, t, t2) => _GistFileCopyWithImpl(v, t, t2));
}

typedef GistFileCopyWithBound = GistFile;

abstract class GistFileCopyWith<$R, $In extends GistFile, $Out extends GistFile>
    implements ObjectCopyWith<$R, $In, $Out> {
  GistFileCopyWith<$R2, $In, $Out2> chain<$R2, $Out2 extends GistFile>(
      Then<GistFile, $Out2> t, Then<$Out2, $R2> t2);
  $R call({String? name, String? content, String? type});
}

class _GistFileCopyWithImpl<$R, $Out extends GistFile>
    extends CopyWithBase<$R, GistFile, $Out>
    implements GistFileCopyWith<$R, GistFile, $Out> {
  _GistFileCopyWithImpl(super.value, super.then, super.then2);
  @override
  GistFileCopyWith<$R2, GistFile, $Out2> chain<$R2, $Out2 extends GistFile>(
          Then<GistFile, $Out2> t, Then<$Out2, $R2> t2) =>
      _GistFileCopyWithImpl($value, t, t2);

  @override
  $R call({String? name, String? content, String? type}) => $then(GistFile(
      name ?? $value.name, content ?? $value.content, type ?? $value.type));
}
