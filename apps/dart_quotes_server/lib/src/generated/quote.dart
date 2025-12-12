/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:dart_quotes_server/src/generated/protocol.dart' as _i2;

abstract class Quote implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
    required List<String> likes,
  }) = _QuoteImpl;

  factory Quote.fromJson(Map<String, dynamic> jsonSerialization) {
    return Quote(
      id: jsonSerialization['id'] as int?,
      quote: jsonSerialization['quote'] as String,
      author: jsonSerialization['author'] as String,
      likes: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['likes'],
      ),
    );
  }

  static final t = QuoteTable();

  static const db = QuoteRepository._();

  @override
  int? id;

  String quote;

  String author;

  List<String> likes;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Quote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Quote copyWith({
    int? id,
    String? quote,
    String? author,
    List<String>? likes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Quote',
      if (id != null) 'id': id,
      'quote': quote,
      'author': author,
      'likes': likes.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Quote',
      if (id != null) 'id': id,
      'quote': quote,
      'author': author,
      'likes': likes.toJson(),
    };
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
    required List<String> likes,
  }) : super._(
         id: id,
         quote: quote,
         author: author,
         likes: likes,
       );

  /// Returns a shallow copy of this [Quote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Quote copyWith({
    Object? id = _Undefined,
    String? quote,
    String? author,
    List<String>? likes,
  }) {
    return Quote(
      id: id is int? ? id : this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      likes: likes ?? this.likes.map((e0) => e0).toList(),
    );
  }
}

class QuoteUpdateTable extends _i1.UpdateTable<QuoteTable> {
  QuoteUpdateTable(super.table);

  _i1.ColumnValue<String, String> quote(String value) => _i1.ColumnValue(
    table.quote,
    value,
  );

  _i1.ColumnValue<String, String> author(String value) => _i1.ColumnValue(
    table.author,
    value,
  );

  _i1.ColumnValue<List<String>, List<String>> likes(List<String> value) =>
      _i1.ColumnValue(
        table.likes,
        value,
      );
}

class QuoteTable extends _i1.Table<int?> {
  QuoteTable({super.tableRelation}) : super(tableName: 'quotes') {
    updateTable = QuoteUpdateTable(this);
    quote = _i1.ColumnString(
      'quote',
      this,
    );
    author = _i1.ColumnString(
      'author',
      this,
    );
    likes = _i1.ColumnSerializable<List<String>>(
      'likes',
      this,
    );
  }

  late final QuoteUpdateTable updateTable;

  late final _i1.ColumnString quote;

  late final _i1.ColumnString author;

  late final _i1.ColumnSerializable<List<String>> likes;

  @override
  List<_i1.Column> get columns => [
    id,
    quote,
    author,
    likes,
  ];
}

class QuoteInclude extends _i1.IncludeObject {
  QuoteInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Quote.t;
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
  _i1.Table<int?> get table => Quote.t;
}

class QuoteRepository {
  const QuoteRepository._();

  /// Returns a list of [Quote]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
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
    return session.db.find<Quote>(
      where: where?.call(Quote.t),
      orderBy: orderBy?.call(Quote.t),
      orderByList: orderByList?.call(Quote.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Quote] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<Quote?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? offset,
    _i1.OrderByBuilder<QuoteTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<QuoteTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Quote>(
      where: where?.call(Quote.t),
      orderBy: orderBy?.call(Quote.t),
      orderByList: orderByList?.call(Quote.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Quote] by its [id] or null if no such row exists.
  Future<Quote?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Quote>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Quote]s in the list and returns the inserted rows.
  ///
  /// The returned [Quote]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Quote>> insert(
    _i1.Session session,
    List<Quote> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Quote>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Quote] and returns the inserted row.
  ///
  /// The returned [Quote] will have its `id` field set.
  Future<Quote> insertRow(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Quote>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Quote]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Quote>> update(
    _i1.Session session,
    List<Quote> rows, {
    _i1.ColumnSelections<QuoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Quote>(
      rows,
      columns: columns?.call(Quote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Quote]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Quote> updateRow(
    _i1.Session session,
    Quote row, {
    _i1.ColumnSelections<QuoteTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Quote>(
      row,
      columns: columns?.call(Quote.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Quote] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Quote?> updateById(
    _i1.Session session,
    int id, {
    required _i1.ColumnValueListBuilder<QuoteUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<Quote>(
      id,
      columnValues: columnValues(Quote.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Quote]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<Quote>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<QuoteUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<QuoteTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<QuoteTable>? orderBy,
    _i1.OrderByListBuilder<QuoteTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<Quote>(
      columnValues: columnValues(Quote.t.updateTable),
      where: where(Quote.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Quote.t),
      orderByList: orderByList?.call(Quote.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [Quote]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Quote>> delete(
    _i1.Session session,
    List<Quote> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Quote>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Quote].
  Future<Quote> deleteRow(
    _i1.Session session,
    Quote row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Quote>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Quote>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<QuoteTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Quote>(
      where: where(Quote.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<QuoteTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Quote>(
      where: where?.call(Quote.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
