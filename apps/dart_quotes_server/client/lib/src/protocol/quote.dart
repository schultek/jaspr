/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Quote implements _i1.SerializableModel {
  Quote._({
    this.id,
    required this.quote,
    required this.author,
    required this.likes,
  });

  factory Quote({
    int? id,
    required String quote,
    required String author,
    required List<int> likes,
  }) = _QuoteImpl;

  factory Quote.fromJson(Map<String, dynamic> jsonSerialization) {
    return Quote(
      id: jsonSerialization['id'] as int?,
      quote: jsonSerialization['quote'] as String,
      author: jsonSerialization['author'] as String,
      likes: (jsonSerialization['likes'] as List).map((e) => e as int).toList(),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String quote;

  String author;

  List<int> likes;

  Quote copyWith({
    int? id,
    String? quote,
    String? author,
    List<int>? likes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'quote': quote,
      'author': author,
      'likes': likes.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _QuoteImpl extends Quote {
  _QuoteImpl({
    int? id,
    required String quote,
    required String author,
    required List<int> likes,
  }) : super._(
          id: id,
          quote: quote,
          author: author,
          likes: likes,
        );

  @override
  Quote copyWith({
    Object? id = _Undefined,
    String? quote,
    String? author,
    List<int>? likes,
  }) {
    return Quote(
      id: id is int? ? id : this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      likes: likes ?? this.likes.map((e0) => e0).toList(),
    );
  }
}
