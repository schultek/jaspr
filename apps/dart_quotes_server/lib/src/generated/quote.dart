/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_serialization/serverpod_serialization.dart';

abstract class Quote extends _i1.TableRow {
  Quote._({
    int? id,
    required this.quote,
    required this.author,
    required this.likes,
  }) : super(id);

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

  static final t = QuoteTable();

  static const db = QuoteRepository._();

  String quote;

  String author;

  List<int> likes;

  @override
  _i1.Table get table => t;

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
  @Deprecated('Will be removed in 2.0.0')
  Map<String, dynamic> toJsonForDatabase() {
    return {
      'id': id,
      'quote': quote,
      'author': author,
      'likes': likes,
    };
  }

  @override
  Map<String, dynamic> allToJson() {
    return {
      if (id != null) 'id': id,
      'quote': quote,
      'author': author,
      'likes': likes.toJson(),
    };
  }

  @override
  @Deprecated('Will be removed in 2.0.0')
  void setColumn(
    String columnName,
    value,
  ) {
    switch (columnName) {
      case 'id':
        id = value;
        return;
      case 'quote':
        quote = value;
        return;
      case 'author':
        author = value;
        return;
      case 'likes':
        likes = value;
        return;
      default:
        throw UnimplementedError();
    }
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.find instead.')
  static Future<List<Quote>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? limit,
    int? offset,
    _i1.Column? orderBy,
    List<_i1.Order>? orderByList,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Quote>(
      where: where != null ? where(Quote.t) : null,
      limit: limit,
      offset: offset,
      orderBy: orderBy,
      orderByList: orderByList,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findRow instead.')
  static Future<Quote?> findSingleRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? offset,
    _i1.Column? orderBy,
    bool orderDescending = false,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findSingleRow<Quote>(
      where: where != null ? where(Quote.t) : null,
      offset: offset,
      orderBy: orderBy,
      orderDescending: orderDescending,
      useCache: useCache,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.findById instead.')
  static Future<Quote?> findById(
    _i1.Session session,
    int id,
  ) async {
    return session.db.findById<Quote>(id);
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteWhere instead.')
  static Future<int> delete(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<QuoteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Quote>(
      where: where(Quote.t),
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.deleteRow instead.')
  static Future<bool> deleteRow(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow(
      row,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.update instead.')
  static Future<bool> update(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.update(
      row,
      transaction: transaction,
    );
  }

  @Deprecated(
      'Will be removed in 2.0.0. Use: db.insert instead. Important note: In db.insert, the object you pass in is no longer modified, instead a new copy with the added row is returned which contains the inserted id.')
  static Future<void> insert(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert(
      row,
      transaction: transaction,
    );
  }

  @Deprecated('Will be removed in 2.0.0. Use: db.count instead.')
  static Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? limit,
    bool useCache = true,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Quote>(
      where: where != null ? where(Quote.t) : null,
      limit: limit,
      useCache: useCache,
      transaction: transaction,
    );
  }

  static QuoteInclude include() {
    return QuoteInclude._();
  }

  static QuoteIncludeList includeList({
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<QuoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<QuoteTable>? orderByList,
    QuoteInclude? include,
  }) {
    return QuoteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Quote.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Quote.t),
      include: include,
    );
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

class QuoteTable extends _i1.Table {
  QuoteTable({super.tableRelation}) : super(tableName: 'quotes') {
    quote = _i1.ColumnString(
      'quote',
      this,
    );
    author = _i1.ColumnString(
      'author',
      this,
    );
    likes = _i1.ColumnSerializable(
      'likes',
      this,
    );
  }

  late final _i1.ColumnString quote;

  late final _i1.ColumnString author;

  late final _i1.ColumnSerializable likes;

  @override
  List<_i1.Column> get columns => [
        id,
        quote,
        author,
        likes,
      ];
}

@Deprecated('Use QuoteTable.t instead.')
QuoteTable tQuote = QuoteTable();

class QuoteInclude extends _i1.IncludeObject {
  QuoteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Quote.t;
}

class QuoteIncludeList extends _i1.IncludeList {
  QuoteIncludeList._({
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Quote.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Quote.t;
}

class QuoteRepository {
  const QuoteRepository._();

  Future<List<Quote>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<QuoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<QuoteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.find<Quote>(
      where: where?.call(Quote.t),
      orderBy: orderBy?.call(Quote.t),
      orderByList: orderByList?.call(Quote.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Quote?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? offset,
    _i1.OrderByBuilder<QuoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<QuoteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findFirstRow<Quote>(
      where: where?.call(Quote.t),
      orderBy: orderBy?.call(Quote.t),
      orderByList: orderByList?.call(Quote.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Quote?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.findById<Quote>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Quote>> insert(
    _i1.Session session,
    List<Quote> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insert<Quote>(
      rows,
      transaction: transaction,
    );
  }

  Future<Quote> insertRow(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.insertRow<Quote>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Quote>> update(
    _i1.Session session,
    List<Quote> rows, {
    _i1.ColumnSelections<QuoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.update<Quote>(
      rows,
      columns: columns?.call(Quote.t),
      transaction: transaction,
    );
  }

  Future<Quote> updateRow(
    _i1.Session session,
    Quote row, {
    _i1.ColumnSelections<QuoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.updateRow<Quote>(
      row,
      columns: columns?.call(Quote.t),
      transaction: transaction,
    );
  }

  Future<List<int>> delete(
    _i1.Session session,
    List<Quote> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.delete<Quote>(
      rows,
      transaction: transaction,
    );
  }

  Future<int> deleteRow(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteRow<Quote>(
      row,
      transaction: transaction,
    );
  }

  Future<List<int>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<QuoteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.deleteWhere<Quote>(
      where: where(Quote.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.dbNext.count<Quote>(
      where: where?.call(Quote.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
