/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:photopush_server/src/generated/protocol.dart' as _ill3kfrr;
import 'package:serverpod/serverpod.dart' as _is;
import 'slide.dart' as _ia13r20e;

abstract class Album
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Album._({
    _is.UuidValue? id,
    required this.name,
    this.coverAssetId,
    this.slides,
    int? localRev,
    this.serverRev,
    this.serverSeq,
    required this.hlcWall,
    required this.hlcCounter,
    required this.deviceId,
    this.deletedAt,
    int? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _is.Uuid().v7obj(),
       localRev = localRev ?? 0,
       pinned = pinned ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Album({
    _is.UuidValue? id,
    required String name,
    _is.UuidValue? coverAssetId,
    List<_ia13r20e.Slide>? slides,
    int? localRev,
    int? serverRev,
    int? serverSeq,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    DateTime? deletedAt,
    int? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _AlbumImpl;

  factory Album.fromJson(Map<String, dynamic> jsonSerialization) {
    return Album(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      coverAssetId: jsonSerialization['coverAssetId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['coverAssetId'],
            ),
      slides: jsonSerialization['slides'] == null
          ? null
          : _ill3kfrr.Protocol().deserialize<List<_ia13r20e.Slide>>(
              jsonSerialization['slides'],
            ),
      localRev: jsonSerialization['localRev'] as int?,
      serverRev: jsonSerialization['serverRev'] as int?,
      serverSeq: jsonSerialization['serverSeq'] as int?,
      hlcWall: jsonSerialization['hlcWall'] as int,
      hlcCounter: jsonSerialization['hlcCounter'] as int,
      deviceId: jsonSerialization['deviceId'] as String,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      pinned: jsonSerialization['pinned'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = AlbumTable();

  static const db = AlbumRepository._();

  @override
  _is.UuidValue id;

  String name;

  _is.UuidValue? coverAssetId;

  List<_ia13r20e.Slide>? slides;

  int localRev;

  int? serverRev;

  int? serverSeq;

  int hlcWall;

  int hlcCounter;

  String deviceId;

  DateTime? deletedAt;

  int pinned;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [Album]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Album copyWith({
    _is.UuidValue? id,
    String? name,
    _is.UuidValue? coverAssetId,
    List<_ia13r20e.Slide>? slides,
    int? localRev,
    int? serverRev,
    int? serverSeq,
    int? hlcWall,
    int? hlcCounter,
    String? deviceId,
    DateTime? deletedAt,
    int? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Album',
      'id': id.toJson(),
      'name': name,
      if (coverAssetId != null) 'coverAssetId': coverAssetId?.toJson(),
      if (slides != null)
        'slides': slides?.toJson(valueToJson: (v) => v.toJson()),
      'localRev': localRev,
      if (serverRev != null) 'serverRev': serverRev,
      if (serverSeq != null) 'serverSeq': serverSeq,
      'hlcWall': hlcWall,
      'hlcCounter': hlcCounter,
      'deviceId': deviceId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      'pinned': pinned,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Album',
      'id': id.toJson(),
      'name': name,
      if (coverAssetId != null) 'coverAssetId': coverAssetId?.toJson(),
      if (slides != null)
        'slides': slides?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'localRev': localRev,
      if (serverRev != null) 'serverRev': serverRev,
      if (serverSeq != null) 'serverSeq': serverSeq,
      'hlcWall': hlcWall,
      'hlcCounter': hlcCounter,
      'deviceId': deviceId,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      'pinned': pinned,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static AlbumInclude include({_ia13r20e.SlideIncludeList? slides}) {
    return AlbumInclude._(slides: slides);
  }

  static AlbumIncludeList includeList({
    _is.WhereExpressionBuilder<AlbumTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AlbumTable>? orderBy,
    _is.OrderByListBuilder<AlbumTable>? orderByList,
    AlbumInclude? include,
  }) {
    return AlbumIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Album.t),
      orderByList: orderByList?.call(Album.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AlbumImpl extends Album {
  _AlbumImpl({
    _is.UuidValue? id,
    required String name,
    _is.UuidValue? coverAssetId,
    List<_ia13r20e.Slide>? slides,
    int? localRev,
    int? serverRev,
    int? serverSeq,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    DateTime? deletedAt,
    int? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         name: name,
         coverAssetId: coverAssetId,
         slides: slides,
         localRev: localRev,
         serverRev: serverRev,
         serverSeq: serverSeq,
         hlcWall: hlcWall,
         hlcCounter: hlcCounter,
         deviceId: deviceId,
         deletedAt: deletedAt,
         pinned: pinned,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Album]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Album copyWith({
    _is.UuidValue? id,
    String? name,
    Object? coverAssetId = _Undefined,
    Object? slides = _Undefined,
    int? localRev,
    Object? serverRev = _Undefined,
    Object? serverSeq = _Undefined,
    int? hlcWall,
    int? hlcCounter,
    String? deviceId,
    Object? deletedAt = _Undefined,
    int? pinned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Album(
      id: id ?? this.id,
      name: name ?? this.name,
      coverAssetId: coverAssetId is _is.UuidValue?
          ? coverAssetId
          : this.coverAssetId,
      slides: slides is List<_ia13r20e.Slide>?
          ? slides
          : this.slides?.map((e0) => e0.copyWith()).toList(),
      localRev: localRev ?? this.localRev,
      serverRev: serverRev is int? ? serverRev : this.serverRev,
      serverSeq: serverSeq is int? ? serverSeq : this.serverSeq,
      hlcWall: hlcWall ?? this.hlcWall,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      deviceId: deviceId ?? this.deviceId,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AlbumUpdateTable extends _is.UpdateTable<AlbumTable> {
  AlbumUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> coverAssetId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.coverAssetId,
    value,
  );

  _is.ColumnValue<int, int> localRev(int value) => _is.ColumnValue(
    table.localRev,
    value,
  );

  _is.ColumnValue<int, int> serverRev(int? value) => _is.ColumnValue(
    table.serverRev,
    value,
  );

  _is.ColumnValue<int, int> serverSeq(int? value) => _is.ColumnValue(
    table.serverSeq,
    value,
  );

  _is.ColumnValue<int, int> hlcWall(int value) => _is.ColumnValue(
    table.hlcWall,
    value,
  );

  _is.ColumnValue<int, int> hlcCounter(int value) => _is.ColumnValue(
    table.hlcCounter,
    value,
  );

  _is.ColumnValue<String, String> deviceId(String value) => _is.ColumnValue(
    table.deviceId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );

  _is.ColumnValue<int, int> pinned(int value) => _is.ColumnValue(
    table.pinned,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class AlbumTable extends _is.Table<_is.UuidValue> {
  AlbumTable({super.tableRelation}) : super(tableName: 'albums') {
    updateTable = AlbumUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    coverAssetId = _is.ColumnUuid(
      'coverAssetId',
      this,
    );
    localRev = _is.ColumnInt(
      'localRev',
      this,
      hasDefault: true,
    );
    serverRev = _is.ColumnInt(
      'serverRev',
      this,
    );
    serverSeq = _is.ColumnInt(
      'serverSeq',
      this,
    );
    hlcWall = _is.ColumnInt(
      'hlcWall',
      this,
    );
    hlcCounter = _is.ColumnInt(
      'hlcCounter',
      this,
    );
    deviceId = _is.ColumnString(
      'deviceId',
      this,
    );
    deletedAt = _is.ColumnDateTime(
      'deletedAt',
      this,
    );
    pinned = _is.ColumnInt(
      'pinned',
      this,
      hasDefault: true,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final AlbumUpdateTable updateTable;

  late final _is.ColumnString name;

  late final _is.ColumnUuid coverAssetId;

  _ia13r20e.SlideTable? ___slides;

  _is.ManyRelation<_ia13r20e.SlideTable>? _slides;

  late final _is.ColumnInt localRev;

  late final _is.ColumnInt serverRev;

  late final _is.ColumnInt serverSeq;

  late final _is.ColumnInt hlcWall;

  late final _is.ColumnInt hlcCounter;

  late final _is.ColumnString deviceId;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnInt pinned;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  _ia13r20e.SlideTable get __slides {
    if (___slides != null) return ___slides!;
    ___slides = _is.createRelationTable(
      relationFieldName: '__slides',
      field: Album.t.id,
      foreignField: _ia13r20e.Slide.t.$_albumsSlidesAlbumsId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ia13r20e.SlideTable(tableRelation: foreignTableRelation),
    );
    return ___slides!;
  }

  _is.ManyRelation<_ia13r20e.SlideTable> get slides {
    if (_slides != null) return _slides!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'slides',
      field: Album.t.id,
      foreignField: _ia13r20e.Slide.t.$_albumsSlidesAlbumsId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ia13r20e.SlideTable(tableRelation: foreignTableRelation),
    );
    _slides = _is.ManyRelation<_ia13r20e.SlideTable>(
      tableWithRelations: relationTable,
      table: _ia13r20e.SlideTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _slides!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    name,
    coverAssetId,
    localRev,
    serverRev,
    serverSeq,
    hlcWall,
    hlcCounter,
    deviceId,
    deletedAt,
    pinned,
    createdAt,
    updatedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'slides') {
      return __slides;
    }
    return null;
  }
}

class AlbumInclude extends _is.IncludeObject {
  AlbumInclude._({_ia13r20e.SlideIncludeList? slides}) {
    _slides = slides;
  }

  _ia13r20e.SlideIncludeList? _slides;

  @override
  Map<String, _is.Include?> get includes => {'slides': _slides};

  @override
  _is.Table<_is.UuidValue> get table => Album.t;
}

class AlbumIncludeList extends _is.IncludeList {
  AlbumIncludeList._({
    _is.WhereExpressionBuilder<AlbumTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Album.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Album.t;
}

class AlbumRepository {
  const AlbumRepository._();

  final attach = const AlbumAttachRepository._();

  final attachRow = const AlbumAttachRowRepository._();

  final detach = const AlbumDetachRepository._();

  final detachRow = const AlbumDetachRowRepository._();

  /// Returns a list of [Album]s matching the given query parameters.
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
  Future<List<Album>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AlbumTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AlbumTable>? orderBy,
    _is.OrderByListBuilder<AlbumTable>? orderByList,
    _is.Transaction? transaction,
    AlbumInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Album>(
      where: where?.call(Album.t),
      orderBy: orderBy?.call(Album.t),
      orderByList: orderByList?.call(Album.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Album] matching the given query parameters.
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
  Future<Album?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AlbumTable>? where,
    int? offset,
    _is.OrderByBuilder<AlbumTable>? orderBy,
    _is.OrderByListBuilder<AlbumTable>? orderByList,
    _is.Transaction? transaction,
    AlbumInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Album>(
      where: where?.call(Album.t),
      orderBy: orderBy?.call(Album.t),
      orderByList: orderByList?.call(Album.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Album] by its [id] or null if no such row exists.
  Future<Album?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    AlbumInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Album>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Album]s in the list and returns the inserted rows.
  ///
  /// The returned [Album]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Album>> insert(
    _is.DatabaseSession session,
    List<Album> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Album>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Album] and returns the inserted row.
  ///
  /// The returned [Album] will have its `id` field set.
  Future<Album> insertRow(
    _is.DatabaseSession session,
    Album row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Album>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Album]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [Album]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Album>> upsert(
    _is.DatabaseSession session,
    List<Album> rows, {
    required _is.ColumnSelections<AlbumTable> conflictColumns,
    _is.ColumnSelections<AlbumTable>? updateColumns,
    _is.WhereExpressionBuilder<AlbumTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Album>(
      rows,
      conflictColumns: conflictColumns(Album.t),
      updateColumns: updateColumns?.call(Album.t),
      updateWhere: updateWhere?.call(Album.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Album] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [Album] will have its `id` field set.
  Future<Album?> upsertRow(
    _is.DatabaseSession session,
    Album row, {
    required _is.ColumnSelections<AlbumTable> conflictColumns,
    _is.ColumnSelections<AlbumTable>? updateColumns,
    _is.WhereExpressionBuilder<AlbumTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Album>(
      row,
      conflictColumns: conflictColumns(Album.t),
      updateColumns: updateColumns?.call(Album.t),
      updateWhere: updateWhere?.call(Album.t),
      transaction: transaction,
    );
  }

  /// Updates all [Album]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Album>> update(
    _is.DatabaseSession session,
    List<Album> rows, {
    _is.ColumnSelections<AlbumTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Album>(
      rows,
      columns: columns?.call(Album.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Album]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Album> updateRow(
    _is.DatabaseSession session,
    Album row, {
    _is.ColumnSelections<AlbumTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Album>(
      row,
      columns: columns?.call(Album.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Album] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Album?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AlbumUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Album>(
      id,
      columnValues: columnValues(Album.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Album]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Album>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AlbumUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AlbumTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AlbumTable>? orderBy,
    _is.OrderByListBuilder<AlbumTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Album>(
      columnValues: columnValues(Album.t.updateTable),
      where: where(Album.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Album.t),
      orderByList: orderByList?.call(Album.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Album]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Album>> delete(
    _is.DatabaseSession session,
    List<Album> rows, {
    _is.OrderByBuilder<AlbumTable>? orderBy,
    _is.OrderByListBuilder<AlbumTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Album>(
      rows,
      orderBy: orderBy?.call(Album.t),
      orderByList: orderByList?.call(Album.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Album].
  Future<Album> deleteRow(
    _is.DatabaseSession session,
    Album row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Album>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Album>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AlbumTable> where,
    _is.OrderByBuilder<AlbumTable>? orderBy,
    _is.OrderByListBuilder<AlbumTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Album>(
      where: where(Album.t),
      orderBy: orderBy?.call(Album.t),
      orderByList: orderByList?.call(Album.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AlbumTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Album>(
      where: where?.call(Album.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Album] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AlbumTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Album>(
      where: where(Album.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class AlbumAttachRepository {
  const AlbumAttachRepository._();

  /// Creates a relation between this [Album] and the given [Slide]s
  /// by setting each [Slide]'s foreign key `_albumsSlidesAlbumsId` to refer to this [Album].
  Future<void> slides(
    _is.DatabaseSession session,
    Album album,
    List<_ia13r20e.Slide> slide, {
    _is.Transaction? transaction,
  }) async {
    if (slide.any((e) => e.id == null)) {
      throw ArgumentError.notNull('slide.id');
    }
    if (album.id == null) {
      throw ArgumentError.notNull('album.id');
    }

    var $slide = slide
        .map(
          (e) => _ia13r20e.SlideImplicit(
            e,
            $_albumsSlidesAlbumsId: album.id,
          ),
        )
        .toList();
    await session.db.update<_ia13r20e.Slide>(
      $slide,
      columns: [_ia13r20e.Slide.t.$_albumsSlidesAlbumsId],
      transaction: transaction,
    );
  }
}

class AlbumAttachRowRepository {
  const AlbumAttachRowRepository._();

  /// Creates a relation between this [Album] and the given [Slide]
  /// by setting the [Slide]'s foreign key `_albumsSlidesAlbumsId` to refer to this [Album].
  Future<void> slides(
    _is.DatabaseSession session,
    Album album,
    _ia13r20e.Slide slide, {
    _is.Transaction? transaction,
  }) async {
    if (slide.id == null) {
      throw ArgumentError.notNull('slide.id');
    }
    if (album.id == null) {
      throw ArgumentError.notNull('album.id');
    }

    var $slide = _ia13r20e.SlideImplicit(
      slide,
      $_albumsSlidesAlbumsId: album.id,
    );
    await session.db.updateRow<_ia13r20e.Slide>(
      $slide,
      columns: [_ia13r20e.Slide.t.$_albumsSlidesAlbumsId],
      transaction: transaction,
    );
  }
}

class AlbumDetachRepository {
  const AlbumDetachRepository._();

  /// Detaches the relation between this [Album] and the given [Slide]
  /// by setting the [Slide]'s foreign key `_albumsSlidesAlbumsId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> slides(
    _is.DatabaseSession session,
    List<_ia13r20e.Slide> slide, {
    _is.Transaction? transaction,
  }) async {
    if (slide.any((e) => e.id == null)) {
      throw ArgumentError.notNull('slide.id');
    }

    var $slide = slide
        .map(
          (e) => _ia13r20e.SlideImplicit(
            e,
            $_albumsSlidesAlbumsId: null,
          ),
        )
        .toList();
    await session.db.update<_ia13r20e.Slide>(
      $slide,
      columns: [_ia13r20e.Slide.t.$_albumsSlidesAlbumsId],
      transaction: transaction,
    );
  }
}

class AlbumDetachRowRepository {
  const AlbumDetachRowRepository._();

  /// Detaches the relation between this [Album] and the given [Slide]
  /// by setting the [Slide]'s foreign key `_albumsSlidesAlbumsId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> slides(
    _is.DatabaseSession session,
    _ia13r20e.Slide slide, {
    _is.Transaction? transaction,
  }) async {
    if (slide.id == null) {
      throw ArgumentError.notNull('slide.id');
    }

    var $slide = _ia13r20e.SlideImplicit(
      slide,
      $_albumsSlidesAlbumsId: null,
    );
    await session.db.updateRow<_ia13r20e.Slide>(
      $slide,
      columns: [_ia13r20e.Slide.t.$_albumsSlidesAlbumsId],
      transaction: transaction,
    );
  }
}
