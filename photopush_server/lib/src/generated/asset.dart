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
import 'package:serverpod/serverpod.dart' as _is;

abstract class Asset
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Asset._({
    _is.UuidValue? id,
    required this.sha256,
    this.localPath,
    this.remoteUrl,
    required this.mimeType,
    required this.byteSize,
    this.width,
    this.height,
    this.capturedAt,
    this.originalName,
    required this.syncState,
    DateTime? createdAt,
  }) : id = id ?? const _is.Uuid().v7obj(),
       createdAt = createdAt ?? DateTime.now();

  factory Asset({
    _is.UuidValue? id,
    required String sha256,
    String? localPath,
    String? remoteUrl,
    required String mimeType,
    required int byteSize,
    int? width,
    int? height,
    DateTime? capturedAt,
    String? originalName,
    required String syncState,
    DateTime? createdAt,
  }) = _AssetImpl;

  factory Asset.fromJson(Map<String, dynamic> jsonSerialization) {
    return Asset(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      sha256: jsonSerialization['sha256'] as String,
      localPath: jsonSerialization['localPath'] as String?,
      remoteUrl: jsonSerialization['remoteUrl'] as String?,
      mimeType: jsonSerialization['mimeType'] as String,
      byteSize: jsonSerialization['byteSize'] as int,
      width: jsonSerialization['width'] as int?,
      height: jsonSerialization['height'] as int?,
      capturedAt: jsonSerialization['capturedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['capturedAt']),
      originalName: jsonSerialization['originalName'] as String?,
      syncState: jsonSerialization['syncState'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = AssetTable();

  static const db = AssetRepository._();

  @override
  _is.UuidValue id;

  String sha256;

  String? localPath;

  String? remoteUrl;

  String mimeType;

  int byteSize;

  int? width;

  int? height;

  DateTime? capturedAt;

  String? originalName;

  String syncState;

  DateTime createdAt;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Asset copyWith({
    _is.UuidValue? id,
    String? sha256,
    String? localPath,
    String? remoteUrl,
    String? mimeType,
    int? byteSize,
    int? width,
    int? height,
    DateTime? capturedAt,
    String? originalName,
    String? syncState,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Asset',
      'id': id.toJson(),
      'sha256': sha256,
      if (localPath != null) 'localPath': localPath,
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      'mimeType': mimeType,
      'byteSize': byteSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (capturedAt != null) 'capturedAt': capturedAt?.toJson(),
      if (originalName != null) 'originalName': originalName,
      'syncState': syncState,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Asset',
      'id': id.toJson(),
      'sha256': sha256,
      if (localPath != null) 'localPath': localPath,
      if (remoteUrl != null) 'remoteUrl': remoteUrl,
      'mimeType': mimeType,
      'byteSize': byteSize,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (capturedAt != null) 'capturedAt': capturedAt?.toJson(),
      if (originalName != null) 'originalName': originalName,
      'syncState': syncState,
      'createdAt': createdAt.toJson(),
    };
  }

  static AssetInclude include() {
    return AssetInclude._();
  }

  static AssetIncludeList includeList({
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    AssetInclude? include,
  }) {
    return AssetIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetImpl extends Asset {
  _AssetImpl({
    _is.UuidValue? id,
    required String sha256,
    String? localPath,
    String? remoteUrl,
    required String mimeType,
    required int byteSize,
    int? width,
    int? height,
    DateTime? capturedAt,
    String? originalName,
    required String syncState,
    DateTime? createdAt,
  }) : super._(
         id: id,
         sha256: sha256,
         localPath: localPath,
         remoteUrl: remoteUrl,
         mimeType: mimeType,
         byteSize: byteSize,
         width: width,
         height: height,
         capturedAt: capturedAt,
         originalName: originalName,
         syncState: syncState,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Asset]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Asset copyWith({
    _is.UuidValue? id,
    String? sha256,
    Object? localPath = _Undefined,
    Object? remoteUrl = _Undefined,
    String? mimeType,
    int? byteSize,
    Object? width = _Undefined,
    Object? height = _Undefined,
    Object? capturedAt = _Undefined,
    Object? originalName = _Undefined,
    String? syncState,
    DateTime? createdAt,
  }) {
    return Asset(
      id: id ?? this.id,
      sha256: sha256 ?? this.sha256,
      localPath: localPath is String? ? localPath : this.localPath,
      remoteUrl: remoteUrl is String? ? remoteUrl : this.remoteUrl,
      mimeType: mimeType ?? this.mimeType,
      byteSize: byteSize ?? this.byteSize,
      width: width is int? ? width : this.width,
      height: height is int? ? height : this.height,
      capturedAt: capturedAt is DateTime? ? capturedAt : this.capturedAt,
      originalName: originalName is String? ? originalName : this.originalName,
      syncState: syncState ?? this.syncState,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AssetUpdateTable extends _is.UpdateTable<AssetTable> {
  AssetUpdateTable(super.table);

  _is.ColumnValue<String, String> sha256(String value) => _is.ColumnValue(
    table.sha256,
    value,
  );

  _is.ColumnValue<String, String> localPath(String? value) => _is.ColumnValue(
    table.localPath,
    value,
  );

  _is.ColumnValue<String, String> remoteUrl(String? value) => _is.ColumnValue(
    table.remoteUrl,
    value,
  );

  _is.ColumnValue<String, String> mimeType(String value) => _is.ColumnValue(
    table.mimeType,
    value,
  );

  _is.ColumnValue<int, int> byteSize(int value) => _is.ColumnValue(
    table.byteSize,
    value,
  );

  _is.ColumnValue<int, int> width(int? value) => _is.ColumnValue(
    table.width,
    value,
  );

  _is.ColumnValue<int, int> height(int? value) => _is.ColumnValue(
    table.height,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> capturedAt(DateTime? value) =>
      _is.ColumnValue(
        table.capturedAt,
        value,
      );

  _is.ColumnValue<String, String> originalName(String? value) =>
      _is.ColumnValue(
        table.originalName,
        value,
      );

  _is.ColumnValue<String, String> syncState(String value) => _is.ColumnValue(
    table.syncState,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class AssetTable extends _is.Table<_is.UuidValue> {
  AssetTable({super.tableRelation}) : super(tableName: 'assets') {
    updateTable = AssetUpdateTable(this);
    sha256 = _is.ColumnString(
      'sha256',
      this,
    );
    localPath = _is.ColumnString(
      'localPath',
      this,
    );
    remoteUrl = _is.ColumnString(
      'remoteUrl',
      this,
    );
    mimeType = _is.ColumnString(
      'mimeType',
      this,
    );
    byteSize = _is.ColumnInt(
      'byteSize',
      this,
    );
    width = _is.ColumnInt(
      'width',
      this,
    );
    height = _is.ColumnInt(
      'height',
      this,
    );
    capturedAt = _is.ColumnDateTime(
      'capturedAt',
      this,
    );
    originalName = _is.ColumnString(
      'originalName',
      this,
    );
    syncState = _is.ColumnString(
      'syncState',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final AssetUpdateTable updateTable;

  late final _is.ColumnString sha256;

  late final _is.ColumnString localPath;

  late final _is.ColumnString remoteUrl;

  late final _is.ColumnString mimeType;

  late final _is.ColumnInt byteSize;

  late final _is.ColumnInt width;

  late final _is.ColumnInt height;

  late final _is.ColumnDateTime capturedAt;

  late final _is.ColumnString originalName;

  late final _is.ColumnString syncState;

  late final _is.ColumnDateTime createdAt;

  @override
  List<_is.Column> get columns => [
    id,
    sha256,
    localPath,
    remoteUrl,
    mimeType,
    byteSize,
    width,
    height,
    capturedAt,
    originalName,
    syncState,
    createdAt,
  ];
}

class AssetInclude extends _is.IncludeObject {
  AssetInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Asset.t;
}

class AssetIncludeList extends _is.IncludeList {
  AssetIncludeList._({
    _is.WhereExpressionBuilder<AssetTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Asset.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Asset.t;
}

class AssetRepository {
  const AssetRepository._();

  /// Returns a list of [Asset]s matching the given query parameters.
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
  Future<List<Asset>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Asset>(
      where: where?.call(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Asset] matching the given query parameters.
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
  Future<Asset?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Asset>(
      where: where?.call(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Asset] by its [id] or null if no such row exists.
  Future<Asset?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Asset>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Asset]s in the list and returns the inserted rows.
  ///
  /// The returned [Asset]s will have their `id` fields set.
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
  Future<List<Asset>> insert(
    _is.DatabaseSession session,
    List<Asset> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Asset>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Asset] and returns the inserted row.
  ///
  /// The returned [Asset] will have its `id` field set.
  Future<Asset> insertRow(
    _is.DatabaseSession session,
    Asset row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Asset>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Asset]s in the list and returns the resulting rows.
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
  /// The returned [Asset]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Asset>> upsert(
    _is.DatabaseSession session,
    List<Asset> rows, {
    required _is.ColumnSelections<AssetTable> conflictColumns,
    _is.ColumnSelections<AssetTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Asset>(
      rows,
      conflictColumns: conflictColumns(Asset.t),
      updateColumns: updateColumns?.call(Asset.t),
      updateWhere: updateWhere?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Asset] and returns the resulting row.
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
  /// The returned [Asset] will have its `id` field set.
  Future<Asset?> upsertRow(
    _is.DatabaseSession session,
    Asset row, {
    required _is.ColumnSelections<AssetTable> conflictColumns,
    _is.ColumnSelections<AssetTable>? updateColumns,
    _is.WhereExpressionBuilder<AssetTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Asset>(
      row,
      conflictColumns: conflictColumns(Asset.t),
      updateColumns: updateColumns?.call(Asset.t),
      updateWhere: updateWhere?.call(Asset.t),
      transaction: transaction,
    );
  }

  /// Updates all [Asset]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Asset>> update(
    _is.DatabaseSession session,
    List<Asset> rows, {
    _is.ColumnSelections<AssetTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Asset>(
      rows,
      columns: columns?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Asset]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Asset> updateRow(
    _is.DatabaseSession session,
    Asset row, {
    _is.ColumnSelections<AssetTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Asset>(
      row,
      columns: columns?.call(Asset.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Asset] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Asset?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<AssetUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Asset>(
      id,
      columnValues: columnValues(Asset.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Asset]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Asset>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<AssetUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<AssetTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Asset>(
      columnValues: columnValues(Asset.t.updateTable),
      where: where(Asset.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Asset]s in the list and returns the deleted rows.
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
  Future<List<Asset>> delete(
    _is.DatabaseSession session,
    List<Asset> rows, {
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Asset>(
      rows,
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Asset].
  Future<Asset> deleteRow(
    _is.DatabaseSession session,
    Asset row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Asset>(
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
  Future<List<Asset>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetTable> where,
    _is.OrderByBuilder<AssetTable>? orderBy,
    _is.OrderByListBuilder<AssetTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Asset>(
      where: where(Asset.t),
      orderBy: orderBy?.call(Asset.t),
      orderByList: orderByList?.call(Asset.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<AssetTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Asset>(
      where: where?.call(Asset.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Asset] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<AssetTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Asset>(
      where: where(Asset.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
