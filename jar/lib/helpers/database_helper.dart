import 'dart:async';
import 'package:jar/models/batch.dart';
import 'package:jar/models/jar.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/received.dart';
import 'package:jar/models/user.dart';
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
      jar_id INTEGER,
      batch_id INTEGER,
      FOREIGN KEY(warehouse_id) REFERENCES warehouses(id),
      FOREIGN KEY(user_id) REFERENCES users(id),
      FOREIGN KEY(jar_id) REFERENCES jar(id),
      FOREIGN KEY(batch_id) REFERENCES batch(id)
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

  // Crea user admin si no existe
  Future<User> ensureAdminUser() async {
    final db = await database;
    // Intenta encontrar un usuario administrador
    final List<Map<String, dynamic>> users = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [
        'admin@admin.com'
      ], // Asume que este es el correo del administrador
    );

    if (users.isNotEmpty) {
      // Si el usuario administrador ya existe, devuelve ese usuario
      return User.fromMap(users.first);
    } else {
      // Si el usuario administrador no existe, créalo
      int id = await db.insert('users', {
        'name': 'Admin',
        'email': 'admin@admin.com',
        // Asegúrate de tener una manera de identificarlo como administrador, podría ser un campo adicional o un rol específico
      });
      // Devuelve el nuevo usuario administrador
      return User(id: id, name: 'Admin', email: 'admin@admin.com');
    }
  }

  // *USERS* //
  Future<List<User>> getUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User.fromMap(maps[i]);
    });
  }

  // *RECEIVED* //
  Future<List<Received>> getReceived() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('received');
    return List.generate(maps.length, (i) {
      return Received.fromMap(maps[i]);
    });
  }

  Future<List<Received>> getReceivedForIdWarehouse(int warehouseId) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT received.*, users.*, warehouses.*, jar.*, batch.*
      FROM received
      JOIN users ON users.id = received.user_id
      JOIN warehouses ON warehouses.id = received.warehouse_id
      JOIN jar ON jar.id = received.jar_id
      JOIN batch ON batch.id = received.batch_id
      WHERE received.warehouse_id = ?
    ''', [warehouseId]);

    return result.map((map) => Received.fromMap(map)).toList();
  }

  Future<Received> createReceived({
    required String date,
    required int warehouseId,
    required int userId,
    int? jarId,
    int? batchId,
  }) async {
    final db = await database;
    final id = await db.insert(
      'received',
      {
        'date': date,
        'warehouse_id': warehouseId,
        'user_id': userId,
        'jar_id': jarId,
        'batch_id': batchId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Ahora recuperamos el objeto 'Received' basado en el ID generado.
    final List<Map<String, dynamic>> insertedReceived = await db.query(
      'received',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (insertedReceived.isNotEmpty) {
      // Si se encuentra el registro, lo devolvemos como un objeto 'Received'.
      return Received.fromMap(insertedReceived.first);
    } else {
      // Manejar el caso en que el registro no se pueda recuperar.
      // Esto podría lanzar un error o manejarlo de alguna manera significativa para tu aplicación.
      throw Exception('Failed to create received record.');
    }
  }

  // *WAREHOUSE* //
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

  // *JAR* //
  Future<Jar> createJar(Jar jar) async {
    final db = await database;
    final id = await db.insert(
      'jar',
      jar.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Retorna una nueva instancia de Jar con el ID generado
    return Jar(id: id, name: jar.name);
  }

  // *PALLETS* //
  Future<Pallet> createPallet(Pallet pallet) async {
    final db = await database;
    final id = await db.insert(
      'pallets',
      pallet.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Retorna una nueva instancia de Pallet con el ID generado
    return Pallet(id: id, batchId: pallet.batchId, number: pallet.number);
  }

  // *BATCH* //
  Future<Batch2> createBatch(Batch2 batch) async {
    final db = await database;
    final id = await db.insert(
      'batch',
      batch.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Retorna una nueva instancia de Batch con el ID generado
    return Batch2(id: id, name: batch.name, jarId: batch.jarId);
  }

  // Cerrar la base de datos
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
