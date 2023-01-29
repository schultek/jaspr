// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element

part of 'project.dart';

class ProjectDataBaseMapper extends MapperBase<ProjectDataBase> {
  static MapperContainer? _c;
  static MapperContainer container = _c ??
      ((_c = MapperContainer(
        mappers: {ProjectDataBaseMapper()},
      ))
        ..linkAll({
          TutorialDataMapper.container,
          TutorialStepMapper.container,
          ProjectDataMapper.container,
        }));

  @override
  ProjectDataBaseMapperElement createElement(MapperContainer container) {
    return ProjectDataBaseMapperElement._(this, container);
  }

  @override
  String get id => 'ProjectDataBase';

  static final fromMap = container.fromMap<ProjectDataBase>;
  static final fromJson = container.fromJson<ProjectDataBase>;
}

class ProjectDataBaseMapperElement extends MapperElementBase<ProjectDataBase> {
  ProjectDataBaseMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  ProjectDataBase decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) {
        switch (map['type']) {
          case 'ProjectData':
            return ProjectDataMapper().createElement(container).decode(map);
          case 'TutorialData':
            return TutorialDataMapper().createElement(container).decode(map);
          case 'TutorialStep':
            return TutorialStepMapper().createElement(container).decode(map);
          default:
            return fromMap(map);
        }
      });
  ProjectDataBase fromMap(Map<String, dynamic> map) =>
      throw MapperException.missingSubclass(
          'ProjectDataBase', 'type', '${map['type']}');
}

mixin ProjectDataBaseMappable {}

class ProjectDataMapper extends MapperBase<ProjectData> {
  static MapperContainer? _c;
  static MapperContainer container = _c ??
      ((_c = MapperContainer(
        mappers: {ProjectDataMapper()},
      ))
        ..linkAll({ProjectDataBaseMapper.container}));

  @override
  ProjectDataMapperElement createElement(MapperContainer container) {
    return ProjectDataMapperElement._(this, container);
  }

  @override
  String get id => 'ProjectData';

  static final fromMap = container.fromMap<ProjectData>;
  static final fromJson = container.fromJson<ProjectData>;
}

class ProjectDataMapperElement extends MapperElementBase<ProjectData> {
  ProjectDataMapperElement._(super.mapper, super.container);

  @override
  Function get decoder => decode;
  ProjectData decode(dynamic v) =>
      checkedType(v, (Map<String, dynamic> map) => fromMap(map));
  ProjectData fromMap(Map<String, dynamic> map) => ProjectData(
      id: container.$getOpt(map, 'id'),
      description: container.$getOpt(map, 'description'),
      htmlFile: container.$getOpt(map, 'htmlFile'),
      cssFile: container.$getOpt(map, 'cssFile'),
      mainDartFile: container.$get(map, 'mainDartFile'),
      dartFiles: container.$getOpt(map, 'dartFiles') ?? const {});

  @override
  Function get encoder => encode;
  dynamic encode(ProjectData v) => toMap(v);
  Map<String, dynamic> toMap(ProjectData p) => {
        'id': container.$enc(p.id, 'id'),
        'description': container.$enc(p.description, 'description'),
        'htmlFile': container.$enc(p.htmlFile, 'htmlFile'),
        'cssFile': container.$enc(p.cssFile, 'cssFile'),
        'mainDartFile': container.$enc(p.mainDartFile, 'mainDartFile'),
        'dartFiles': container.$enc(p.dartFiles, 'dartFiles'),
        'type': 'ProjectData'
      };

  @override
  String stringify(ProjectData self) =>
      'ProjectData(id: ${container.asString(self.id)}, description: ${container.asString(self.description)}, htmlFile: ${container.asString(self.htmlFile)}, cssFile: ${container.asString(self.cssFile)}, mainDartFile: ${container.asString(self.mainDartFile)}, dartFiles: ${container.asString(self.dartFiles)})';
  @override
  int hash(ProjectData self) =>
      container.hash(self.id) ^
      container.hash(self.description) ^
      container.hash(self.htmlFile) ^
      container.hash(self.cssFile) ^
      container.hash(self.mainDartFile) ^
      container.hash(self.dartFiles);
  @override
  bool equals(ProjectData self, ProjectData other) =>
      container.isEqual(self.id, other.id) &&
      container.isEqual(self.description, other.description) &&
      container.isEqual(self.htmlFile, other.htmlFile) &&
      container.isEqual(self.cssFile, other.cssFile) &&
      container.isEqual(self.mainDartFile, other.mainDartFile) &&
      container.isEqual(self.dartFiles, other.dartFiles);
}

mixin ProjectDataMappable {
  String toJson() => ProjectDataMapper.container.toJson(this as ProjectData);
  Map<String, dynamic> toMap() =>
      ProjectDataMapper.container.toMap(this as ProjectData);
  ProjectDataCopyWith<ProjectData, ProjectData, ProjectData> get copyWith =>
      _ProjectDataCopyWithImpl(this as ProjectData, $identity, $identity);
  @override
  String toString() => ProjectDataMapper.container.asString(this);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (runtimeType == other.runtimeType &&
          ProjectDataMapper.container.isEqual(this, other));
  @override
  int get hashCode => ProjectDataMapper.container.hash(this);
}

extension ProjectDataValueCopy<$R, $Out extends ProjectDataBase>
    on ObjectCopyWith<$R, ProjectData, $Out> {
  ProjectDataCopyWith<$R, ProjectData, $Out> get asProjectData =>
      base.as((v, t, t2) => _ProjectDataCopyWithImpl(v, t, t2));
}

typedef ProjectDataCopyWithBound = ProjectDataBase;

abstract class ProjectDataCopyWith<$R, $In extends ProjectData,
    $Out extends ProjectDataBase> implements ObjectCopyWith<$R, $In, $Out> {
  ProjectDataCopyWith<$R2, $In, $Out2>
      chain<$R2, $Out2 extends ProjectDataBase>(
          Then<ProjectData, $Out2> t, Then<$Out2, $R2> t2);
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>
      get dartFiles;
  $R call(
      {String? id,
      String? description,
      String? htmlFile,
      String? cssFile,
      String? mainDartFile,
      Map<String, String>? dartFiles});
}

class _ProjectDataCopyWithImpl<$R, $Out extends ProjectDataBase>
    extends CopyWithBase<$R, ProjectData, $Out>
    implements ProjectDataCopyWith<$R, ProjectData, $Out> {
  _ProjectDataCopyWithImpl(super.value, super.then, super.then2);
  @override
  ProjectDataCopyWith<$R2, ProjectData, $Out2>
      chain<$R2, $Out2 extends ProjectDataBase>(
              Then<ProjectData, $Out2> t, Then<$Out2, $R2> t2) =>
          _ProjectDataCopyWithImpl($value, t, t2);

  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>>
      get dartFiles => MapCopyWith($value.dartFiles,
          (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(dartFiles: v));
  @override
  $R call(
          {Object? id = $none,
          Object? description = $none,
          Object? htmlFile = $none,
          Object? cssFile = $none,
          String? mainDartFile,
          Map<String, String>? dartFiles}) =>
      $then(ProjectData(
          id: or(id, $value.id),
          description: or(description, $value.description),
          htmlFile: or(htmlFile, $value.htmlFile),
          cssFile: or(cssFile, $value.cssFile),
          mainDartFile: mainDartFile ?? $value.mainDartFile,
          dartFiles: dartFiles ?? $value.dartFiles));
}
