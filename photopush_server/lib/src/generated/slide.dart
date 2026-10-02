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
import 'pin.dart' as _iw6bx03f;

abstract class Slide
    implements _is.TableRow<_is.UuidValue>, _is.ProtocolSerialization {
  Slide._({
    _is.UuidValue? id,
    required this.albumId,
    required this.kind,
    String? title,
    this.commentText,
    this.assetId,
    this.pins,
    required this.orderKey,
    int? zPinCounter,
    int? dirty,
    required this.hlcWall,
    required this.hlcCounter,
    required this.deviceId,
    this.serverRev,
    this.deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : id = id ?? const _is.Uuid().v7obj(),
       title = title ?? '',
       zPinCounter = zPinCounter ?? 0,
       dirty = dirty ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       _albumsSlidesAlbumsId = null;

  factory Slide({
    _is.UuidValue? id,
    required _is.UuidValue albumId,
    required String kind,
    String? title,
    String? commentText,
    _is.UuidValue? assetId,
    List<_iw6bx03f.Pin>? pins,
    required String orderKey,
    int? zPinCounter,
    int? dirty,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SlideImpl;

  factory Slide.fromJson(Map<String, dynamic> jsonSerialization) {
    return SlideImplicit._(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      albumId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['albumId'],
      ),
      kind: jsonSerialization['kind'] as String,
      title: jsonSerialization['title'] as String?,
      commentText: jsonSerialization['commentText'] as String?,
      assetId: jsonSerialization['assetId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['assetId']),
      pins: jsonSerialization['pins'] == null
          ? null
          : _ill3kfrr.Protocol().deserialize<List<_iw6bx03f.Pin>>(
              jsonSerialization['pins'],
            ),
      orderKey: jsonSerialization['orderKey'] as String,
      zPinCounter: jsonSerialization['zPinCounter'] as int?,
      dirty: jsonSerialization['dirty'] as int?,
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
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      $_albumsSlidesAlbumsId: jsonSerialization['_albumsSlidesAlbumsId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['_albumsSlidesAlbumsId'],
            ),
    );
  }

  static final t = SlideTable();

  static const db = SlideRepository._();

  @override
  _is.UuidValue id;

  _is.UuidValue albumId;

  String kind;

  String title;

  String? commentText;

  _is.UuidValue? assetId;

  List<_iw6bx03f.Pin>? pins;

  String orderKey;

  int zPinCounter;

  int dirty;

  int hlcWall;

  int hlcCounter;

  String deviceId;

  int? serverRev;

  DateTime? deletedAt;

  DateTime createdAt;

  DateTime updatedAt;

  final _is.UuidValue? _albumsSlidesAlbumsId;

  @override
  _is.Table<_is.UuidValue> get table => t;

  /// Returns a shallow copy of this [Slide]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Slide copyWith({
    _is.UuidValue? id,
    _is.UuidValue? albumId,
    String? kind,
    String? title,
    String? commentText,
    _is.UuidValue? assetId,
    List<_iw6bx03f.Pin>? pins,
    String? orderKey,
    int? zPinCounter,
    int? dirty,
    int? hlcWall,
    int? hlcCounter,
    String? deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Slide',
      'id': id.toJson(),
      'albumId': albumId.toJson(),
      'kind': kind,
      'title': title,
      if (commentText != null) 'commentText': commentText,
      if (assetId != null) 'assetId': assetId?.toJson(),
      if (pins != null) 'pins': pins?.toJson(valueToJson: (v) => v.toJson()),
      'orderKey': orderKey,
      'zPinCounter': zPinCounter,
      'dirty': dirty,
      'hlcWall': hlcWall,
      'hlcCounter': hlcCounter,
      'deviceId': deviceId,
      if (serverRev != null) 'serverRev': serverRev,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (_albumsSlidesAlbumsId != null)
        '_albumsSlidesAlbumsId': _albumsSlidesAlbumsId.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Slide',
      'id': id.toJson(),
      'albumId': albumId.toJson(),
      'kind': kind,
      'title': title,
      if (commentText != null) 'commentText': commentText,
      if (assetId != null) 'assetId': assetId?.toJson(),
      if (pins != null)
        'pins': pins?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'orderKey': orderKey,
      'zPinCounter': zPinCounter,
      'dirty': dirty,
      'hlcWall': hlcWall,
      'hlcCounter': hlcCounter,
      'deviceId': deviceId,
      if (serverRev != null) 'serverRev': serverRev,
      if (deletedAt != null) 'deletedAt': deletedAt?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static SlideInclude include({_iw6bx03f.PinIncludeList? pins}) {
    return SlideInclude._(pins: pins);
  }

  static SlideIncludeList includeList({
    _is.WhereExpressionBuilder<SlideTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SlideTable>? orderBy,
    _is.OrderByListBuilder<SlideTable>? orderByList,
    SlideInclude? include,
  }) {
    return SlideIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Slide.t),
      orderByList: orderByList?.call(Slide.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SlideImpl extends Slide {
  _SlideImpl({
    _is.UuidValue? id,
    required _is.UuidValue albumId,
    required String kind,
    String? title,
    String? commentText,
    _is.UuidValue? assetId,
    List<_iw6bx03f.Pin>? pins,
    required String orderKey,
    int? zPinCounter,
    int? dirty,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         albumId: albumId,
         kind: kind,
         title: title,
         commentText: commentText,
         assetId: assetId,
         pins: pins,
         orderKey: orderKey,
         zPinCounter: zPinCounter,
         dirty: dirty,
         hlcWall: hlcWall,
         hlcCounter: hlcCounter,
         deviceId: deviceId,
         serverRev: serverRev,
         deletedAt: deletedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Slide]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Slide copyWith({
    _is.UuidValue? id,
    _is.UuidValue? albumId,
    String? kind,
    String? title,
    Object? commentText = _Undefined,
    Object? assetId = _Undefined,
    Object? pins = _Undefined,
    String? orderKey,
    int? zPinCounter,
    int? dirty,
    int? hlcWall,
    int? hlcCounter,
    String? deviceId,
    Object? serverRev = _Undefined,
    Object? deletedAt = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SlideImplicit._(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      commentText: commentText is String? ? commentText : this.commentText,
      assetId: assetId is _is.UuidValue? ? assetId : this.assetId,
      pins: pins is List<_iw6bx03f.Pin>?
          ? pins
          : this.pins?.map((e0) => e0.copyWith()).toList(),
      orderKey: orderKey ?? this.orderKey,
      zPinCounter: zPinCounter ?? this.zPinCounter,
      dirty: dirty ?? this.dirty,
      hlcWall: hlcWall ?? this.hlcWall,
      hlcCounter: hlcCounter ?? this.hlcCounter,
      deviceId: deviceId ?? this.deviceId,
      serverRev: serverRev is int? ? serverRev : this.serverRev,
      deletedAt: deletedAt is DateTime? ? deletedAt : this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      $_albumsSlidesAlbumsId: this._albumsSlidesAlbumsId,
    );
  }
}

class SlideImplicit extends _SlideImpl {
  SlideImplicit._({
    _is.UuidValue? id,
    required _is.UuidValue albumId,
    required String kind,
    String? title,
    String? commentText,
    _is.UuidValue? assetId,
    List<_iw6bx03f.Pin>? pins,
    required String orderKey,
    int? zPinCounter,
    int? dirty,
    required int hlcWall,
    required int hlcCounter,
    required String deviceId,
    int? serverRev,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    _is.UuidValue? $_albumsSlidesAlbumsId,
  }) : _albumsSlidesAlbumsId = $_albumsSlidesAlbumsId,
       super(
         id: id,
         albumId: albumId,
         kind: kind,
         title: title,
         commentText: commentText,
         assetId: assetId,
         pins: pins,
         orderKey: orderKey,
         zPinCounter: zPinCounter,
         dirty: dirty,
         hlcWall: hlcWall,
         hlcCounter: hlcCounter,
         deviceId: deviceId,
         serverRev: serverRev,
         deletedAt: deletedAt,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory SlideImplicit(
    Slide slide, {
    _is.UuidValue? $_albumsSlidesAlbumsId,
  }) {
    return SlideImplicit._(
      id: slide.id,
      albumId: slide.albumId,
      kind: slide.kind,
      title: slide.title,
      commentText: slide.commentText,
      assetId: slide.assetId,
      pins: slide.pins,
      orderKey: slide.orderKey,
      zPinCounter: slide.zPinCounter,
      dirty: slide.dirty,
      hlcWall: slide.hlcWall,
      hlcCounter: slide.hlcCounter,
      deviceId: slide.deviceId,
      serverRev: slide.serverRev,
      deletedAt: slide.deletedAt,
      createdAt: slide.createdAt,
      updatedAt: slide.updatedAt,
      $_albumsSlidesAlbumsId: $_albumsSlidesAlbumsId,
    );
  }

  @override
  final _is.UuidValue? _albumsSlidesAlbumsId;
}

class SlideUpdateTable extends _is.UpdateTable<SlideTable> {
  SlideUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> albumId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.albumId,
        value,
      );

  _is.ColumnValue<String, String> kind(String value) => _is.ColumnValue(
    table.kind,
    value,
  );

  _is.ColumnValue<String, String> title(String value) => _is.ColumnValue(
    table.title,
    value,
  );

  _is.ColumnValue<String, String> commentText(String? value) => _is.ColumnValue(
    table.commentText,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> assetId(_is.UuidValue? value) =>
      _is.ColumnValue(
        table.assetId,
        value,
      );

  _is.ColumnValue<String, String> orderKey(String value) => _is.ColumnValue(
    table.orderKey,
    value,
  );

  _is.ColumnValue<int, int> zPinCounter(int value) => _is.ColumnValue(
    table.zPinCounter,
    value,
  );

  _is.ColumnValue<int, int> dirty(int value) => _is.ColumnValue(
    table.dirty,
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

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> $_albumsSlidesAlbumsId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.$_albumsSlidesAlbumsId,
    value,
  );
}

class SlideTable extends _is.Table<_is.UuidValue> {
  SlideTable({super.tableRelation}) : super(tableName: 'slides') {
    updateTable = SlideUpdateTable(this);
    albumId = _is.ColumnUuid(
      'albumId',
      this,
    );
    kind = _is.ColumnString(
      'kind',
      this,
    );
    title = _is.ColumnString(
      'title',
      this,
      hasDefault: true,
    );
    commentText = _is.ColumnString(
      'commentText',
      this,
    );
    assetId = _is.ColumnUuid(
      'assetId',
      this,
    );
    orderKey = _is.ColumnString(
      'orderKey',
      this,
    );
    zPinCounter = _is.ColumnInt(
      'zPinCounter',
      this,
      hasDefault: true,
    );
    dirty = _is.ColumnInt(
      'dirty',
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
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
    );
    $_albumsSlidesAlbumsId = _is.ColumnUuid(
      '_albumsSlidesAlbumsId',
      this,
    );
  }

  late final SlideUpdateTable updateTable;

  late final _is.ColumnUuid albumId;

  late final _is.ColumnString kind;

  late final _is.ColumnString title;

  late final _is.ColumnString commentText;

  late final _is.ColumnUuid assetId;

  _iw6bx03f.PinTable? ___pins;

  _is.ManyRelation<_iw6bx03f.PinTable>? _pins;

  late final _is.ColumnString orderKey;

  late final _is.ColumnInt zPinCounter;

  late final _is.ColumnInt dirty;

  late final _is.ColumnInt hlcWall;

  late final _is.ColumnInt hlcCounter;

  late final _is.ColumnString deviceId;

  late final _is.ColumnInt serverRev;

  late final _is.ColumnDateTime deletedAt;

  late final _is.ColumnDateTime createdAt;

  late final _is.ColumnDateTime updatedAt;

  late final _is.ColumnUuid $_albumsSlidesAlbumsId;

  _iw6bx03f.PinTable get __pins {
    if (___pins != null) return ___pins!;
    ___pins = _is.createRelationTable(
      relationFieldName: '__pins',
      field: Slide.t.id,
      foreignField: _iw6bx03f.Pin.t.$_slidesPinsSlidesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iw6bx03f.PinTable(tableRelation: foreignTableRelation),
    );
    return ___pins!;
  }

  _is.ManyRelation<_iw6bx03f.PinTable> get pins {
    if (_pins != null) return _pins!;
    var relationTable = _is.createRelationTable(
      relationFieldName: 'pins',
      field: Slide.t.id,
      foreignField: _iw6bx03f.Pin.t.$_slidesPinsSlidesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iw6bx03f.PinTable(tableRelation: foreignTableRelation),
    );
    _pins = _is.ManyRelation<_iw6bx03f.PinTable>(
      tableWithRelations: relationTable,
      table: _iw6bx03f.PinTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _pins!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    albumId,
    kind,
    title,
    commentText,
    assetId,
    orderKey,
    zPinCounter,
    dirty,
    hlcWall,
    hlcCounter,
    deviceId,
    serverRev,
    deletedAt,
    createdAt,
    updatedAt,
    $_albumsSlidesAlbumsId,
  ];

  @override
  List<_is.Column> get managedColumns => [
    id,
    albumId,
    kind,
    title,
    commentText,
    assetId,
    orderKey,
    zPinCounter,
    dirty,
    hlcWall,
    hlcCounter,
    deviceId,
    serverRev,
    deletedAt,
    createdAt,
    updatedAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'pins') {
      return __pins;
    }
    return null;
  }
}

class SlideInclude extends _is.IncludeObject {
  SlideInclude._({_iw6bx03f.PinIncludeList? pins}) {
    _pins = pins;
  }

  _iw6bx03f.PinIncludeList? _pins;

  @override
  Map<String, _is.Include?> get includes => {'pins': _pins};

  @override
  _is.Table<_is.UuidValue> get table => Slide.t;
}

class SlideIncludeList extends _is.IncludeList {
  SlideIncludeList._({
    _is.WhereExpressionBuilder<SlideTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Slide.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue> get table => Slide.t;
}

class SlideRepository {
  const SlideRepository._();

  final attach = const SlideAttachRepository._();

  final attachRow = const SlideAttachRowRepository._();

  final detach = const SlideDetachRepository._();

  final detachRow = const SlideDetachRowRepository._();

  /// Returns a list of [Slide]s matching the given query parameters.
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
  Future<List<Slide>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SlideTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SlideTable>? orderBy,
    _is.OrderByListBuilder<SlideTable>? orderByList,
    _is.Transaction? transaction,
    SlideInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Slide>(
      where: where?.call(Slide.t),
      orderBy: orderBy?.call(Slide.t),
      orderByList: orderByList?.call(Slide.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Slide] matching the given query parameters.
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
  Future<Slide?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SlideTable>? where,
    int? offset,
    _is.OrderByBuilder<SlideTable>? orderBy,
    _is.OrderByListBuilder<SlideTable>? orderByList,
    _is.Transaction? transaction,
    SlideInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Slide>(
      where: where?.call(Slide.t),
      orderBy: orderBy?.call(Slide.t),
      orderByList: orderByList?.call(Slide.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Slide] by its [id] or null if no such row exists.
  Future<Slide?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    SlideInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Slide>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Slide]s in the list and returns the inserted rows.
  ///
  /// The returned [Slide]s will have their `id` fields set.
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
  Future<List<Slide>> insert(
    _is.DatabaseSession session,
    List<Slide> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Slide>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Slide] and returns the inserted row.
  ///
  /// The returned [Slide] will have its `id` field set.
  Future<Slide> insertRow(
    _is.DatabaseSession session,
    Slide row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Slide>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Slide]s in the list and returns the resulting rows.
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
  /// The returned [Slide]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Slide>> upsert(
    _is.DatabaseSession session,
    List<Slide> rows, {
    required _is.ColumnSelections<SlideTable> conflictColumns,
    _is.ColumnSelections<SlideTable>? updateColumns,
    _is.WhereExpressionBuilder<SlideTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Slide>(
      rows,
      conflictColumns: conflictColumns(Slide.t),
      updateColumns: updateColumns?.call(Slide.t),
      updateWhere: updateWhere?.call(Slide.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Slide] and returns the resulting row.
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
  /// The returned [Slide] will have its `id` field set.
  Future<Slide?> upsertRow(
    _is.DatabaseSession session,
    Slide row, {
    required _is.ColumnSelections<SlideTable> conflictColumns,
    _is.ColumnSelections<SlideTable>? updateColumns,
    _is.WhereExpressionBuilder<SlideTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Slide>(
      row,
      conflictColumns: conflictColumns(Slide.t),
      updateColumns: updateColumns?.call(Slide.t),
      updateWhere: updateWhere?.call(Slide.t),
      transaction: transaction,
    );
  }

  /// Updates all [Slide]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Slide>> update(
    _is.DatabaseSession session,
    List<Slide> rows, {
    _is.ColumnSelections<SlideTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Slide>(
      rows,
      columns: columns?.call(Slide.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Slide]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Slide> updateRow(
    _is.DatabaseSession session,
    Slide row, {
    _is.ColumnSelections<SlideTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Slide>(
      row,
      columns: columns?.call(Slide.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Slide] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Slide?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SlideUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Slide>(
      id,
      columnValues: columnValues(Slide.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Slide]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Slide>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SlideUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SlideTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SlideTable>? orderBy,
    _is.OrderByListBuilder<SlideTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Slide>(
      columnValues: columnValues(Slide.t.updateTable),
      where: where(Slide.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Slide.t),
      orderByList: orderByList?.call(Slide.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Slide]s in the list and returns the deleted rows.
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
  Future<List<Slide>> delete(
    _is.DatabaseSession session,
    List<Slide> rows, {
    _is.OrderByBuilder<SlideTable>? orderBy,
    _is.OrderByListBuilder<SlideTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Slide>(
      rows,
      orderBy: orderBy?.call(Slide.t),
      orderByList: orderByList?.call(Slide.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Slide].
  Future<Slide> deleteRow(
    _is.DatabaseSession session,
    Slide row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Slide>(
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
  Future<List<Slide>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SlideTable> where,
    _is.OrderByBuilder<SlideTable>? orderBy,
    _is.OrderByListBuilder<SlideTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Slide>(
      where: where(Slide.t),
      orderBy: orderBy?.call(Slide.t),
      orderByList: orderByList?.call(Slide.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SlideTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Slide>(
      where: where?.call(Slide.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Slide] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SlideTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Slide>(
      where: where(Slide.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class SlideAttachRepository {
  const SlideAttachRepository._();

  /// Creates a relation between this [Slide] and the given [Pin]s
  /// by setting each [Pin]'s foreign key `_slidesPinsSlidesId` to refer to this [Slide].
  Future<void> pins(
    _is.DatabaseSession session,
    Slide slide,
    List<_iw6bx03f.Pin> pin, {
    _is.Transaction? transaction,
  }) async {
    if (pin.any((e) => e.id == null)) {
      throw ArgumentError.notNull('pin.id');
    }
    if (slide.id == null) {
      throw ArgumentError.notNull('slide.id');
    }

    var $pin = pin
        .map(
          (e) => _iw6bx03f.PinImplicit(
            e,
            $_slidesPinsSlidesId: slide.id,
          ),
        )
        .toList();
    await session.db.update<_iw6bx03f.Pin>(
      $pin,
      columns: [_iw6bx03f.Pin.t.$_slidesPinsSlidesId],
      transaction: transaction,
    );
  }
}

class SlideAttachRowRepository {
  const SlideAttachRowRepository._();

  /// Creates a relation between this [Slide] and the given [Pin]
  /// by setting the [Pin]'s foreign key `_slidesPinsSlidesId` to refer to this [Slide].
  Future<void> pins(
    _is.DatabaseSession session,
    Slide slide,
    _iw6bx03f.Pin pin, {
    _is.Transaction? transaction,
  }) async {
    if (pin.id == null) {
      throw ArgumentError.notNull('pin.id');
    }
    if (slide.id == null) {
      throw ArgumentError.notNull('slide.id');
    }

    var $pin = _iw6bx03f.PinImplicit(
      pin,
      $_slidesPinsSlidesId: slide.id,
    );
    await session.db.updateRow<_iw6bx03f.Pin>(
      $pin,
      columns: [_iw6bx03f.Pin.t.$_slidesPinsSlidesId],
      transaction: transaction,
    );
  }
}

class SlideDetachRepository {
  const SlideDetachRepository._();

  /// Detaches the relation between this [Slide] and the given [Pin]
  /// by setting the [Pin]'s foreign key `_slidesPinsSlidesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> pins(
    _is.DatabaseSession session,
    List<_iw6bx03f.Pin> pin, {
    _is.Transaction? transaction,
  }) async {
    if (pin.any((e) => e.id == null)) {
      throw ArgumentError.notNull('pin.id');
    }

    var $pin = pin
        .map(
          (e) => _iw6bx03f.PinImplicit(
            e,
            $_slidesPinsSlidesId: null,
          ),
        )
        .toList();
    await session.db.update<_iw6bx03f.Pin>(
      $pin,
      columns: [_iw6bx03f.Pin.t.$_slidesPinsSlidesId],
      transaction: transaction,
    );
  }
}

class SlideDetachRowRepository {
  const SlideDetachRowRepository._();

  /// Detaches the relation between this [Slide] and the given [Pin]
  /// by setting the [Pin]'s foreign key `_slidesPinsSlidesId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> pins(
    _is.DatabaseSession session,
    _iw6bx03f.Pin pin, {
    _is.Transaction? transaction,
  }) async {
    if (pin.id == null) {
      throw ArgumentError.notNull('pin.id');
    }

    var $pin = _iw6bx03f.PinImplicit(
      pin,
      $_slidesPinsSlidesId: null,
    );
    await session.db.updateRow<_iw6bx03f.Pin>(
      $pin,
      columns: [_iw6bx03f.Pin.t.$_slidesPinsSlidesId],
      transaction: transaction,
    );
  }
}
