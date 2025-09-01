// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'api_models.dart';

class IssueKindMapper extends EnumMapper<IssueKind> {
  IssueKindMapper._();

  static IssueKindMapper? _instance;
  static IssueKindMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IssueKindMapper._());
    }
    return _instance!;
  }

  static IssueKind fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  IssueKind decode(dynamic value) {
    switch (value) {
      case r'error':
        return IssueKind.error;
      case r'warning':
        return IssueKind.warning;
      case r'info':
        return IssueKind.info;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(IssueKind self) {
    switch (self) {
      case IssueKind.error:
        return r'error';
      case IssueKind.warning:
        return r'warning';
      case IssueKind.info:
        return r'info';
    }
  }
}

extension IssueKindMapperExtension on IssueKind {
  String toValue() {
    IssueKindMapper.ensureInitialized();
    return MapperContainer.globals.toValue<IssueKind>(this) as String;
  }
}

class CompileRequestMapper extends ClassMapperBase<CompileRequest> {
  CompileRequestMapper._();

  static CompileRequestMapper? _instance;
  static CompileRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CompileRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CompileRequest';

  static Map<String, String> _$sources(CompileRequest v) => v.sources;
  static const Field<CompileRequest, Map<String, String>> _f$sources = Field(
    'sources',
    _$sources,
  );

  @override
  final MappableFields<CompileRequest> fields = const {#sources: _f$sources};

  static CompileRequest _instantiate(DecodingData data) {
    return CompileRequest(data.dec(_f$sources));
  }

  @override
  final Function instantiate = _instantiate;

  static CompileRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CompileRequest>(map);
  }

  static CompileRequest fromJson(String json) {
    return ensureInitialized().decodeJson<CompileRequest>(json);
  }
}

mixin CompileRequestMappable {
  String toJson() {
    return CompileRequestMapper.ensureInitialized().encodeJson<CompileRequest>(
      this as CompileRequest,
    );
  }

  Map<String, dynamic> toMap() {
    return CompileRequestMapper.ensureInitialized().encodeMap<CompileRequest>(
      this as CompileRequest,
    );
  }

  CompileRequestCopyWith<CompileRequest, CompileRequest, CompileRequest> get copyWith =>
      _CompileRequestCopyWithImpl<CompileRequest, CompileRequest>(
        this as CompileRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CompileRequestMapper.ensureInitialized().stringifyValue(
      this as CompileRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return CompileRequestMapper.ensureInitialized().equalsValue(
      this as CompileRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return CompileRequestMapper.ensureInitialized().hashValue(
      this as CompileRequest,
    );
  }
}

extension CompileRequestValueCopy<$R, $Out> on ObjectCopyWith<$R, CompileRequest, $Out> {
  CompileRequestCopyWith<$R, CompileRequest, $Out> get $asCompileRequest =>
      $base.as((v, t, t2) => _CompileRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CompileRequestCopyWith<$R, $In extends CompileRequest, $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources;
  $R call({Map<String, String>? sources});
  CompileRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CompileRequestCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, CompileRequest, $Out>
    implements CompileRequestCopyWith<$R, CompileRequest, $Out> {
  _CompileRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CompileRequest> $mapper = CompileRequestMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources => MapCopyWith(
        $value.sources,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(sources: v),
      );
  @override
  $R call({Map<String, String>? sources}) => $apply(FieldCopyWithData({if (sources != null) #sources: sources}));
  @override
  CompileRequest $make(CopyWithData data) => CompileRequest(data.get(#sources, or: $value.sources));

  @override
  CompileRequestCopyWith<$R2, CompileRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _CompileRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class CompileResponseMapper extends ClassMapperBase<CompileResponse> {
  CompileResponseMapper._();

  static CompileResponseMapper? _instance;
  static CompileResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CompileResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CompileResponse';

  static String? _$result(CompileResponse v) => v.result;
  static const Field<CompileResponse, String> _f$result = Field(
    'result',
    _$result,
  );
  static String? _$error(CompileResponse v) => v.error;
  static const Field<CompileResponse, String> _f$error = Field(
    'error',
    _$error,
  );

  @override
  final MappableFields<CompileResponse> fields = const {
    #result: _f$result,
    #error: _f$error,
  };

  static CompileResponse _instantiate(DecodingData data) {
    return CompileResponse(data.dec(_f$result), data.dec(_f$error));
  }

  @override
  final Function instantiate = _instantiate;

  static CompileResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CompileResponse>(map);
  }

  static CompileResponse fromJson(String json) {
    return ensureInitialized().decodeJson<CompileResponse>(json);
  }
}

mixin CompileResponseMappable {
  String toJson() {
    return CompileResponseMapper.ensureInitialized().encodeJson<CompileResponse>(this as CompileResponse);
  }

  Map<String, dynamic> toMap() {
    return CompileResponseMapper.ensureInitialized().encodeMap<CompileResponse>(
      this as CompileResponse,
    );
  }

  CompileResponseCopyWith<CompileResponse, CompileResponse, CompileResponse> get copyWith =>
      _CompileResponseCopyWithImpl<CompileResponse, CompileResponse>(
        this as CompileResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CompileResponseMapper.ensureInitialized().stringifyValue(
      this as CompileResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return CompileResponseMapper.ensureInitialized().equalsValue(
      this as CompileResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return CompileResponseMapper.ensureInitialized().hashValue(
      this as CompileResponse,
    );
  }
}

extension CompileResponseValueCopy<$R, $Out> on ObjectCopyWith<$R, CompileResponse, $Out> {
  CompileResponseCopyWith<$R, CompileResponse, $Out> get $asCompileResponse =>
      $base.as((v, t, t2) => _CompileResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CompileResponseCopyWith<$R, $In extends CompileResponse, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? result, String? error});
  CompileResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _CompileResponseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, CompileResponse, $Out>
    implements CompileResponseCopyWith<$R, CompileResponse, $Out> {
  _CompileResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CompileResponse> $mapper = CompileResponseMapper.ensureInitialized();
  @override
  $R call({Object? result = $none, Object? error = $none}) => $apply(
        FieldCopyWithData({
          if (result != $none) #result: result,
          if (error != $none) #error: error,
        }),
      );
  @override
  CompileResponse $make(CopyWithData data) => CompileResponse(
        data.get(#result, or: $value.result),
        data.get(#error, or: $value.error),
      );

  @override
  CompileResponseCopyWith<$R2, CompileResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _CompileResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AnalyzeRequestMapper extends ClassMapperBase<AnalyzeRequest> {
  AnalyzeRequestMapper._();

  static AnalyzeRequestMapper? _instance;
  static AnalyzeRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AnalyzeRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'AnalyzeRequest';

  static Map<String, String> _$sources(AnalyzeRequest v) => v.sources;
  static const Field<AnalyzeRequest, Map<String, String>> _f$sources = Field(
    'sources',
    _$sources,
  );

  @override
  final MappableFields<AnalyzeRequest> fields = const {#sources: _f$sources};

  static AnalyzeRequest _instantiate(DecodingData data) {
    return AnalyzeRequest(data.dec(_f$sources));
  }

  @override
  final Function instantiate = _instantiate;

  static AnalyzeRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AnalyzeRequest>(map);
  }

  static AnalyzeRequest fromJson(String json) {
    return ensureInitialized().decodeJson<AnalyzeRequest>(json);
  }
}

mixin AnalyzeRequestMappable {
  String toJson() {
    return AnalyzeRequestMapper.ensureInitialized().encodeJson<AnalyzeRequest>(
      this as AnalyzeRequest,
    );
  }

  Map<String, dynamic> toMap() {
    return AnalyzeRequestMapper.ensureInitialized().encodeMap<AnalyzeRequest>(
      this as AnalyzeRequest,
    );
  }

  AnalyzeRequestCopyWith<AnalyzeRequest, AnalyzeRequest, AnalyzeRequest> get copyWith =>
      _AnalyzeRequestCopyWithImpl<AnalyzeRequest, AnalyzeRequest>(
        this as AnalyzeRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AnalyzeRequestMapper.ensureInitialized().stringifyValue(
      this as AnalyzeRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return AnalyzeRequestMapper.ensureInitialized().equalsValue(
      this as AnalyzeRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return AnalyzeRequestMapper.ensureInitialized().hashValue(
      this as AnalyzeRequest,
    );
  }
}

extension AnalyzeRequestValueCopy<$R, $Out> on ObjectCopyWith<$R, AnalyzeRequest, $Out> {
  AnalyzeRequestCopyWith<$R, AnalyzeRequest, $Out> get $asAnalyzeRequest =>
      $base.as((v, t, t2) => _AnalyzeRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AnalyzeRequestCopyWith<$R, $In extends AnalyzeRequest, $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources;
  $R call({Map<String, String>? sources});
  AnalyzeRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AnalyzeRequestCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, AnalyzeRequest, $Out>
    implements AnalyzeRequestCopyWith<$R, AnalyzeRequest, $Out> {
  _AnalyzeRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AnalyzeRequest> $mapper = AnalyzeRequestMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources => MapCopyWith(
        $value.sources,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(sources: v),
      );
  @override
  $R call({Map<String, String>? sources}) => $apply(FieldCopyWithData({if (sources != null) #sources: sources}));
  @override
  AnalyzeRequest $make(CopyWithData data) => AnalyzeRequest(data.get(#sources, or: $value.sources));

  @override
  AnalyzeRequestCopyWith<$R2, AnalyzeRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _AnalyzeRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FormatResponseMapper extends ClassMapperBase<FormatResponse> {
  FormatResponseMapper._();

  static FormatResponseMapper? _instance;
  static FormatResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FormatResponseMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FormatResponse';

  static String _$newString(FormatResponse v) => v.newString;
  static const Field<FormatResponse, String> _f$newString = Field(
    'newString',
    _$newString,
  );
  static int _$newOffset(FormatResponse v) => v.newOffset;
  static const Field<FormatResponse, int> _f$newOffset = Field(
    'newOffset',
    _$newOffset,
  );

  @override
  final MappableFields<FormatResponse> fields = const {
    #newString: _f$newString,
    #newOffset: _f$newOffset,
  };

  static FormatResponse _instantiate(DecodingData data) {
    return FormatResponse(data.dec(_f$newString), data.dec(_f$newOffset));
  }

  @override
  final Function instantiate = _instantiate;

  static FormatResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FormatResponse>(map);
  }

  static FormatResponse fromJson(String json) {
    return ensureInitialized().decodeJson<FormatResponse>(json);
  }
}

mixin FormatResponseMappable {
  String toJson() {
    return FormatResponseMapper.ensureInitialized().encodeJson<FormatResponse>(
      this as FormatResponse,
    );
  }

  Map<String, dynamic> toMap() {
    return FormatResponseMapper.ensureInitialized().encodeMap<FormatResponse>(
      this as FormatResponse,
    );
  }

  FormatResponseCopyWith<FormatResponse, FormatResponse, FormatResponse> get copyWith =>
      _FormatResponseCopyWithImpl<FormatResponse, FormatResponse>(
        this as FormatResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FormatResponseMapper.ensureInitialized().stringifyValue(
      this as FormatResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return FormatResponseMapper.ensureInitialized().equalsValue(
      this as FormatResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return FormatResponseMapper.ensureInitialized().hashValue(
      this as FormatResponse,
    );
  }
}

extension FormatResponseValueCopy<$R, $Out> on ObjectCopyWith<$R, FormatResponse, $Out> {
  FormatResponseCopyWith<$R, FormatResponse, $Out> get $asFormatResponse =>
      $base.as((v, t, t2) => _FormatResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FormatResponseCopyWith<$R, $In extends FormatResponse, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? newString, int? newOffset});
  FormatResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _FormatResponseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, FormatResponse, $Out>
    implements FormatResponseCopyWith<$R, FormatResponse, $Out> {
  _FormatResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FormatResponse> $mapper = FormatResponseMapper.ensureInitialized();
  @override
  $R call({String? newString, int? newOffset}) => $apply(
        FieldCopyWithData({
          if (newString != null) #newString: newString,
          if (newOffset != null) #newOffset: newOffset,
        }),
      );
  @override
  FormatResponse $make(CopyWithData data) => FormatResponse(
        data.get(#newString, or: $value.newString),
        data.get(#newOffset, or: $value.newOffset),
      );

  @override
  FormatResponseCopyWith<$R2, FormatResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _FormatResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class FormatRequestMapper extends ClassMapperBase<FormatRequest> {
  FormatRequestMapper._();

  static FormatRequestMapper? _instance;
  static FormatRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = FormatRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'FormatRequest';

  static String _$source(FormatRequest v) => v.source;
  static const Field<FormatRequest, String> _f$source = Field(
    'source',
    _$source,
  );
  static int _$offset(FormatRequest v) => v.offset;
  static const Field<FormatRequest, int> _f$offset = Field('offset', _$offset);

  @override
  final MappableFields<FormatRequest> fields = const {
    #source: _f$source,
    #offset: _f$offset,
  };

  static FormatRequest _instantiate(DecodingData data) {
    return FormatRequest(data.dec(_f$source), data.dec(_f$offset));
  }

  @override
  final Function instantiate = _instantiate;

  static FormatRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<FormatRequest>(map);
  }

  static FormatRequest fromJson(String json) {
    return ensureInitialized().decodeJson<FormatRequest>(json);
  }
}

mixin FormatRequestMappable {
  String toJson() {
    return FormatRequestMapper.ensureInitialized().encodeJson<FormatRequest>(
      this as FormatRequest,
    );
  }

  Map<String, dynamic> toMap() {
    return FormatRequestMapper.ensureInitialized().encodeMap<FormatRequest>(
      this as FormatRequest,
    );
  }

  FormatRequestCopyWith<FormatRequest, FormatRequest, FormatRequest> get copyWith =>
      _FormatRequestCopyWithImpl<FormatRequest, FormatRequest>(
        this as FormatRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return FormatRequestMapper.ensureInitialized().stringifyValue(
      this as FormatRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return FormatRequestMapper.ensureInitialized().equalsValue(
      this as FormatRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return FormatRequestMapper.ensureInitialized().hashValue(
      this as FormatRequest,
    );
  }
}

extension FormatRequestValueCopy<$R, $Out> on ObjectCopyWith<$R, FormatRequest, $Out> {
  FormatRequestCopyWith<$R, FormatRequest, $Out> get $asFormatRequest =>
      $base.as((v, t, t2) => _FormatRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class FormatRequestCopyWith<$R, $In extends FormatRequest, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? source, int? offset});
  FormatRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _FormatRequestCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, FormatRequest, $Out>
    implements FormatRequestCopyWith<$R, FormatRequest, $Out> {
  _FormatRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<FormatRequest> $mapper = FormatRequestMapper.ensureInitialized();
  @override
  $R call({String? source, int? offset}) => $apply(
        FieldCopyWithData({
          if (source != null) #source: source,
          if (offset != null) #offset: offset,
        }),
      );
  @override
  FormatRequest $make(CopyWithData data) => FormatRequest(
        data.get(#source, or: $value.source),
        data.get(#offset, or: $value.offset),
      );

  @override
  FormatRequestCopyWith<$R2, FormatRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _FormatRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class AnalyzeResponseMapper extends ClassMapperBase<AnalyzeResponse> {
  AnalyzeResponseMapper._();

  static AnalyzeResponseMapper? _instance;
  static AnalyzeResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = AnalyzeResponseMapper._());
      IssueMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'AnalyzeResponse';

  static List<Issue> _$issues(AnalyzeResponse v) => v.issues;
  static const Field<AnalyzeResponse, List<Issue>> _f$issues = Field(
    'issues',
    _$issues,
    opt: true,
    def: const [],
  );

  @override
  final MappableFields<AnalyzeResponse> fields = const {#issues: _f$issues};

  static AnalyzeResponse _instantiate(DecodingData data) {
    return AnalyzeResponse(data.dec(_f$issues));
  }

  @override
  final Function instantiate = _instantiate;

  static AnalyzeResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<AnalyzeResponse>(map);
  }

  static AnalyzeResponse fromJson(String json) {
    return ensureInitialized().decodeJson<AnalyzeResponse>(json);
  }
}

mixin AnalyzeResponseMappable {
  String toJson() {
    return AnalyzeResponseMapper.ensureInitialized().encodeJson<AnalyzeResponse>(this as AnalyzeResponse);
  }

  Map<String, dynamic> toMap() {
    return AnalyzeResponseMapper.ensureInitialized().encodeMap<AnalyzeResponse>(
      this as AnalyzeResponse,
    );
  }

  AnalyzeResponseCopyWith<AnalyzeResponse, AnalyzeResponse, AnalyzeResponse> get copyWith =>
      _AnalyzeResponseCopyWithImpl<AnalyzeResponse, AnalyzeResponse>(
        this as AnalyzeResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return AnalyzeResponseMapper.ensureInitialized().stringifyValue(
      this as AnalyzeResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return AnalyzeResponseMapper.ensureInitialized().equalsValue(
      this as AnalyzeResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return AnalyzeResponseMapper.ensureInitialized().hashValue(
      this as AnalyzeResponse,
    );
  }
}

extension AnalyzeResponseValueCopy<$R, $Out> on ObjectCopyWith<$R, AnalyzeResponse, $Out> {
  AnalyzeResponseCopyWith<$R, AnalyzeResponse, $Out> get $asAnalyzeResponse =>
      $base.as((v, t, t2) => _AnalyzeResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class AnalyzeResponseCopyWith<$R, $In extends AnalyzeResponse, $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Issue, IssueCopyWith<$R, Issue, Issue>> get issues;
  $R call({List<Issue>? issues});
  AnalyzeResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _AnalyzeResponseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, AnalyzeResponse, $Out>
    implements AnalyzeResponseCopyWith<$R, AnalyzeResponse, $Out> {
  _AnalyzeResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<AnalyzeResponse> $mapper = AnalyzeResponseMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Issue, IssueCopyWith<$R, Issue, Issue>> get issues => ListCopyWith(
        $value.issues,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(issues: v),
      );
  @override
  $R call({List<Issue>? issues}) => $apply(FieldCopyWithData({if (issues != null) #issues: issues}));
  @override
  AnalyzeResponse $make(CopyWithData data) => AnalyzeResponse(data.get(#issues, or: $value.issues));

  @override
  AnalyzeResponseCopyWith<$R2, AnalyzeResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _AnalyzeResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IssueMapper extends ClassMapperBase<Issue> {
  IssueMapper._();

  static IssueMapper? _instance;
  static IssueMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IssueMapper._());
      IssueKindMapper.ensureInitialized();
      IssueLocationMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Issue';

  static IssueKind _$kind(Issue v) => v.kind;
  static const Field<Issue, IssueKind> _f$kind = Field('kind', _$kind);
  static IssueLocation _$location(Issue v) => v.location;
  static const Field<Issue, IssueLocation> _f$location = Field(
    'location',
    _$location,
  );
  static String _$message(Issue v) => v.message;
  static const Field<Issue, String> _f$message = Field('message', _$message);
  static bool _$hasFixes(Issue v) => v.hasFixes;
  static const Field<Issue, bool> _f$hasFixes = Field('hasFixes', _$hasFixes);
  static String _$sourceName(Issue v) => v.sourceName;
  static const Field<Issue, String> _f$sourceName = Field(
    'sourceName',
    _$sourceName,
  );
  static String? _$correction(Issue v) => v.correction;
  static const Field<Issue, String> _f$correction = Field(
    'correction',
    _$correction,
    opt: true,
  );
  static String? _$url(Issue v) => v.url;
  static const Field<Issue, String> _f$url = Field('url', _$url, opt: true);

  @override
  final MappableFields<Issue> fields = const {
    #kind: _f$kind,
    #location: _f$location,
    #message: _f$message,
    #hasFixes: _f$hasFixes,
    #sourceName: _f$sourceName,
    #correction: _f$correction,
    #url: _f$url,
  };

  static Issue _instantiate(DecodingData data) {
    return Issue(
      kind: data.dec(_f$kind),
      location: data.dec(_f$location),
      message: data.dec(_f$message),
      hasFixes: data.dec(_f$hasFixes),
      sourceName: data.dec(_f$sourceName),
      correction: data.dec(_f$correction),
      url: data.dec(_f$url),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Issue fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Issue>(map);
  }

  static Issue fromJson(String json) {
    return ensureInitialized().decodeJson<Issue>(json);
  }
}

mixin IssueMappable {
  String toJson() {
    return IssueMapper.ensureInitialized().encodeJson<Issue>(this as Issue);
  }

  Map<String, dynamic> toMap() {
    return IssueMapper.ensureInitialized().encodeMap<Issue>(this as Issue);
  }

  IssueCopyWith<Issue, Issue, Issue> get copyWith =>
      _IssueCopyWithImpl<Issue, Issue>(this as Issue, $identity, $identity);
  @override
  String toString() {
    return IssueMapper.ensureInitialized().stringifyValue(this as Issue);
  }

  @override
  bool operator ==(Object other) {
    return IssueMapper.ensureInitialized().equalsValue(this as Issue, other);
  }

  @override
  int get hashCode {
    return IssueMapper.ensureInitialized().hashValue(this as Issue);
  }
}

extension IssueValueCopy<$R, $Out> on ObjectCopyWith<$R, Issue, $Out> {
  IssueCopyWith<$R, Issue, $Out> get $asIssue => $base.as((v, t, t2) => _IssueCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IssueCopyWith<$R, $In extends Issue, $Out> implements ClassCopyWith<$R, $In, $Out> {
  IssueLocationCopyWith<$R, IssueLocation, IssueLocation> get location;
  $R call({
    IssueKind? kind,
    IssueLocation? location,
    String? message,
    bool? hasFixes,
    String? sourceName,
    String? correction,
    String? url,
  });
  IssueCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IssueCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Issue, $Out>
    implements IssueCopyWith<$R, Issue, $Out> {
  _IssueCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Issue> $mapper = IssueMapper.ensureInitialized();
  @override
  IssueLocationCopyWith<$R, IssueLocation, IssueLocation> get location =>
      $value.location.copyWith.$chain((v) => call(location: v));
  @override
  $R call({
    IssueKind? kind,
    IssueLocation? location,
    String? message,
    bool? hasFixes,
    String? sourceName,
    Object? correction = $none,
    Object? url = $none,
  }) =>
      $apply(
        FieldCopyWithData({
          if (kind != null) #kind: kind,
          if (location != null) #location: location,
          if (message != null) #message: message,
          if (hasFixes != null) #hasFixes: hasFixes,
          if (sourceName != null) #sourceName: sourceName,
          if (correction != $none) #correction: correction,
          if (url != $none) #url: url,
        }),
      );
  @override
  Issue $make(CopyWithData data) => Issue(
        kind: data.get(#kind, or: $value.kind),
        location: data.get(#location, or: $value.location),
        message: data.get(#message, or: $value.message),
        hasFixes: data.get(#hasFixes, or: $value.hasFixes),
        sourceName: data.get(#sourceName, or: $value.sourceName),
        correction: data.get(#correction, or: $value.correction),
        url: data.get(#url, or: $value.url),
      );

  @override
  IssueCopyWith<$R2, Issue, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _IssueCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class IssueLocationMapper extends ClassMapperBase<IssueLocation> {
  IssueLocationMapper._();

  static IssueLocationMapper? _instance;
  static IssueLocationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IssueLocationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'IssueLocation';

  static int _$startLine(IssueLocation v) => v.startLine;
  static const Field<IssueLocation, int> _f$startLine = Field(
    'startLine',
    _$startLine,
  );
  static int _$endLine(IssueLocation v) => v.endLine;
  static const Field<IssueLocation, int> _f$endLine = Field(
    'endLine',
    _$endLine,
  );
  static int _$startColumn(IssueLocation v) => v.startColumn;
  static const Field<IssueLocation, int> _f$startColumn = Field(
    'startColumn',
    _$startColumn,
  );
  static int _$endColumn(IssueLocation v) => v.endColumn;
  static const Field<IssueLocation, int> _f$endColumn = Field(
    'endColumn',
    _$endColumn,
  );

  @override
  final MappableFields<IssueLocation> fields = const {
    #startLine: _f$startLine,
    #endLine: _f$endLine,
    #startColumn: _f$startColumn,
    #endColumn: _f$endColumn,
  };

  static IssueLocation _instantiate(DecodingData data) {
    return IssueLocation(
      startLine: data.dec(_f$startLine),
      endLine: data.dec(_f$endLine),
      startColumn: data.dec(_f$startColumn),
      endColumn: data.dec(_f$endColumn),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static IssueLocation fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IssueLocation>(map);
  }

  static IssueLocation fromJson(String json) {
    return ensureInitialized().decodeJson<IssueLocation>(json);
  }
}

mixin IssueLocationMappable {
  String toJson() {
    return IssueLocationMapper.ensureInitialized().encodeJson<IssueLocation>(
      this as IssueLocation,
    );
  }

  Map<String, dynamic> toMap() {
    return IssueLocationMapper.ensureInitialized().encodeMap<IssueLocation>(
      this as IssueLocation,
    );
  }

  IssueLocationCopyWith<IssueLocation, IssueLocation, IssueLocation> get copyWith =>
      _IssueLocationCopyWithImpl<IssueLocation, IssueLocation>(
        this as IssueLocation,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return IssueLocationMapper.ensureInitialized().stringifyValue(
      this as IssueLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    return IssueLocationMapper.ensureInitialized().equalsValue(
      this as IssueLocation,
      other,
    );
  }

  @override
  int get hashCode {
    return IssueLocationMapper.ensureInitialized().hashValue(
      this as IssueLocation,
    );
  }
}

extension IssueLocationValueCopy<$R, $Out> on ObjectCopyWith<$R, IssueLocation, $Out> {
  IssueLocationCopyWith<$R, IssueLocation, $Out> get $asIssueLocation =>
      $base.as((v, t, t2) => _IssueLocationCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class IssueLocationCopyWith<$R, $In extends IssueLocation, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({int? startLine, int? endLine, int? startColumn, int? endColumn});
  IssueLocationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _IssueLocationCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, IssueLocation, $Out>
    implements IssueLocationCopyWith<$R, IssueLocation, $Out> {
  _IssueLocationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IssueLocation> $mapper = IssueLocationMapper.ensureInitialized();
  @override
  $R call({int? startLine, int? endLine, int? startColumn, int? endColumn}) => $apply(
        FieldCopyWithData({
          if (startLine != null) #startLine: startLine,
          if (endLine != null) #endLine: endLine,
          if (startColumn != null) #startColumn: startColumn,
          if (endColumn != null) #endColumn: endColumn,
        }),
      );
  @override
  IssueLocation $make(CopyWithData data) => IssueLocation(
        startLine: data.get(#startLine, or: $value.startLine),
        endLine: data.get(#endLine, or: $value.endLine),
        startColumn: data.get(#startColumn, or: $value.startColumn),
        endColumn: data.get(#endColumn, or: $value.endColumn),
      );

  @override
  IssueLocationCopyWith<$R2, IssueLocation, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _IssueLocationCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DocumentResponseMapper extends ClassMapperBase<DocumentResponse> {
  DocumentResponseMapper._();

  static DocumentResponseMapper? _instance;
  static DocumentResponseMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentResponseMapper._());
      HoverInfoMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentResponse';

  static HoverInfo _$info(DocumentResponse v) => v.info;
  static const Field<DocumentResponse, HoverInfo> _f$info = Field(
    'info',
    _$info,
  );
  static String? _$error(DocumentResponse v) => v.error;
  static const Field<DocumentResponse, String> _f$error = Field(
    'error',
    _$error,
  );

  @override
  final MappableFields<DocumentResponse> fields = const {
    #info: _f$info,
    #error: _f$error,
  };

  static DocumentResponse _instantiate(DecodingData data) {
    return DocumentResponse(data.dec(_f$info), data.dec(_f$error));
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentResponse fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentResponse>(map);
  }

  static DocumentResponse fromJson(String json) {
    return ensureInitialized().decodeJson<DocumentResponse>(json);
  }
}

mixin DocumentResponseMappable {
  String toJson() {
    return DocumentResponseMapper.ensureInitialized().encodeJson<DocumentResponse>(this as DocumentResponse);
  }

  Map<String, dynamic> toMap() {
    return DocumentResponseMapper.ensureInitialized().encodeMap<DocumentResponse>(this as DocumentResponse);
  }

  DocumentResponseCopyWith<DocumentResponse, DocumentResponse, DocumentResponse> get copyWith =>
      _DocumentResponseCopyWithImpl<DocumentResponse, DocumentResponse>(
        this as DocumentResponse,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DocumentResponseMapper.ensureInitialized().stringifyValue(
      this as DocumentResponse,
    );
  }

  @override
  bool operator ==(Object other) {
    return DocumentResponseMapper.ensureInitialized().equalsValue(
      this as DocumentResponse,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentResponseMapper.ensureInitialized().hashValue(
      this as DocumentResponse,
    );
  }
}

extension DocumentResponseValueCopy<$R, $Out> on ObjectCopyWith<$R, DocumentResponse, $Out> {
  DocumentResponseCopyWith<$R, DocumentResponse, $Out> get $asDocumentResponse =>
      $base.as((v, t, t2) => _DocumentResponseCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DocumentResponseCopyWith<$R, $In extends DocumentResponse, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  HoverInfoCopyWith<$R, HoverInfo, HoverInfo> get info;
  $R call({HoverInfo? info, String? error});
  DocumentResponseCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DocumentResponseCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, DocumentResponse, $Out>
    implements DocumentResponseCopyWith<$R, DocumentResponse, $Out> {
  _DocumentResponseCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DocumentResponse> $mapper = DocumentResponseMapper.ensureInitialized();
  @override
  HoverInfoCopyWith<$R, HoverInfo, HoverInfo> get info => $value.info.copyWith.$chain((v) => call(info: v));
  @override
  $R call({HoverInfo? info, Object? error = $none}) => $apply(
        FieldCopyWithData({
          if (info != null) #info: info,
          if (error != $none) #error: error,
        }),
      );
  @override
  DocumentResponse $make(CopyWithData data) => DocumentResponse(
        data.get(#info, or: $value.info),
        data.get(#error, or: $value.error),
      );

  @override
  DocumentResponseCopyWith<$R2, DocumentResponse, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _DocumentResponseCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class HoverInfoMapper extends ClassMapperBase<HoverInfo> {
  HoverInfoMapper._();

  static HoverInfoMapper? _instance;
  static HoverInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HoverInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'HoverInfo';

  static String? _$description(HoverInfo v) => v.description;
  static const Field<HoverInfo, String> _f$description = Field(
    'description',
    _$description,
    opt: true,
  );
  static String? _$kind(HoverInfo v) => v.kind;
  static const Field<HoverInfo, String> _f$kind = Field(
    'kind',
    _$kind,
    opt: true,
  );
  static String? _$dartdoc(HoverInfo v) => v.dartdoc;
  static const Field<HoverInfo, String> _f$dartdoc = Field(
    'dartdoc',
    _$dartdoc,
    opt: true,
  );
  static String? _$enclosingClassName(HoverInfo v) => v.enclosingClassName;
  static const Field<HoverInfo, String> _f$enclosingClassName = Field(
    'enclosingClassName',
    _$enclosingClassName,
    opt: true,
  );
  static String? _$libraryName(HoverInfo v) => v.libraryName;
  static const Field<HoverInfo, String> _f$libraryName = Field(
    'libraryName',
    _$libraryName,
    opt: true,
  );
  static String? _$parameter(HoverInfo v) => v.parameter;
  static const Field<HoverInfo, String> _f$parameter = Field(
    'parameter',
    _$parameter,
    opt: true,
  );
  static bool? _$deprecated(HoverInfo v) => v.deprecated;
  static const Field<HoverInfo, bool> _f$deprecated = Field(
    'deprecated',
    _$deprecated,
    opt: true,
  );
  static String? _$staticType(HoverInfo v) => v.staticType;
  static const Field<HoverInfo, String> _f$staticType = Field(
    'staticType',
    _$staticType,
    opt: true,
  );
  static String? _$propagatedType(HoverInfo v) => v.propagatedType;
  static const Field<HoverInfo, String> _f$propagatedType = Field(
    'propagatedType',
    _$propagatedType,
    opt: true,
  );

  @override
  final MappableFields<HoverInfo> fields = const {
    #description: _f$description,
    #kind: _f$kind,
    #dartdoc: _f$dartdoc,
    #enclosingClassName: _f$enclosingClassName,
    #libraryName: _f$libraryName,
    #parameter: _f$parameter,
    #deprecated: _f$deprecated,
    #staticType: _f$staticType,
    #propagatedType: _f$propagatedType,
  };

  static HoverInfo _instantiate(DecodingData data) {
    return HoverInfo(
      description: data.dec(_f$description),
      kind: data.dec(_f$kind),
      dartdoc: data.dec(_f$dartdoc),
      enclosingClassName: data.dec(_f$enclosingClassName),
      libraryName: data.dec(_f$libraryName),
      parameter: data.dec(_f$parameter),
      deprecated: data.dec(_f$deprecated),
      staticType: data.dec(_f$staticType),
      propagatedType: data.dec(_f$propagatedType),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static HoverInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HoverInfo>(map);
  }

  static HoverInfo fromJson(String json) {
    return ensureInitialized().decodeJson<HoverInfo>(json);
  }
}

mixin HoverInfoMappable {
  String toJson() {
    return HoverInfoMapper.ensureInitialized().encodeJson<HoverInfo>(
      this as HoverInfo,
    );
  }

  Map<String, dynamic> toMap() {
    return HoverInfoMapper.ensureInitialized().encodeMap<HoverInfo>(
      this as HoverInfo,
    );
  }

  HoverInfoCopyWith<HoverInfo, HoverInfo, HoverInfo> get copyWith => _HoverInfoCopyWithImpl<HoverInfo, HoverInfo>(
        this as HoverInfo,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return HoverInfoMapper.ensureInitialized().stringifyValue(
      this as HoverInfo,
    );
  }

  @override
  bool operator ==(Object other) {
    return HoverInfoMapper.ensureInitialized().equalsValue(
      this as HoverInfo,
      other,
    );
  }

  @override
  int get hashCode {
    return HoverInfoMapper.ensureInitialized().hashValue(this as HoverInfo);
  }
}

extension HoverInfoValueCopy<$R, $Out> on ObjectCopyWith<$R, HoverInfo, $Out> {
  HoverInfoCopyWith<$R, HoverInfo, $Out> get $asHoverInfo =>
      $base.as((v, t, t2) => _HoverInfoCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class HoverInfoCopyWith<$R, $In extends HoverInfo, $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? description,
    String? kind,
    String? dartdoc,
    String? enclosingClassName,
    String? libraryName,
    String? parameter,
    bool? deprecated,
    String? staticType,
    String? propagatedType,
  });
  HoverInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HoverInfoCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, HoverInfo, $Out>
    implements HoverInfoCopyWith<$R, HoverInfo, $Out> {
  _HoverInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HoverInfo> $mapper = HoverInfoMapper.ensureInitialized();
  @override
  $R call({
    Object? description = $none,
    Object? kind = $none,
    Object? dartdoc = $none,
    Object? enclosingClassName = $none,
    Object? libraryName = $none,
    Object? parameter = $none,
    Object? deprecated = $none,
    Object? staticType = $none,
    Object? propagatedType = $none,
  }) =>
      $apply(
        FieldCopyWithData({
          if (description != $none) #description: description,
          if (kind != $none) #kind: kind,
          if (dartdoc != $none) #dartdoc: dartdoc,
          if (enclosingClassName != $none) #enclosingClassName: enclosingClassName,
          if (libraryName != $none) #libraryName: libraryName,
          if (parameter != $none) #parameter: parameter,
          if (deprecated != $none) #deprecated: deprecated,
          if (staticType != $none) #staticType: staticType,
          if (propagatedType != $none) #propagatedType: propagatedType,
        }),
      );
  @override
  HoverInfo $make(CopyWithData data) => HoverInfo(
        description: data.get(#description, or: $value.description),
        kind: data.get(#kind, or: $value.kind),
        dartdoc: data.get(#dartdoc, or: $value.dartdoc),
        enclosingClassName: data.get(
          #enclosingClassName,
          or: $value.enclosingClassName,
        ),
        libraryName: data.get(#libraryName, or: $value.libraryName),
        parameter: data.get(#parameter, or: $value.parameter),
        deprecated: data.get(#deprecated, or: $value.deprecated),
        staticType: data.get(#staticType, or: $value.staticType),
        propagatedType: data.get(#propagatedType, or: $value.propagatedType),
      );

  @override
  HoverInfoCopyWith<$R2, HoverInfo, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _HoverInfoCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class DocumentRequestMapper extends ClassMapperBase<DocumentRequest> {
  DocumentRequestMapper._();

  static DocumentRequestMapper? _instance;
  static DocumentRequestMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DocumentRequestMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'DocumentRequest';

  static Map<String, String> _$sources(DocumentRequest v) => v.sources;
  static const Field<DocumentRequest, Map<String, String>> _f$sources = Field(
    'sources',
    _$sources,
  );
  static String _$name(DocumentRequest v) => v.name;
  static const Field<DocumentRequest, String> _f$name = Field('name', _$name);
  static int _$offset(DocumentRequest v) => v.offset;
  static const Field<DocumentRequest, int> _f$offset = Field(
    'offset',
    _$offset,
  );

  @override
  final MappableFields<DocumentRequest> fields = const {
    #sources: _f$sources,
    #name: _f$name,
    #offset: _f$offset,
  };

  static DocumentRequest _instantiate(DecodingData data) {
    return DocumentRequest(
      data.dec(_f$sources),
      data.dec(_f$name),
      data.dec(_f$offset),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static DocumentRequest fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DocumentRequest>(map);
  }

  static DocumentRequest fromJson(String json) {
    return ensureInitialized().decodeJson<DocumentRequest>(json);
  }
}

mixin DocumentRequestMappable {
  String toJson() {
    return DocumentRequestMapper.ensureInitialized().encodeJson<DocumentRequest>(this as DocumentRequest);
  }

  Map<String, dynamic> toMap() {
    return DocumentRequestMapper.ensureInitialized().encodeMap<DocumentRequest>(
      this as DocumentRequest,
    );
  }

  DocumentRequestCopyWith<DocumentRequest, DocumentRequest, DocumentRequest> get copyWith =>
      _DocumentRequestCopyWithImpl<DocumentRequest, DocumentRequest>(
        this as DocumentRequest,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return DocumentRequestMapper.ensureInitialized().stringifyValue(
      this as DocumentRequest,
    );
  }

  @override
  bool operator ==(Object other) {
    return DocumentRequestMapper.ensureInitialized().equalsValue(
      this as DocumentRequest,
      other,
    );
  }

  @override
  int get hashCode {
    return DocumentRequestMapper.ensureInitialized().hashValue(
      this as DocumentRequest,
    );
  }
}

extension DocumentRequestValueCopy<$R, $Out> on ObjectCopyWith<$R, DocumentRequest, $Out> {
  DocumentRequestCopyWith<$R, DocumentRequest, $Out> get $asDocumentRequest =>
      $base.as((v, t, t2) => _DocumentRequestCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class DocumentRequestCopyWith<$R, $In extends DocumentRequest, $Out> implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources;
  $R call({Map<String, String>? sources, String? name, int? offset});
  DocumentRequestCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  );
}

class _DocumentRequestCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, DocumentRequest, $Out>
    implements DocumentRequestCopyWith<$R, DocumentRequest, $Out> {
  _DocumentRequestCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DocumentRequest> $mapper = DocumentRequestMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, String, ObjectCopyWith<$R, String, String>> get sources => MapCopyWith(
        $value.sources,
        (v, t) => ObjectCopyWith(v, $identity, t),
        (v) => call(sources: v),
      );
  @override
  $R call({Map<String, String>? sources, String? name, int? offset}) => $apply(
        FieldCopyWithData({
          if (sources != null) #sources: sources,
          if (name != null) #name: name,
          if (offset != null) #offset: offset,
        }),
      );
  @override
  DocumentRequest $make(CopyWithData data) => DocumentRequest(
        data.get(#sources, or: $value.sources),
        data.get(#name, or: $value.name),
        data.get(#offset, or: $value.offset),
      );

  @override
  DocumentRequestCopyWith<$R2, DocumentRequest, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) =>
      _DocumentRequestCopyWithImpl<$R2, $Out2>($value, $cast, t);
}
