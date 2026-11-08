import 'dart:async';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SQLDB {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  int get version => 6;

  Future<Database> intialDb() async {
    String dataBais;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final dir = await getApplicationSupportDirectory();
      dataBais = dir.path;
    } else {
      dataBais = await getDatabasesPath();
    }
    String path = join(dataBais, 'zeffa.db');
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: version,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  /// Upgrades may run again on a database that already has the change
  /// (e.g. the version wasn't saved after an interrupted upgrade), so a
  /// column is added only when it's missing.
  Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String type,
  ) async {
    final cols = await db.rawQuery('PRAGMA table_info($table)');
    if (cols.any((c) => c['name'] == column)) return;
    await db.execute("ALTER TABLE $table ADD COLUMN $column $type");
  }

  Future<void> _onUpgrade(Database db, int oldversion, int newVersion) async {
    print("_onUpgrade ===============");
    if (oldversion < 2) {
      // ربط المصاريف بالحجز + المصاريف المحفوظة لكل نوع حفلة
      await _addColumnIfMissing(db, "expenses", "reservation_uuid", "TEXT");
      await _addColumnIfMissing(db, "party_types", "default_expenses", "TEXT");
    }
    if (oldversion < 3) {
      // القاعات الإضافية + ربط الحجز بالقاعة (فارغ = قاعة الحساب)
      await db.execute('''
      CREATE TABLE IF NOT EXISTS halls(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        name TEXT,
        phone1 TEXT,
        phone2 TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');
      await _addColumnIfMissing(db, "reservations", "hall_uuid", "TEXT");
    }
    if (oldversion < 4) {
      // موقع القاعة (اختياري)
      await _addColumnIfMissing(db, "halls", "address", "TEXT");
    }
    if (oldversion < 5) {
      // طريقة حساب سعر الخدمة: 0 = ثابت، 1 = لكل شخص
      await _addColumnIfMissing(
        db,
        "additional_services",
        "price_type",
        "INTEGER DEFAULT 0",
      );
    }
    if (oldversion < 6) {
      // سعر العامل / العاملة للفرد حسب نوع الحفل + عددهم في مصروف العمال
      await _addColumnIfMissing(db, "party_types", "worker_price", "REAL");
      await _addColumnIfMissing(db, "party_types", "female_worker_price", "REAL");
      await _addColumnIfMissing(db, "expenses", "workers_count", "INTEGER");
      await _addColumnIfMissing(db, "expenses", "female_workers_count", "INTEGER");
      await _addColumnIfMissing(db, "expenses", "worker_price", "REAL");
      await _addColumnIfMissing(db, "expenses", "female_worker_price", "REAL");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    Batch batch = db.batch();

    // ==============================
    // party_types
    // ==============================
    batch.execute('''
      CREATE TABLE party_types(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        name TEXT,
        content TEXT,
        basic_price REAL,
        seasonal_price REAL,
        guest_pricing_tiers TEXT,
        icon TEXT,
        default_expenses TEXT,
        worker_price REAL,
        female_worker_price REAL,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // ==============================
    // Reservations
    // ==============================
    batch.execute('''
      CREATE TABLE reservations(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        numperReservation TEXT,
        username TEXT,
        phone_numper TEXT,
        booking_date TEXT,
        booking_period INTEGER,
        type_of_party_uuid TEXT,
        hall_uuid TEXT,
        price REAL,
        notes TEXT,
        deposit REAL,
        remaining_amount REAL,
        number_of_men INTEGER,
        number_of_women INTEGER,
        added_by_name TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // ==============================
    // cat_dishes
    // ==============================
    batch.execute('''
      CREATE TABLE cat_dishes(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        name TEXT,
        image TEXT,
        created_at TEXT,
        updated_at TEXT
      )
  ''');

    // ==============================
    // dishes
    // ==============================
    batch.execute('''
      CREATE  TABLE dishes(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        cat_uuid TEXT,
        name TEXT,
        image TEXT,
        created_at TEXT,
        updated_at TEXT
      )
''');

    // ==============================
    // reservation_dishes
    // ==============================
    batch.execute('''
      CREATE TABLE reservation_dishes(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        reservation_uuid TEXT,
        dishes_uuid TEXT,
        created_at TEXT,
        updated_at TEXT
      )
''');

    // ==============================
    // additional_services
    // ==============================
    batch.execute('''
      CREATE TABLE additional_services(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        name TEXT,
        price REAL,
        price_type INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
''');

    // ==============================
    // reservation_services
    // ==============================
    batch.execute('''
      CREATE TABLE reservation_services(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        reservation_uuid TEXT,
        service_uuid TEXT,
        user_id INTEGER,
        created_at TEXT,
        updated_at TEXT
      )
''');

    // ==============================
    // special_dates
    // ==============================
    batch.execute('''
      CREATE TABLE special_dates(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        reservation_uuid TEXT,
        user_id INTEGER,
        title TEXT,
        type TEXT,
        start_date TEXT,
        end_date TEXT,
        date TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // halls (extra halls of the account)
    // ==============================
    batch.execute('''
      CREATE TABLE IF NOT EXISTS halls(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        name TEXT,
        phone1 TEXT,
        phone2 TEXT,
        address TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // expenses
    // ==============================
    batch.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        reservation_uuid TEXT,
        workers_count INTEGER,
        female_workers_count INTEGER,
        worker_price REAL,
        female_worker_price REAL,
        type INTEGER,
        description TEXT,
        value REAL,
        date_perry TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // notes
    // ==============================
    batch.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        title TEXT,
        description TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // notifications
    // ==============================
    batch.execute('''
      CREATE TABLE notifications(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        title TEXT,
        content TEXT,
        is_read INTEGER DEFAULT 0,
        type TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // Terms
    // ==============================
    batch.execute('''
      CREATE TABLE terms(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
        title TEXT,
        type TEXT, -- 'internal_rules','contract_terms','required_procedures','required_documents'
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // Terms
    // ==============================
    batch.execute('''
      CREATE TABLE terms_content(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        term_uuid TEXT,
        user_id INTEGER,
        content TEXT,
        created_at TEXT,
        updated_at TEXT
      )
      ''');

    // ==============================
    // جداول خاصة بالمزامنة
    // ==============================

    /// جدول العمليات (queue)
    batch.execute('''
    CREATE TABLE sync_queue(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      table_name TEXT NOT NULL,
      row_id TEXT NOT NULL,
      operation TEXT NOT NULL, -- insert/update/delete
      data TEXT, -- JSON مخزن فيه البيانات (عند insert/update)
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      synced INTEGER DEFAULT 0 -- 0: مازال، 1: تزامن
    )
  ''');

    /// جدول الميتاداتا (آخر وقت تزامن)
    batch.execute('''
    CREATE TABLE sync_metadata(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      table_name TEXT NOT NULL,
      last_sync TEXT,
      user_id INTEGER NOT NULL
    )
  ''');

    await batch.commit();
    print(
      'Database and tables (with sync) created successfully ======================',
    );
  }

  // CRUD METHODS =============================================

  Future<List<Map<String, Object?>>> readData(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    Database? mydb = await db;
    return await mydb!.rawQuery(sql, arguments);
  }

  Future<int> insertData(String sql) async {
    Database? mydb = await db;
    return await mydb!.rawInsert(sql);
  }

  Future<int> updateData(String sql, List list) async {
    Database? mydb = await db;
    return await mydb!.rawUpdate(sql);
  }

  Future<int> deleteData(String sql) async {
    Database? mydb = await db;
    return await mydb!.rawDelete(sql);
  }

  Future<void> mydeleteDatebase() async {
    String dataBais;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final dir = await getApplicationSupportDirectory();
      dataBais = dir.path;
    } else {
      dataBais = await getDatabasesPath();
    }
    String path = join(dataBais, 'zeffa.db');
    await deleteDatabase(path);
  }

  Future<List<Map>> read(String table) async {
    Database? mydb = await db;
    return await mydb!.query(table);
  }

  Future<int> insert(String table, Map<String, Object?> values) async {
    Database? mydb = await db;
    return await mydb!.insert(table, values);
  }

  Future<int> update(
    String table,
    Map<String, Object?> values,
    String? where, [
    List<Object?>? whereArgs,
  ]) async {
    Database? mydb = await db;
    return await mydb!.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<int> delete(
    String table,
    String? where, [
    List<Object?>? whereArgs,
  ]) async {
    Database? mydb = await db;
    return await mydb!.delete(table, where: where, whereArgs: whereArgs);
  }
}
