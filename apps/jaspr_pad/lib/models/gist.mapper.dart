// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'gist.dart';

class GistDataMapper extends ClassMapperBase<GistData> {
  GistDataMapper._();

  static GistDataMapper? _instance;
  static GistDataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GistDataMapper._());
      GistFileMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'GistData';

  static String? _$id(GistData v) => v.id;
  static const Field<GistData, String> _f$id = Field('id', _$id);
  static String? _$description(GistData v) => v.description;
  static const Field<GistData, String> _f$description = Field(
    'description',
    _$description,
  );
  static Map<String, GistFile> _$files(GistData v) => v.files;
  static const Field<GistData, Map<String, GistFile>> _f$files = Field(
    'files',
    _$files,
  );

  @override
  final MappableFields<GistData> fields = const {
    #id: _f$id,
    #description: _f$description,
    #files: _f$files,
  };

  static GistData _instantiate(DecodingData data) {
    return GistData(
      data.dec(_f$id),
      data.dec(_f$description),
      data.dec(_f$files),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static GistData fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GistData>(map);
  }

  static GistData fromJson(String json) {
    return ensureInitialized().decodeJson<GistData>(json);
  }
}

mixin GistDataMappable {
  String toJson() {
    return GistDataMapper.ensureInitialized().encodeJson<GistData>(
      this as GistData,
    );
  }

  Map<String, dynamic> toMap() {
    return GistDataMapper.ensureInitialized().encodeMap<GistData>(
      this as GistData,
    );
  }

  GistDataCopyWith<GistData, GistData, GistData> get copyWith => _GistDataCopyWithImpl<GistData, GistData>(
        this as GistData,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GistDataMapper.ensureInitialized().stringifyValue(this as GistData);
  }

  @override
  bool operator ==(Object other) {
    return GistDataMapper.ensureInitialized().equalsValue(
      this as GistData,
      other,
    );
  }

  @override
  int get hashCode {
    return GistDataMapper.ensureInitialized().hashValue(this as GistData);
  }
}

extension GistDataValueCopy<$R, $Out> on ObjectCopyWith<$R, GistData, $Out> {
  GistDataCopyWith<$R, GistData, $Out> get $asGistData =>
      $base.as((v, t, t2) => _GistDataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GistDataCopyWith<$R, $In extends GistData, $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, GistFile, GistFileCopyWith<$R, GistFile, GistFile>> get files;
  $R call({String? id, String? description, Map<String, GistFile>? files});
  GistDataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GistDataCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, GistData, $Out>
    implements GistDataCopyWith<$R, GistData, $Out> {
  _GistDataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GistData> $mapper = GistDataMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, GistFile, GistFileCopyWith<$R, GistFile, GistFile>> get files => MapCopyWith(
        $value.files,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(files: v),
      );
  @override
  $R call({
    Object? id = $none,
    Object? description = $none,
    Map<String, GistFile>? files,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != $none) #id: id,
          if (description != $none) #description: description,
          if (files != null) #files: files,
        }),
      );
  @override
  GistData $make(CopyWithData data) => GistData(
        data.get(#id, or: $value.id),
        data.get(#description, or: $value.description),
        data.get(#files, or: $value.files),
      );

  @override
  GistDataCopyWith<$R2, GistData, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _GistDataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class GistFileMapper extends ClassMapperBase<GistFile> {
  GistFileMapper._();

  static GistFileMapper? _instance;
  static GistFileMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = GistFileMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'GistFile';

  static String _$name(GistFile v) => v.name;
  static const Field<GistFile, String> _f$name = Field(
    'name',
    _$name,
    key: r'filename',
  );
  static String _$content(GistFile v) => v.content;
  static const Field<GistFile, String> _f$content = Field('content', _$content);
  static String _$type(GistFile v) => v.type;
  static const Field<GistFile, String> _f$type = Field('type', _$type);

  @override
  final MappableFields<GistFile> fields = const {
    #name: _f$name,
    #content: _f$content,
    #type: _f$type,
  };

  static GistFile _instantiate(DecodingData data) {
    return GistFile(data.dec(_f$name), data.dec(_f$content), data.dec(_f$type));
  }

  @override
  final Function instantiate = _instantiate;

  static GistFile fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<GistFile>(map);
  }

  static GistFile fromJson(String json) {
    return ensureInitialized().decodeJson<GistFile>(json);
  }
}

mixin GistFileMappable {
  String toJson() {
    return GistFileMapper.ensureInitialized().encodeJson<GistFile>(
      this as GistFile,
    );
  }

  Map<String, dynamic> toMap() {
    return GistFileMapper.ensureInitialized().encodeMap<GistFile>(
      this as GistFile,
    );
  }

  GistFileCopyWith<GistFile, GistFile, GistFile> get copyWith => _GistFileCopyWithImpl<GistFile, GistFile>(
        this as GistFile,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return GistFileMapper.ensureInitialized().stringifyValue(this as GistFile);
  }

  @override
  bool operator ==(Object other) {
    return GistFileMapper.ensureInitialized().equalsValue(
      this as GistFile,
      other,
    );
  }

  @override
  int get hashCode {
    return GistFileMapper.ensureInitialized().hashValue(this as GistFile);
  }
}

extension GistFileValueCopy<$R, $Out> on ObjectCopyWith<$R, GistFile, $Out> {
  GistFileCopyWith<$R, GistFile, $Out> get $asGistFile =>
      $base.as((v, t, t2) => _GistFileCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class GistFileCopyWith<$R, $In extends GistFile, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? name, String? content, String? type});
  GistFileCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _GistFileCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, GistFile, $Out>
    implements GistFileCopyWith<$R, GistFile, $Out> {
  _GistFileCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<GistFile> $mapper = GistFileMapper.ensureInitialized();
  @override
  $R call({String? name, String? content, String? type}) => $apply(
        FieldCopyWithData({
          if (name != null) #name: name,
          if (content != null) #content: content,
          if (type != null) #type: type,
        }),
      );
  @override
  GistFile $make(CopyWithData data) => GistFile(
        data.get(#name, or: $value.name),
        data.get(#content, or: $value.content),
        data.get(#type, or: $value.type),
      );

  @override
  GistFileCopyWith<$R2, GistFile, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _GistFileCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
