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
import 'package:photopush_client/src/protocol/protocol.dart' as _i7t9t1gg;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_database/serverpod_database.dart' as _isd;
import 'pin.dart' as _iw6bx03f;

abstract class Slide
    implements _isd.TableRow<_isc.UuidValue>, _isc.ProtocolSerialization {
  Slide._({
    _isc.UuidValue? id,
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
  }) : id = id ?? const _isc.Uuid().v7obj(),
       title = title ?? '',
       zPinCounter = zPinCounter ?? 0,
       dirty = dirty ?? 0,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       _albumsSlidesAlbumsId = null;

  factory Slide({
    _isc.UuidValue? id,
    required _isc.UuidValue albumId,
    required String kind,
    String? title,
    String? commentText,
    _isc.UuidValue? assetId,
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
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      albumId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['albumId'],
      ),
      kind: jsonSerialization['kind'] as String,
      title: jsonSerialization['title'] as String?,
      commentText: jsonSerialization['commentText'] as String?,
      assetId: jsonSerialization['assetId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['assetId']),
      pins: jsonSerialization['pins'] == null
          ? null
          : _i7t9t1gg.Protocol().deserialize<List<_iw6bx03f.Pin>>(
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
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['deletedAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      $_albumsSlidesAlbumsId: jsonSerialization['_albumsSlidesAlbumsId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['_albumsSlidesAlbumsId'],
            ),
    );
  }

  static final t = SlideTable();

  static const db = SlideRepository._();

  @override
  _isc.UuidValue id;

  _isc.UuidValue albumId;

  String kind;

  String title;

  String? commentText;

  _isc.UuidValue? assetId;

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

  final _isc.UuidValue? _albumsSlidesAlbumsId;

  @override
  _isd.Table<_isc.UuidValue> get table => t;

  /// Returns a shallow copy of this [Slide]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Slide copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? albumId,
    String? kind,
    String? title,
    String? commentText,
    _isc.UuidValue? assetId,
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
    _isd.WhereExpressionBuilder<SlideTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SlideTable>? orderBy,
    _isd.OrderByListBuilder<SlideTable>? orderByList,
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
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SlideImpl extends Slide {
  _SlideImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue albumId,
    required String kind,
    String? title,
    String? commentText,
    _isc.UuidValue? assetId,
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
  @_isc.useResult
  @override
  Slide copyWith({
    _isc.UuidValue? id,
    _isc.UuidValue? albumId,
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
      assetId: assetId is _isc.UuidValue? ? assetId : this.assetId,
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
    _isc.UuidValue? id,
    required _isc.UuidValue albumId,
    required String kind,
    String? title,
    String? commentText,
    _isc.UuidValue? assetId,
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
    _isc.UuidValue? $_albumsSlidesAlbumsId,
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
    _isc.UuidValue? $_albumsSlidesAlbumsId,
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
  final _isc.UuidValue? _albumsSlidesAlbumsId;
}

class SlideUpdateTable extends _isd.UpdateTable<SlideTable> {
  SlideUpdateTable(super.table);

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> albumId(
    _isc.UuidValue value,
  ) => _isd.ColumnValue(
    table.albumId,
    value,
  );

  _isd.ColumnValue<String, String> kind(String value) => _isd.ColumnValue(
    table.kind,
    value,
  );

  _isd.ColumnValue<String, String> title(String value) => _isd.ColumnValue(
    table.title,
    value,
  );

  _isd.ColumnValue<String, String> commentText(String? value) =>
      _isd.ColumnValue(
        table.commentText,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> assetId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.assetId,
    value,
  );

  _isd.ColumnValue<String, String> orderKey(String value) => _isd.ColumnValue(
    table.orderKey,
    value,
  );

  _isd.ColumnValue<int, int> zPinCounter(int value) => _isd.ColumnValue(
    table.zPinCounter,
    value,
  );

  _isd.ColumnValue<int, int> dirty(int value) => _isd.ColumnValue(
    table.dirty,
    value,
  );

  _isd.ColumnValue<int, int> hlcWall(int value) => _isd.ColumnValue(
    table.hlcWall,
    value,
  );

  _isd.ColumnValue<int, int> hlcCounter(int value) => _isd.ColumnValue(
    table.hlcCounter,
    value,
  );

  _isd.ColumnValue<String, String> deviceId(String value) => _isd.ColumnValue(
    table.deviceId,
    value,
  );

  _isd.ColumnValue<int, int> serverRev(int? value) => _isd.ColumnValue(
    table.serverRev,
    value,
  );

  _isd.ColumnValue<DateTime, DateTime> deletedAt(DateTime? value) =>
      _isd.ColumnValue(
        table.deletedAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _isd.ColumnValue(
        table.createdAt,
        value,
      );

  _isd.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _isd.ColumnValue(
        table.updatedAt,
        value,
      );

  _isd.ColumnValue<_isc.UuidValue, _isc.UuidValue> $_albumsSlidesAlbumsId(
    _isc.UuidValue? value,
  ) => _isd.ColumnValue(
    table.$_albumsSlidesAlbumsId,
    value,
  );
}

class SlideTable extends _isd.Table<_isc.UuidValue> {
  SlideTable({super.tableRelation}) : super(tableName: 'slides') {
    updateTable = SlideUpdateTable(this);
    albumId = _isd.ColumnUuid(
      'albumId',
      this,
    );
    kind = _isd.ColumnString(
      'kind',
      this,
    );
    title = _isd.ColumnString(
      'title',
      this,
      hasDefault: true,
    );
    commentText = _isd.ColumnString(
      'commentText',
      this,
    );
    assetId = _isd.ColumnUuid(
      'assetId',
      this,
    );
    orderKey = _isd.ColumnString(
      'orderKey',
      this,
    );
    zPinCounter = _isd.ColumnInt(
      'zPinCounter',
      this,
      hasDefault: true,
    );
    dirty = _isd.ColumnInt(
      'dirty',
      this,
      hasDefault: true,
    );
    hlcWall = _isd.ColumnInt(
      'hlcWall',
      this,
    );
    hlcCounter = _isd.ColumnInt(
      'hlcCounter',
      this,
    );
    deviceId = _isd.ColumnString(
      'deviceId',
      this,
    );
    serverRev = _isd.ColumnInt(
      'serverRev',
      this,
    );
    deletedAt = _isd.ColumnDateTime(
      'deletedAt',
      this,
    );
    createdAt = _isd.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _isd.ColumnDateTime(
      'updatedAt',
      this,
    );
    $_albumsSlidesAlbumsId = _isd.ColumnUuid(
      '_albumsSlidesAlbumsId',
      this,
    );
  }

  late final SlideUpdateTable updateTable;

  late final _isd.ColumnUuid albumId;

  late final _isd.ColumnString kind;

  late final _isd.ColumnString title;

  late final _isd.ColumnString commentText;

  late final _isd.ColumnUuid assetId;

  _iw6bx03f.PinTable? ___pins;

  _isd.ManyRelation<_iw6bx03f.PinTable>? _pins;

  late final _isd.ColumnString orderKey;

  late final _isd.ColumnInt zPinCounter;

  late final _isd.ColumnInt dirty;

  late final _isd.ColumnInt hlcWall;

  late final _isd.ColumnInt hlcCounter;

  late final _isd.ColumnString deviceId;

  late final _isd.ColumnInt serverRev;

  late final _isd.ColumnDateTime deletedAt;

  late final _isd.ColumnDateTime createdAt;

  late final _isd.ColumnDateTime updatedAt;

  late final _isd.ColumnUuid $_albumsSlidesAlbumsId;

  _iw6bx03f.PinTable get __pins {
    if (___pins != null) return ___pins!;
    ___pins = _isd.createRelationTable(
      relationFieldName: '__pins',
      field: Slide.t.id,
      foreignField: _iw6bx03f.Pin.t.$_slidesPinsSlidesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iw6bx03f.PinTable(tableRelation: foreignTableRelation),
    );
    return ___pins!;
  }

  _isd.ManyRelation<_iw6bx03f.PinTable> get pins {
    if (_pins != null) return _pins!;
    var relationTable = _isd.createRelationTable(
      relationFieldName: 'pins',
      field: Slide.t.id,
      foreignField: _iw6bx03f.Pin.t.$_slidesPinsSlidesId,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iw6bx03f.PinTable(tableRelation: foreignTableRelation),
    );
    _pins = _isd.ManyRelation<_iw6bx03f.PinTable>(
      tableWithRelations: relationTable,
      table: _iw6bx03f.PinTable(
        tableRelation: relationTable.tableRelation!.lastRelation,
      ),
    );
    return _pins!;
  }

  @override
  List<_isd.Column> get columns => [
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
  List<_isd.Column> get managedColumns => [
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
  _isd.Table? getRelationTable(String relationField) {
    if (relationField == 'pins') {
      return __pins;
    }
    return null;
  }
}

class SlideInclude extends _isd.IncludeObject {
  SlideInclude._({_iw6bx03f.PinIncludeList? pins}) {
    _pins = pins;
  }

  _iw6bx03f.PinIncludeList? _pins;

  @override
  Map<String, _isd.Include?> get includes => {'pins': _pins};

  @override
  _isd.Table<_isc.UuidValue> get table => Slide.t;
}

class SlideIncludeList extends _isd.IncludeList {
  SlideIncludeList._({
    _isd.WhereExpressionBuilder<SlideTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Slide.t);
  }

  @override
  Map<String, _isd.Include?> get includes => include?.includes ?? {};

  @override
  _isd.Table<_isc.UuidValue> get table => Slide.t;
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SlideTable>? where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SlideTable>? orderBy,
    _isd.OrderByListBuilder<SlideTable>? orderByList,
    _isd.Transaction? transaction,
    SlideInclude? include,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SlideTable>? where,
    int? offset,
    _isd.OrderByBuilder<SlideTable>? orderBy,
    _isd.OrderByListBuilder<SlideTable>? orderByList,
    _isd.Transaction? transaction,
    SlideInclude? include,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    _isd.Transaction? transaction,
    SlideInclude? include,
    _isd.LockMode? lockMode,
    _isd.LockBehavior? lockBehavior,
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
    _isd.DatabaseSession session,
    List<Slide> rows, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Slide row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Slide> rows, {
    required _isd.ColumnSelections<SlideTable> conflictColumns,
    _isd.ColumnSelections<SlideTable>? updateColumns,
    _isd.WhereExpressionBuilder<SlideTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Slide row, {
    required _isd.ColumnSelections<SlideTable> conflictColumns,
    _isd.ColumnSelections<SlideTable>? updateColumns,
    _isd.WhereExpressionBuilder<SlideTable>? updateWhere,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Slide> rows, {
    _isd.ColumnSelections<SlideTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Slide row, {
    _isd.ColumnSelections<SlideTable>? columns,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _isc.UuidValue id, {
    required _isd.ColumnValueListBuilder<SlideUpdateTable> columnValues,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.ColumnValueListBuilder<SlideUpdateTable> columnValues,
    required _isd.WhereExpressionBuilder<SlideTable> where,
    int? limit,
    int? offset,
    _isd.OrderByBuilder<SlideTable>? orderBy,
    _isd.OrderByListBuilder<SlideTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<Slide> rows, {
    _isd.OrderByBuilder<SlideTable>? orderBy,
    _isd.OrderByListBuilder<SlideTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Slide row, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SlideTable> where,
    _isd.OrderByBuilder<SlideTable>? orderBy,
    _isd.OrderByListBuilder<SlideTable>? orderByList,
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session, {
    _isd.WhereExpressionBuilder<SlideTable>? where,
    int? limit,
    _isd.Transaction? transaction,
  }) async {
    return session.db.count<Slide>(
      where: where?.call(Slide.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Slide] rows matching the [where] expression.
  Future<void> lockRows(
    _isd.DatabaseSession session, {
    required _isd.WhereExpressionBuilder<SlideTable> where,
    required _isd.LockMode lockMode,
    required _isd.Transaction transaction,
    _isd.LockBehavior lockBehavior = _isd.LockBehavior.wait,
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
    _isd.DatabaseSession session,
    Slide slide,
    List<_iw6bx03f.Pin> pin, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    Slide slide,
    _iw6bx03f.Pin pin, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    List<_iw6bx03f.Pin> pin, {
    _isd.Transaction? transaction,
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
    _isd.DatabaseSession session,
    _iw6bx03f.Pin pin, {
    _isd.Transaction? transaction,
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
