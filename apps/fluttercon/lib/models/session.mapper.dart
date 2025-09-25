// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'session.dart';

class SessionMapper extends ClassMapperBase<Session> {
  SessionMapper._();

  static SessionMapper? _instance;
  static SessionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = SessionMapper._());
      _t$_R0Mapper.ensureInitialized();
      _t$_R1Mapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Session';

  static String _$title(Session v) => v.title;
  static const Field<Session, String> _f$title = Field('title', _$title);
  static String _$id(Session v) => v.id;
  static const Field<Session, String> _f$id = Field('id', _$id);
  static String _$description(Session v) => v.description;
  static const Field<Session, String> _f$description = Field('description', _$description);
  static DateTime _$startsAt(Session v) => v.startsAt;
  static const Field<Session, DateTime> _f$startsAt = Field('startsAt', _$startsAt);
  static DateTime _$endsAt(Session v) => v.endsAt;
  static const Field<Session, DateTime> _f$endsAt = Field('endsAt', _$endsAt);
  static List<_t$_R0<String>> _$speakers(Session v) => v.speakers;
  static const Field<Session, List<_t$_R0<String>>> _f$speakers = Field('speakers', _$speakers);
  static String _$room(Session v) => v.room;
  static const Field<Session, String> _f$room = Field('room', _$room);
  static List<_t$_R1<List<_t$_R0<String>>, String>> _$categories(Session v) => v.categories;
  static const Field<Session, List<_t$_R1<List<_t$_R0<String>>, String>>> _f$categories = Field(
    'categories',
    _$categories,
  );

  @override
  final MappableFields<Session> fields = const {
    #title: _f$title,
    #id: _f$id,
    #description: _f$description,
    #startsAt: _f$startsAt,
    #endsAt: _f$endsAt,
    #speakers: _f$speakers,
    #room: _f$room,
    #categories: _f$categories,
  };

  static Session _instantiate(DecodingData data) {
    return Session(
      title: data.dec(_f$title),
      id: data.dec(_f$id),
      description: data.dec(_f$description),
      startsAt: data.dec(_f$startsAt),
      endsAt: data.dec(_f$endsAt),
      speakers: data.dec(_f$speakers),
      room: data.dec(_f$room),
      categories: data.dec(_f$categories),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Session fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Session>(map);
  }

  static Session fromJson(String json) {
    return ensureInitialized().decodeJson<Session>(json);
  }
}

mixin SessionMappable {
  String toJson() {
    return SessionMapper.ensureInitialized().encodeJson<Session>(this as Session);
  }

  Map<String, dynamic> toMap() {
    return SessionMapper.ensureInitialized().encodeMap<Session>(this as Session);
  }

  SessionCopyWith<Session, Session, Session> get copyWith =>
      _SessionCopyWithImpl(this as Session, $identity, $identity);
  @override
  String toString() {
    return SessionMapper.ensureInitialized().stringifyValue(this as Session);
  }

  @override
  bool operator ==(Object other) {
    return SessionMapper.ensureInitialized().equalsValue(this as Session, other);
  }

  @override
  int get hashCode {
    return SessionMapper.ensureInitialized().hashValue(this as Session);
  }
}

extension SessionValueCopy<$R, $Out> on ObjectCopyWith<$R, Session, $Out> {
  SessionCopyWith<$R, Session, $Out> get $asSession => $base.as((v, t, t2) => _SessionCopyWithImpl(v, t, t2));
}

abstract class SessionCopyWith<$R, $In extends Session, $Out> implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, _t$_R0<String>, ObjectCopyWith<$R, _t$_R0<String>, _t$_R0<String>>> get speakers;
  ListCopyWith<
    $R,
    _t$_R1<List<_t$_R0<String>>, String>,
    ObjectCopyWith<$R, _t$_R1<List<_t$_R0<String>>, String>, _t$_R1<List<_t$_R0<String>>, String>>
  >
  get categories;
  $R call({
    String? title,
    String? id,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    List<_t$_R0<String>>? speakers,
    String? room,
    List<_t$_R1<List<_t$_R0<String>>, String>>? categories,
  });
  SessionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _SessionCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Session, $Out>
    implements SessionCopyWith<$R, Session, $Out> {
  _SessionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Session> $mapper = SessionMapper.ensureInitialized();
  @override
  ListCopyWith<$R, _t$_R0<String>, ObjectCopyWith<$R, _t$_R0<String>, _t$_R0<String>>> get speakers =>
      ListCopyWith($value.speakers, (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(speakers: v));
  @override
  ListCopyWith<
    $R,
    _t$_R1<List<_t$_R0<String>>, String>,
    ObjectCopyWith<$R, _t$_R1<List<_t$_R0<String>>, String>, _t$_R1<List<_t$_R0<String>>, String>>
  >
  get categories =>
      ListCopyWith($value.categories, (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(categories: v));
  @override
  $R call({
    String? title,
    String? id,
    String? description,
    DateTime? startsAt,
    DateTime? endsAt,
    List<_t$_R0<String>>? speakers,
    String? room,
    List<_t$_R1<List<_t$_R0<String>>, String>>? categories,
  }) => $apply(
    FieldCopyWithData({
      if (title != null) #title: title,
      if (id != null) #id: id,
      if (description != null) #description: description,
      if (startsAt != null) #startsAt: startsAt,
      if (endsAt != null) #endsAt: endsAt,
      if (speakers != null) #speakers: speakers,
      if (room != null) #room: room,
      if (categories != null) #categories: categories,
    }),
  );
  @override
  Session $make(CopyWithData data) => Session(
    title: data.get(#title, or: $value.title),
    id: data.get(#id, or: $value.id),
    description: data.get(#description, or: $value.description),
    startsAt: data.get(#startsAt, or: $value.startsAt),
    endsAt: data.get(#endsAt, or: $value.endsAt),
    speakers: data.get(#speakers, or: $value.speakers),
    room: data.get(#room, or: $value.room),
    categories: data.get(#categories, or: $value.categories),
  );

  @override
  SessionCopyWith<$R2, Session, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) => _SessionCopyWithImpl($value, $cast, t);
}

typedef _t$_R1<A, B> = ({A categoryItems, B name});

class _t$_R1Mapper extends RecordMapperBase<_t$_R1> {
  static _t$_R1Mapper? _instance;
  _t$_R1Mapper._();

  static _t$_R1Mapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = _t$_R1Mapper._());
      MapperBase.addType(<A, B>(f) => f<({A categoryItems, B name})>());
    }
    return _instance!;
  }

  static dynamic _$categoryItems(_t$_R1 v) => v.categoryItems;
  static dynamic _arg$categoryItems<A, B>(f) => f<A>();
  static const Field<_t$_R1, dynamic> _f$categoryItems = Field(
    'categoryItems',
    _$categoryItems,
    arg: _arg$categoryItems,
  );
  static dynamic _$name(_t$_R1 v) => v.name;
  static dynamic _arg$name<A, B>(f) => f<B>();
  static const Field<_t$_R1, dynamic> _f$name = Field('name', _$name, arg: _arg$name);

  @override
  final MappableFields<_t$_R1> fields = const {#categoryItems: _f$categoryItems, #name: _f$name};

  @override
  Function get typeFactory =>
      <A, B>(f) => f<_t$_R1<A, B>>();

  static _t$_R1<A, B> _instantiate<A, B>(DecodingData<_t$_R1> data) {
    return (categoryItems: data.dec(_f$categoryItems), name: data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static _t$_R1<A, B> fromMap<A, B>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<_t$_R1<A, B>>(map);
  }

  static _t$_R1<A, B> fromJson<A, B>(String json) {
    return ensureInitialized().decodeJson<_t$_R1<A, B>>(json);
  }
}

typedef _t$_R0<A> = ({A name});

class _t$_R0Mapper extends RecordMapperBase<_t$_R0> {
  static _t$_R0Mapper? _instance;
  _t$_R0Mapper._();

  static _t$_R0Mapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = _t$_R0Mapper._());
      MapperBase.addType(<A>(f) => f<({A name})>());
    }
    return _instance!;
  }

  static dynamic _$name(_t$_R0 v) => v.name;
  static dynamic _arg$name<A>(f) => f<A>();
  static const Field<_t$_R0, dynamic> _f$name = Field('name', _$name, arg: _arg$name);

  @override
  final MappableFields<_t$_R0> fields = const {#name: _f$name};

  @override
  Function get typeFactory =>
      <A>(f) => f<_t$_R0<A>>();

  static _t$_R0<A> _instantiate<A>(DecodingData<_t$_R0> data) {
    return (name: data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static _t$_R0<A> fromMap<A>(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<_t$_R0<A>>(map);
  }

  static _t$_R0<A> fromJson<A>(String json) {
    return ensureInitialized().decodeJson<_t$_R0<A>>(json);
  }
}
