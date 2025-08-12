import 'dart:async';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/warehouse.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('warehouse_transport.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _upgradeDB);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE pallet ADD COLUMN defective INTEGER DEFAULT 0');
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE "product" ( "id" INTEGER NOT NULL UNIQUE, "name" TEXT, "create_date" DATETIME DEFAULT CURRENT_TIMESTAMP, PRIMARY KEY("id" AUTOINCREMENT) );
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

  // ✅ MÉTODO CORREGIDO Y MÁS SEGURO
  Future<void> close() async {
    // No usamos el getter 'database' aquí para evitar una posible recreación.
    // Operamos directamente sobre la instancia estática.
    if (_database == null) {
      return; // Ya está cerrada, no hacemos nada.
    }
    await _database!.close();
    _database = null;
  }
  
  // --- MÉTODOS REFACTORIZADOS Y CENTRALIZADOS ---

  Future<List<Lot>> getLotsWithPallets({
    required int warehouseId,
    required bool isDefective,
    int? productId,
  }) async {
    final db = await database;
    String subQuery = '''
      SELECT DISTINCT l.id FROM lot l
      JOIN pallet_lot pl ON pl.id_lot = l.id
      JOIN pallet pal ON pl.id_pallet = pal.id
      WHERE pal.warehouse = ? AND pal.is_out = 0 AND pal.defective = ?
    ''';
    List<dynamic> subQueryParams = [warehouseId, isDefective ? 1 : 0];

    if (productId != null) {
      subQuery += ' AND l.product = ?';
      subQueryParams.add(productId);
    }

    String mainQuery = '''
      SELECT l.*, p.id AS productId, p.name AS productName, p.create_date AS productCreateDate
      FROM lot l
      JOIN product p ON l.product = p.id
      WHERE l.id IN ($subQuery)
      ORDER BY l.create_date DESC
    ''';
    final List<Map<String, dynamic>> maps = await db.rawQuery(mainQuery, subQueryParams);

    List<Lot> lots = [];
    for (var map in maps) {
      final product = Product.fromJson({
        'id': map['productId'],
        'name': map['productName'],
        'create_date': map['productCreateDate'],
      });
      var lot = Lot(
        id: map['id'],
        name: map['name'],
        createDate: DateTime.parse(map['create_date']),
        product: product,
        pallet: [],
      );
      final List<Map<String, dynamic>> palletMaps = await db.rawQuery('''
        SELECT * FROM pallet
        WHERE id IN (SELECT id_pallet FROM pallet_lot WHERE id_lot = ?) 
              AND warehouse = ?
      ''', [lot.id, warehouseId]);
      var pallets = palletMaps.map((p) => Pallet.fromJson(p)).toList();
      lot = lot.copyWith(pallet: pallets);
      lots.add(lot);
    }
    return lots;
  }

  Future<Map<int, int>> getAllWarehousePalletCounts({required bool isDefective}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT warehouse, COUNT(id) as count
      FROM pallet
      WHERE is_out = 0 AND defective = ?
      GROUP BY warehouse
    ''', [isDefective ? 1 : 0]);
    return {for (var map in maps) map['warehouse'] as int: map['count'] as int};
  }

  // ** LOT **
  Future<int> insertLot(Lot lot) async {
    final db = await database;
    return await db.insert('lot', lot.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Lot?> findLotByName(String lotName) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query('lot', where: 'name = ?', whereArgs: [lotName]);
    if (results.isNotEmpty) return Lot.fromJson(results.first);
    return null;
  }

  // ** WAREHOUSE **
  Future<int> createWarehouse(Warehouse warehouse) async {
    final db = await database;
    return await db.insert('warehouse', warehouse.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateWarehouse(Warehouse warehouse) async {
    final db = await database;
    return await db.update('warehouse', warehouse.toMap(), where: 'id = ?', whereArgs: [warehouse.id]);
  }

  Future<int> deleteWarehouse(int id) async {
    final db = await database;
    return await db.delete('warehouse', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Warehouse>> getAllWarehouses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('warehouse', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Warehouse.fromMap(maps[i]));
  }

  // ** PRODUCT **
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('product', product.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Product?> findProductByName(String productName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('product', where: 'name = ?', whereArgs: [productName]);
    if (maps.isNotEmpty) return Product.fromJson(maps.first);
    return null;
  }

  Future<List<Product>> getProductsByPalletsNotOutWithCount(int warehouseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT p.*, COUNT(pal.id) AS numPallets
      FROM product p
      JOIN lot l ON p.id = l.product
      JOIN pallet_lot pl ON l.id = pl.id_lot
      JOIN pallet pal ON pl.id_pallet = pal.id
      WHERE pal.is_out = 0 AND pal.warehouse = ?
      GROUP BY p.id
      ORDER BY p.name ASC
    ''', [warehouseId]);
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }

  // ** PALLET **
  Future<void> createPalletAndLinkToLot(Pallet pallet, int lotId) async {
    final db = await database;
    Map<String, dynamic> palletData = pallet.toJson();
    palletData['create_date'] = DateTime.now().toIso8601String();
    int palletId = await db.insert('pallet', palletData, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('pallet_lot', {'id_pallet': palletId, 'id_lot': lotId}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markPalletsAsOut(int lotId, int numberOfPallets, int warehouseId) async {
    final db = await database;
    List<Map<String, dynamic>> palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.is_out = 0 AND p.defective = 0 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPallets]);
    for (var row in palletIds) {
      await db.update('pallet', {'is_out': 1, 'out_date': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [row['id']]);
    }
  }

  Future<void> markPalletsAsDefectuous(int lotId, int numberOfPallets, int warehouseId) async {
    final db = await database;
    List<Map<String, dynamic>> palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.defective = 0 AND p.is_out = 0 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPallets]);
    for (var row in palletIds) {
      await db.update('pallet', {'defective': 1}, where: 'id = ?', whereArgs: [row['id']]);
    }
  }

  Future<void> markPalletsAsOutDefective(int lotId, int numberOfPallets, int warehouseId) async {
    final db = await database;
    List<Map<String, dynamic>> palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.is_out = 0 AND p.defective = 1 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPallets]);
    for (var row in palletIds) {
      await db.update('pallet', {'is_out': 1, 'out_date': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [row['id']]);
    }
  }
}