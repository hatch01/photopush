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

abstract class Pin
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Pin._({
    _is.UuidValue? id,
    required this.slideId,
    required this.kind,
    required this.x,
    required this.y,
    double? sizeScale,
    String? color,
    this.text,
    this.targetSlideId,
    int? zIndex,
    required this.hlcWall,
    required this.hlcCounter,
    required this.deviceId,
    this.serverRev,
    this.deletedAt,
    DateTime? createdAt,
  }) : id = id ?? const _is.Uuid().v7obj(),
       sizeScale = sizeScale ?? 1.0,
       color = color ?? 'black',
       zIndex = zIndex ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       _slidesPinsSlidesId = null;

  factory Pin({
    _is.UuidValue? id,
    required _is.UuidValue slideId,
    required String kind,
    required double x,
    required double y,
    double? sizeScale,
    String? color,
    String? text,
    _is.UuidValue? targetSlideId,
    int? zIndex,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
  }) = _PinImpl;

  factory Pin.fromJson(Map<String, dynamic> jsonSerialization) {
    return PinImplicit._(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      slideId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['slideId'],
      ),
      kind: jsonSerialization['kind'] as String,
      x: (jsonSerialization['x'] as num).toDouble(),
      y: (jsonSerialization['y'] as num).toDouble(),
      sizeScale: (jsonSerialization['sizeScale'] as num?)?.toDouble(),
      color: jsonSerialization['color'] as String?,
      text: jsonSerialization['text'] as String?,
      targetSlideId: jsonSerialization['targetSlideId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['targetSlideId'],
            ),
      zIndex: jsonSerialization['zIndex'] as int?,
      hlcWall: jsonSerialization['hlcWall'] as int,
      hlcCounter: jsonSerialization['hlcCounter'] as int,
      deviceId: jsonSerialization['deviceId'] as String,
      serverRev: jsonSerialization['serverRev'] as int?,
      deletedAt: jsonSerialization['deletedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      $_slidesPinsSlidesId: jsonSerialization['_slidesPinsSlidesId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['_slidesPinsSlidesId'],
            ),
    );
  }

  static final t = PinTable();

  static const db = PinRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue slideId;

  String kind;

  double x;

  double y;

  double sizeScale;

  String color;

  String? text;

  _is.UuidValue? targetSlideId;

  int zIndex;

  int hlcWall;

  int hlcCounter;

  String deviceId;

  int? serverRev;

  DateTime? deletedAt;

  DateTime createdAt;

  final _is.UuidValue? _slidesPinsSlidesId;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [Pin]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Pin copyWith({
    _is.UuidValue? id,
    _is.UuidValue? slideId,
    String? kind,
    double? x,
    double? y,
    double? sizeScale,
    String? color,
    String? text,
    _is.UuidValue? targetSlideId,
    int? zIndex,
    int? hlcWall,
    int? hlcCounter,
    String? deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Pin',
      'id': id.toJson(),
      'slideId': slideId.toJson(),
      'kind': kind,
      'x': x,
      'y': y,
      'sizeScale': sizeScale,
      'color': color,
      if (text != null) 'text': text,
      if (targetSlideId != null) 'targetSlideId': targetSlideId?.toJson(),
      'zIndex': zIndex,
      'hlcWall': hlcWall,
      'hlcCounter': hlcCounter,
      'deviceId': deviceId,
      if (serverRev != null) 'serverRev': serverRev,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      if (_slidesPinsSlidesId != null)
        '_slidesPinsSlidesId': _slidesPinsSlidesId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Pin',
      'id': id.toJson(),
      'slideId': slideId.toJson(),
      'kind': kind,
      'x': x,
      'y': y,
      'sizeScale': sizeScale,
      'color': color,
      if (text != null) 'text': text,
      if (targetSlideId != null) 'targetSlideId': targetSlideId?.toJson(),
      'zIndex': zIndex,
      'hlcWall': hlcWall,
      'hlcCounter': hlcCounter,
      'deviceId': deviceId,
      if (serverRev != null) 'serverRev': serverRev,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static PinInclude include() {
    return PinInclude._();
  }

  static PinIncludeList includeList({
    _is.WhereExpressionBuilder<PinTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PinTable>? orderBy,
    _is.OrderByListBuilder<PinTable>? orderByList,
    PinInclude? include,
  }) {
    return PinIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Pin.t),
      orderByList: orderByList?.call(Pin.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PinImpl extends Pin {
  _PinImpl({
    _is.UuidValue? id,
    required _is.UuidValue slideId,
    required String kind,
    required double x,
    required double y,
    double? sizeScale,
    String? color,
    String? text,
    _is.UuidValue? targetSlideId,
    int? zIndex,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         slideId: slideId,
         kind: kind,
         x: x,
         y: y,
         sizeScale: sizeScale,
         color: color,
         text: text,
         targetSlideId: targetSlideId,
         zIndex: zIndex,
         hlcWall: hlcWall,
         hlcCounter: hlcCounter,
         deviceId: deviceId,
         serverRev: serverRev,
         deletedAt: deletedAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Pin]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Pin copyWith({
    _is.UuidValue? id,
    _is.UuidValue? slideId,
    String? kind,
    double? x,
    double? y,
    double? sizeScale,
    String? color,
    Object? text = _Undefined,
    Object? targetSlideId = _Undefined,
    int? zIndex,
    int? hlcWall,
    int? hlcCounter,
    String? deviceId,
    Object? serverRev = _Undefined,
    Object? deletedAt = _Undefined,
    DateTime? createdAt,
  }) {
    return PinImplicit._(
      id: id ?? this.id,
      slideId: slideId ?? this.slideId,
      kind: kind ?? this.kind,
      x: x ?? this.x,
      y: y ?? this.y,
      sizeScale: sizeScale ?? this.sizeScale,
      color: color ?? this.color,
      text: text is String? ? text : this.text,
      targetSlideId: targetSlideId is _is.UuidValue?
          ? targetSlideId
          : this.targetSlideId,
      zIndex: zIndex ?? this.zIndex,
      hlcWall: hlcWall ?? this.hlcWall,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      deviceId: deviceId ?? this.deviceId,
      serverRev: serverRev is int? ? serverRev : this.serverRev,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      $_slidesPinsSlidesId: this._slidesPinsSlidesId,
    );
  }
}

class PinImplicit extends _PinImpl {
  PinImplicit._({
    _is.UuidValue? id,
    required _is.UuidValue slideId,
    required String kind,
    required double x,
    required double y,
    double? sizeScale,
    String? color,
    String? text,
    _is.UuidValue? targetSlideId,
    int? zIndex,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
    _is.UuidValue? $_slidesPinsSlidesId,
  }) : _slidesPinsSlidesId = $_slidesPinsSlidesId,
       super(
         id: id,
         slideId: slideId,
         kind: kind,
         x: x,
         y: y,
         sizeScale: sizeScale,
         color: color,
         text: text,
         targetSlideId: targetSlideId,
         zIndex: zIndex,
         hlcWall: hlcWall,
         hlcCounter: hlcCounter,
         deviceId: deviceId,
         serverRev: serverRev,
         deletedAt: deletedAt,
         createdAt: createdAt,
       );

  factory PinImplicit(
    Pin pin, {
    _is.UuidValue? $_slidesPinsSlidesId,
  }) {
    return PinImplicit._(
      id: pin.id,
      slideId: pin.slideId,
      kind: pin.kind,
      x: pin.x,
      y: pin.y,
      sizeScale: pin.sizeScale,
      color: pin.color,
      text: pin.text,
      targetSlideId: pin.targetSlideId,
      zIndex: pin.zIndex,
      hlcWall: pin.hlcWall,
      hlcCounter: pin.hlcCounter,
      deviceId: pin.deviceId,
      serverRev: pin.serverRev,
      deletedAt: pin.deletedAt,
      createdAt: pin.createdAt,
      $_slidesPinsSlidesId: $_slidesPinsSlidesId,
    );
  }

  @override
  final _is.UuidValue? _slidesPinsSlidesId;
}

class PinUpdateTable extends _is.UpdateTable<PinTable> {
  PinUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> slideId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.slideId,
        value,
      );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<double, double> x(double value) => _is.ColumnValue(
    table.x,
    value,
  );

  _is.ColumnValue<double, double> y(double value) => _is.ColumnValue(
    table.y,
    value,
  );

  _is.ColumnValue<double, double> sizeScale(double value) => _is.ColumnValue(
    table.sizeScale,
    value,
  );

  _is.ColumnValue<String, String> color(String value) => _is.ColumnValue(
    table.color,
    value,
  );

  _is.ColumnValue<String, String> text(String? value) => _is.ColumnValue(
    table.text,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> targetSlideId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.targetSlideId,
    value,
  );

  _is.ColumnValue<int, int> zIndex(int value) => _is.ColumnValue(
    table.zIndex,
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

  _is.ColumnValue<int, int> serverRev(int? value) => _is.ColumnValue(
    table.serverRev,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _is.ColumnValue(
        table.deletedAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> $_slidesPinsSlidesId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.$_slidesPinsSlidesId,
    value,
  );
}

class PinTable extends _is.Table<_is.UuidValue> {
  PinTable({super.tableRelation}) : super(tableName: 'pins') {
    updateTable = PinUpdateTable(this);
    slideId = _is.ColumnUuid(
      'slideId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    x = _is.ColumnDouble(
      'x',
      this,
    );
    y = _is.ColumnDouble(
      'y',
      this,
    );
    sizeScale = _is.ColumnDouble(
      'sizeScale',
      this,
      hasDefault: true,
    );
    color = _is.ColumnString(
      'color',
      this,
      hasDefault: true,
    );
    text = _is.ColumnString(
      'text',
      this,
    );
    targetSlideId = _is.ColumnUuid(
      'targetSlideId',
      this,
    );
    zIndex = _is.ColumnInt(
      'zIndex',
      this,
      hasDefault: true,
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
    serverRev = _is.ColumnInt(
      'serverRev',
      this,
    );
    deletedAt = _is.ColumnDateTime(
      'deletedAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
    $_slidesPinsSlidesId = _is.ColumnUuid(
      '_slidesPinsSlidesId',
      this,
    );
  }

  late final PinUpdateTable updateTable;

  late final _is.ColumnUuid slideId;

  late final _is.ColumnString kind;

  late final _is.ColumnDouble x;

  late final _is.ColumnDouble y;

  late final _is.ColumnDouble sizeScale;

  late final _is.ColumnString color;

  late final _is.ColumnString text;

  late final _is.ColumnUuid targetSlideId;

  late final _is.ColumnInt zIndex;

  late final _is.ColumnInt hlcWall;

  late final _is.ColumnInt hlcCounter;

  late final _is.ColumnString deviceId;

  late final _is.ColumnInt serverRev;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnUuid $_slidesPinsSlidesId;

  @override
  List<_is.Column> get columns => [
    id,
    slideId,
    kind,
    x,
    y,
    sizeScale,
    color,
    text,
    targetSlideId,
    zIndex,
    hlcWall,
    hlcCounter,
    deviceId,
    serverRev,
    deletedAt,
    createdAt,
    $_slidesPinsSlidesId,
  ];

  @override
  List<_is.Column> get managedColumns => [
    id,
    slideId,
    kind,
    x,
    y,
    sizeScale,
    color,
    text,
    targetSlideId,
    zIndex,
    hlcWall,
    hlcCounter,
    deviceId,
    serverRev,
    deletedAt,
    createdAt,
  ];
}

class PinInclude extends _is.IncludeObject {
  PinInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue> get table => Pin.t;
}

class PinIncludeList extends _is.IncludeList {
  PinIncludeList._({
    _is.WhereExpressionBuilder<PinTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Pin.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Pin.t;
}

class PinRepository {
  const PinRepository._();

  /// Returns a list of [Pin]s matching the given query parameters.
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
  Future<List<Pin>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PinTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PinTable>? orderBy,
    _is.OrderByListBuilder<PinTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Pin>(
      where: where?.call(Pin.t),
      orderBy: orderBy?.call(Pin.t),
      orderByList: orderByList?.call(Pin.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Pin] matching the given query parameters.
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
  Future<Pin?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PinTable>? where,
    int? offset,
    _is.OrderByBuilder<PinTable>? orderBy,
    _is.OrderByListBuilder<PinTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Pin>(
      where: where?.call(Pin.t),
      orderBy: orderBy?.call(Pin.t),
      orderByList: orderByList?.call(Pin.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Pin] by its [id] or null if no such row exists.
  Future<Pin?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Pin>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Pin]s in the list and returns the inserted rows.
  ///
  /// The returned [Pin]s will have their `id` fields set.
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
  Future<List<Pin>> insert(
    _is.DatabaseSession session,
    List<Pin> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Pin>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Pin] and returns the inserted row.
  ///
  /// The returned [Pin] will have its `id` field set.
  Future<Pin> insertRow(
    _is.DatabaseSession session,
    Pin row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Pin>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Pin]s in the list and returns the resulting rows.
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
  /// The returned [Pin]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Pin>> upsert(
    _is.DatabaseSession session,
    List<Pin> rows, {
    required _is.ColumnSelections<PinTable> conflictColumns,
    _is.ColumnSelections<PinTable>? updateColumns,
    _is.WhereExpressionBuilder<PinTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Pin>(
      rows,
      conflictColumns: conflictColumns(Pin.t),
      updateColumns: updateColumns?.call(Pin.t),
      updateWhere: updateWhere?.call(Pin.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Pin] and returns the resulting row.
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
  /// The returned [Pin] will have its `id` field set.
  Future<Pin?> upsertRow(
    _is.DatabaseSession session,
    Pin row, {
    required _is.ColumnSelections<PinTable> conflictColumns,
    _is.ColumnSelections<PinTable>? updateColumns,
    _is.WhereExpressionBuilder<PinTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Pin>(
      row,
      conflictColumns: conflictColumns(Pin.t),
      updateColumns: updateColumns?.call(Pin.t),
      updateWhere: updateWhere?.call(Pin.t),
      transaction: transaction,
    );
  }

  /// Updates all [Pin]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Pin>> update(
    _is.DatabaseSession session,
    List<Pin> rows, {
    _is.ColumnSelections<PinTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Pin>(
      rows,
      columns: columns?.call(Pin.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Pin]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Pin> updateRow(
    _is.DatabaseSession session,
    Pin row, {
    _is.ColumnSelections<PinTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Pin>(
      row,
      columns: columns?.call(Pin.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Pin] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Pin?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<PinUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Pin>(
      id,
      columnValues: columnValues(Pin.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Pin]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Pin>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<PinUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<PinTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<PinTable>? orderBy,
    _is.OrderByListBuilder<PinTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Pin>(
      columnValues: columnValues(Pin.t.updateTable),
      where: where(Pin.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Pin.t),
      orderByList: orderByList?.call(Pin.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Pin]s in the list and returns the deleted rows.
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
  Future<List<Pin>> delete(
    _is.DatabaseSession session,
    List<Pin> rows, {
    _is.OrderByBuilder<PinTable>? orderBy,
    _is.OrderByListBuilder<PinTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Pin>(
      rows,
      orderBy: orderBy?.call(Pin.t),
      orderByList: orderByList?.call(Pin.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Pin].
  Future<Pin> deleteRow(
    _is.DatabaseSession session,
    Pin row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Pin>(
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
  Future<List<Pin>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PinTable> where,
    _is.OrderByBuilder<PinTable>? orderBy,
    _is.OrderByListBuilder<PinTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Pin>(
      where: where(Pin.t),
      orderBy: orderBy?.call(Pin.t),
      orderByList: orderByList?.call(Pin.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<PinTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Pin>(
      where: where?.call(Pin.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Pin] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<PinTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Pin>(
      where: where(Pin.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
