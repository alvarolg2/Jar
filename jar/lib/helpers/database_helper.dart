import 'dart:async';
import 'package:jar/models/warehouse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  // Crear una instancia singleton de DatabaseHelper
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  // Getter para la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    // Si _database es nulo, inicializamos la base de datos
    _database = await _initDB('warehouse_transport.db');
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // Crear las tablas en la base de datos
  Future _createDB(Database db, int version) async {
    // Sentencias SQL para crear las tablas

    const String tableUsers = '''
    CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      email TEXT
    );
    ''';

    const String tableWarehouses = '''
    CREATE TABLE warehouses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      location TEXT,
      name TEXT
    );
    ''';

    const String tableReceived = '''
    CREATE TABLE received(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      warehouse_id INTEGER,
      user_id INTEGER,
      FOREIGN KEY(warehouse_id) REFERENCES warehouses(id),
      FOREIGN KEY(user_id) REFERENCES users(id)
    );
    ''';

    const String tableJar = '''
    CREATE TABLE jar(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    );
    ''';

    const String tableBatch = '''
    CREATE TABLE batch(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      jar_id INTEGER,
      FOREIGN KEY(jar_id) REFERENCES jar(id)
    );
    ''';

    const String tablePallets = '''
    CREATE TABLE pallets(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      batch_id INTEGER,
      number TEXT,
      FOREIGN KEY(batch_id) REFERENCES batch(id)
    );
    ''';

    const String tableTravel = '''
    CREATE TABLE travel(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      date TEXT,
      batch_id INTEGER,
      pallet_id INTEGER,
      warehouse_id INTEGER,
      FOREIGN KEY(batch_id) REFERENCES batch(id),
      FOREIGN KEY(pallet_id) REFERENCES pallets(id),
      FOREIGN KEY(warehouse_id) REFERENCES warehouses(id)
    );
    ''';

    // Ejecutar las sentencias SQL para crear las tablas
    await db.execute(tableUsers);
    await db.execute(tableWarehouses);
    await db.execute(tableReceived);
    await db.execute(tableJar);
    await db.execute(tableBatch);
    await db.execute(tablePallets);
    await db.execute(tableTravel);
  }

  // Métodos para operaciones CRUD aquí...
  Future<List<Warehouse>> getWarehouses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('warehouses');
    return List.generate(maps.length, (i) {
      return Warehouse.fromMap(maps[i]);
    });
  }

  Future<void> createWarehouse(Warehouse warehouse) async {
    final db = await database;
    // Inserta el almacén en la base de datos y obtiene el ID generado
    await db.insert('warehouses', warehouse.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateWarehouseName(int id, String newName) async {
    final db = await database;
    await db.update(
      'warehouses',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteWarehouse(int id) async {
    final db = await database;
    await db.delete(
      'warehouses', // Asegúrate de que este es el nombre correcto de tu tabla
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Cerrar la base de datos
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
