// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'project.dart';

class ProjectDataBaseMapper extends ClassMapperBase<ProjectDataBase> {
  ProjectDataBaseMapper._();

  static ProjectDataBaseMapper? _instance;
  static ProjectDataBaseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProjectDataBaseMapper._());
      TutorialDataMapper.ensureInitialized();
      TutorialStepMapper.ensureInitialized();
      ProjectDataMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ProjectDataBase';

  static String? _$id(ProjectDataBase v) => v.id;
  static const Field<ProjectDataBase, String> _f$id = Field(
    'id',
    _$id,
    mode: FieldMode.member,
  );
  static String? _$description(ProjectDataBase v) => v.description;
  static const Field<ProjectDataBase, String> _f$description = Field(
    'description',
    _$description,
    mode: FieldMode.member,
  );
  static String? _$htmlFile(ProjectDataBase v) => v.htmlFile;
  static const Field<ProjectDataBase, String> _f$htmlFile = Field(
    'htmlFile',
    _$htmlFile,
    mode: FieldMode.member,
  );
  static String? _$cssFile(ProjectDataBase v) => v.cssFile;
  static const Field<ProjectDataBase, String> _f$cssFile = Field(
    'cssFile',
    _$cssFile,
    mode: FieldMode.member,
  );
  static String _$mainDartFile(ProjectDataBase v) => v.mainDartFile;
  static const Field<ProjectDataBase, String> _f$mainDartFile = Field(
    'mainDartFile',
    _$mainDartFile,
    mode: FieldMode.member,
  );
  static Map<String, String> _$dartFiles(ProjectDataBase v) => v.dartFiles;
  static const Field<ProjectDataBase, Map<String, String>> _f$dartFiles = Field(
    'dartFiles',
    _$dartFiles,
    mode: FieldMode.member,
  );
  static List<String> _$fileNames(ProjectDataBase v) => v.fileNames;
  static const Field<ProjectDataBase, List<String>> _f$fileNames = Field(
    'fileNames',
    _$fileNames,
    mode: FieldMode.member,
  );
  static Map<String, String> _$allDartFiles(ProjectDataBase v) => v.allDartFiles;
  static const Field<ProjectDataBase, Map<String, String>> _f$allDartFiles =
      Field('allDartFiles', _$allDartFiles, mode: FieldMode.member);

  @override
  final MappableFields<ProjectDataBase> fields = const {
    #id: _f$id,
    #description: _f$description,
    #htmlFile: _f$htmlFile,
    #cssFile: _f$cssFile,
    #mainDartFile: _f$mainDartFile,
    #dartFiles: _f$dartFiles,
    #fileNames: _f$fileNames,
    #allDartFiles: _f$allDartFiles,
  };

  static ProjectDataBase _instantiate(DecodingData data) {
    throw MapperException.missingSubclass(
      'ProjectDataBase',
      'type',
      '${data.value['type']}',
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProjectDataBase fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProjectDataBase>(map);
  }

  static ProjectDataBase fromJson(String json) {
    return ensureInitialized().decodeJson<ProjectDataBase>(json);
  }
}

mixin ProjectDataBaseMappable {}

class ProjectDataMapper extends SubClassMapperBase<ProjectData> {
  ProjectDataMapper._();

  static ProjectDataMapper? _instance;
  static ProjectDataMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ProjectDataMapper._());
      ProjectDataBaseMapper.ensureInitialized().addSubMapper(_instance!);
    }
    return _instance!;
  }

  @override
  final String id = 'ProjectData';

  static String? _$id(ProjectData v) => v.id;
  static const Field<ProjectData, String> _f$id = Field('id', _$id, opt: true);
  static String? _$description(ProjectData v) => v.description;
  static const Field<ProjectData, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$htmlFile(ProjectData v) => v.htmlFile;
  static const Field<ProjectData, String> _f$htmlFile = Field(
    'htmlFile',
    _$htmlFile,
    opt: true,
  );
  static String? _$cssFile(ProjectData v) => v.cssFile;
  static const Field<ProjectData, String> _f$cssFile = Field(
    'cssFile',
    _$cssFile,
    opt: true,
  );
  static String _$mainDartFile(ProjectData v) => v.mainDartFile;
  static const Field<ProjectData, String> _f$mainDartFile = Field(
    'mainDartFile',
    _$mainDartFile,
  );
  static Map<String, String> _$dartFiles(ProjectData v) => v.dartFiles;
  static const Field<ProjectData, Map<String, String>> _f$dartFiles = Field(
    'dartFiles',
    _$dartFiles,
    opt: true,
    def: const {},
  );
  static List<String> _$fileNames(ProjectData v) => v.fileNames;
  static const Field<ProjectData, List<String>> _f$fileNames = Field(
    'fileNames',
    _$fileNames,
    mode: FieldMode.member,
  );
  static Map<String, String> _$allDartFiles(ProjectData v) => v.allDartFiles;
  static const Field<ProjectData, Map<String, String>> _f$allDartFiles = Field(
    'allDartFiles',
    _$allDartFiles,
    mode: FieldMode.member,
  );

  @override
  final MappableFields<ProjectData> fields = const {
    #id: _f$id,
    #description: _f$description,
    #htmlFile: _f$htmlFile,
    #cssFile: _f$cssFile,
    #mainDartFile: _f$mainDartFile,
    #dartFiles: _f$dartFiles,
    #fileNames: _f$fileNames,
    #allDartFiles: _f$allDartFiles,
  };

  @override
  final String discriminatorKey = 'type';
  @override
  final dynamic discriminatorValue = 'ProjectData';
  @override
  late final ClassMapperBase superMapper = ProjectDataBaseMapper.ensureInitialized();

  static ProjectData _instantiate(DecodingData data) {
    return ProjectData(
      id: data.dec(_f$id),
      description: data.dec(_f$description),
      htmlFile: data.dec(_f$htmlFile),
      cssFile: data.dec(_f$cssFile),
      mainDartFile: data.dec(_f$mainDartFile),
      dartFiles: data.dec(_f$dartFiles),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static ProjectData fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ProjectData>(map);
  }

  static ProjectData fromJson(String json) {
    return ensureInitialized().decodeJson<ProjectData>(json);
  }
}

mixin ProjectDataMappable {
  String toJson() {
    return ProjectDataMapper.ensureInitialized().encodeJson<ProjectData>(
      this as ProjectData,
    );
  }

  Map<String, dynamic> toMap() {
    return ProjectDataMapper.ensureInitialized().encodeMap<ProjectData>(
      this as ProjectData,
    );
  }

  ProjectDataCopyWith<ProjectData, ProjectData, ProjectData> get copyWith =>
      _ProjectDataCopyWithImpl<ProjectData, ProjectData>(
        this as ProjectData,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ProjectDataMapper.ensureInitialized().stringifyValue(
      this as ProjectData,
    );
  }

  @override
  bool operator ==(Object other) {
    return ProjectDataMapper.ensureInitialized().equalsValue(
      this as ProjectData,
      other,
    );
  }

  @override
  int get hashCode {
    return ProjectDataMapper.ensureInitialized().hashValue(this as ProjectData);
  }
}

extension ProjectDataValueCopy<$R, $Out> on ObjectCopyWith<$R, ProjectData, $Out> {
  ProjectDataCopyWith<$R, ProjectData, $Out> get $asProjectData =>
      $base.as((v, t, t2) => _ProjectDataCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ProjectDataCopyWith<$R, $In extends ProjectData, $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get dartFiles;
  $R call({
    String? id,
    String? description,
    String? htmlFile,
    String? cssFile,
    String? mainDartFile,
    Map<String, String>? dartFiles,
  });
  ProjectDataCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ProjectDataCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, ProjectData, $Out>
    implements ProjectDataCopyWith<$R, ProjectData, $Out> {
  _ProjectDataCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ProjectData> $mapper = ProjectDataMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get dartFiles => MapCopyWith(
        $value.dartFiles,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(dartFiles: v),
      );
  @override
  $R call({
    Object? id = $none,
    Object? description = $none,
    Object? htmlFile = $none,
    Object? cssFile = $none,
    String? mainDartFile,
    Map<String, String>? dartFiles,
  }) =>
      $apply(
        FieldCopyWithData({
          if (id != $none) #id: id,
          if (description != $none) #description: description,
          if (htmlFile != $none) #htmlFile: htmlFile,
          if (cssFile != $none) #cssFile: cssFile,
          if (mainDartFile != null) #mainDartFile: mainDartFile,
          if (dartFiles != null) #dartFiles: dartFiles,
        }),
      );
  @override
  ProjectData $make(CopyWithData data) => ProjectData(
        id: data.get(#id, or: $value.id),
        description: data.get(#description, or: $value.description),
        htmlFile: data.get(#htmlFile, or: $value.htmlFile),
        cssFile: data.get(#cssFile, or: $value.cssFile),
        mainDartFile: data.get(#mainDartFile, or: $value.mainDartFile),
        dartFiles: data.get(#dartFiles, or: $value.dartFiles),
      );

  @override
  ProjectDataCopyWith<$R2, ProjectData, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _ProjectDataCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
