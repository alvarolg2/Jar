import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warehouse_transport.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    return await openDatabase(path,
        version: 3, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE pallet ADD COLUMN defective INTEGER DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE product ADD COLUMN description TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE "product" (
        "id" INTEGER NOT NULL UNIQUE,
        "name" TEXT,
        "description" TEXT,
        "create_date" DATETIME DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
    ''');
    await db.execute('''
      CREATE TABLE "lot" ( "id" INTEGER NOT NULL UNIQUE, "name" TEXT, "create_date" DATETIME DEFAULT CURRENT_TIMESTAMP, "product" INTEGER, PRIMARY KEY("id" AUTOINCREMENT), FOREIGN KEY("product") REFERENCES "product"("id") );
    ''');
    await db.execute('''
      CREATE TABLE "pallet" ( "id" INTEGER NOT NULL UNIQUE, "name" TEXT NOT NULL UNIQUE, "warehouse" INTEGER, "create_date" DATETIME DEFAULT CURRENT_TIMESTAMP, "out_date" DATETIME, "date" DATETIME, "is_out" INTEGER DEFAULT 0, "defective" INTEGER DEFAULT 0, PRIMARY KEY("id" AUTOINCREMENT), FOREIGN KEY("warehouse") REFERENCES "warehouse"("id") );
    ''');
    await db.execute('''
      CREATE TABLE "pallet_lot" ( "id_pallet" INTEGER NOT NULL, "id_lot" INTEGER NOT NULL, PRIMARY KEY("id_pallet", "id_lot") );
    ''');
    await db.execute('''
      CREATE TABLE "warehouse" ( "id" INTEGER NOT NULL UNIQUE, "name" TEXT NOT NULL UNIQUE, "address" TEXT, "create_date" DATETIME DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY("id" AUTOINCREMENT) );
    ''');
  }

  static Future<String> getDatabasePath() async {
    const dbName = 'warehouse_transport.db';
    final dbPath = await getApplicationDocumentsDirectory();
    return join(dbPath.path, dbName);
  }

  Future<void> close() async {
    if (_database == null) return;
    await _database!.close();
    _database = null;
  }

  Future<void> reopen() async {
    await close();
    await database;
  }

  Future<bool> isValidSqliteFile(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return false;

      final fileSize = await file.length();
      if (fileSize < 100) return false;

      final headerBytes = await file.openRead(0, 16).first;
      final header = String.fromCharCodes(headerBytes);
      return header.startsWith('SQLite format 3');
    } catch (_) {
      return false;
    }
  }

  Future<String?> checkIntegrity(String dbPath) async {
    try {
      final db = await openDatabase(dbPath, readOnly: true);
      final result = await db.rawQuery('PRAGMA integrity_check');
      await db.close();
      final integrity = result.first['integrity_check'] as String;
      return integrity == 'ok' ? null : integrity;
    } catch (e) {
      return e.toString();
    }
  }

  Future<bool> hasValidSchema(String dbPath) async {
    try {
      final db = await openDatabase(dbPath, readOnly: true);
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('product', 'lot', 'pallet', 'pallet_lot', 'warehouse')",
      );
      await db.close();
      return tables.length == 5;
    } catch (_) {
      return false;
    }
  }
}
