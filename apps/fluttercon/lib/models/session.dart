import 'dart:convert';

import 'package:dart_mappable/dart_mappable.dart';
import 'package:intl/intl.dart';
import 'package:jaspr/jaspr.dart';

part 'session.mapper.dart';

@MappableClass()
class Session with SessionMappable {
  Session({
    required this.title,
    required this.id,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.speakers,
    required this.room,
    required this.categories,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime endsAt;
  final List<({String name})> speakers;
  final String room;
  final List<Category> categories;

  String get slug => '${title.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')}_$id';

  String get format => categories.where((c) => c.name == "Session format").first.categoryItems.first.name;

  Duration get duration => endsAt.difference(startsAt);

  String get timeFormatted => DateFormat("EEE, dd MMM 'at' h:mm a").format(startsAt.toLocal());
  String get durationFormatted => '${duration.inMinutes}m';

  @decoder
  static Session fromJson(String json) => SessionMapper.fromJson(json);

  @encoder
  @override
  String toJson() => super.toJson();
}

typedef Category = ({String name, List<({String name})> categoryItems});

abstract class SimpleCodec<S, T> with Codec<S, T> {
  const SimpleCodec();

  @override
  Converter<T, S> get decoder => SimpleConverter(decode);

  @override
  Converter<S, T> get encoder => SimpleConverter(encode);
}

class MappableCodec<T> extends SimpleCodec<T, String> {
  const MappableCodec();
}
