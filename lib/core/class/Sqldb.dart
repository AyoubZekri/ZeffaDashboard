import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

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

  Future<Database> intialDb() async {
    String dataBais = await getDatabasesPath();
    String path = join(dataBais, 'zeffa.db');
    Database mydb = await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  Future<void> _onUpgrade(Database db, int oldversion, int newVersion) async {
    print("_onUpgrade ===============");
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
        icon TEXT,
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
        username TEXT,
        phone_numper TEXT,
        booking_date TEXT,
        booking_period INTEGER,
        type_of_party_uuid TEXT,
        price REAL,
        notes TEXT,
        deposit REAL,
        remaining_amount REAL,
        number_of_men INTEGER,
        number_of_women INTEGER,
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
    // expenses
    // ==============================
    batch.execute('''
      CREATE TABLE expenses(
        id INTEGER PRIMARY KEY,
        uuid TEXT UNIQUE,
        user_id INTEGER,
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
    String dataBais = await getDatabasesPath();
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
