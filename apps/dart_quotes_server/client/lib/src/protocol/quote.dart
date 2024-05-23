/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Quote extends _i1.SerializableEntity {
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

  factory Quote.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return Quote(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      quote:
          serializationManager.deserialize<String>(jsonSerialization['quote']),
      author:
          serializationManager.deserialize<String>(jsonSerialization['author']),
      likes: serializationManager
          .deserialize<List<int>>(jsonSerialization['likes']),
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
      likes: likes ?? this.likes.clone(),
    );
  }
}
