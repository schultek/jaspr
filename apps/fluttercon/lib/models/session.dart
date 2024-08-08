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
  final List<({String name, List<({String name})> categoryItems})> categories;

  String get slug => '${title.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_')}_$id';

  String get format => categories.where((c) => c.name == "Session format").first.categoryItems.first.name;

  String get timeFormatted => DateFormat("EEE, dd MMM 'at' h:mm a").format(startsAt.toLocal());
  String get durationFormatted => '${endsAt.difference(startsAt).inMinutes}m';
}

extension type SessionCodex(Session session) implements Session {
  @decoder
  SessionCodex.decode(String json) : session = SessionMapper.fromJson(json);

  @encoder
  String encode() => session.toJson();
}
