import 'dart:async';
import 'package:jar/models/lot.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';
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

  return await openDatabase(
    path,
    version: 2, // Incrementar la versión de la base de datos
    onCreate: _createDB,
    onUpgrade: _upgradeDB,
  );
}

// Método para actualizar la base de datos
Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await db.execute('ALTER TABLE pallet ADD COLUMN defective INTEGER DEFAULT 0');
  }
}

  // Crear las tablas en la base de datos
  Future _createDB(Database db, int version) async {
    // Sentencia SQL para crear las tablas
    await db.execute('''
      CREATE TABLE "product" (
        "id"	INTEGER NOT NULL UNIQUE,
        "name"	TEXT,
        "create_date"	datetime DEFAULT current_timestamp,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
    ''');

    await db.execute('''
      CREATE TABLE "lot" (
        "id"	INTEGER NOT NULL UNIQUE,
        "name"	TEXT,
        "create_date"	datetime DEFAULT current_timestamp,
        "product"	INTEGER,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("product") REFERENCES "product"("id")
      );
    ''');

    await db.execute('''
      CREATE TABLE "pallet" (
        "id"	INTEGER NOT NULL UNIQUE,
        "name"	TEXT NOT NULL UNIQUE,
        "warehouse"	INTEGER,
        "create_date"	datetime DEFAULT current_timestamp,
        "out_date"	datetime,
        "date"	datetime,
        "is_out"	INTEGER DEFAULT 0,
        "defective"	INTEGER DEFAULT 0,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("warehouse") REFERENCES "warehouse"("id")
      );
    ''');

    await db.execute('''
      CREATE TABLE "pallet_lot" (
        "id_pallet"	INTEGER NOT NULL UNIQUE,
        "id_lot"	INTEGER NOT NULL,
        PRIMARY KEY("id_pallet","id_lot")
      );
    ''');

    await db.execute('''
      CREATE TABLE "warehouse" (
        "id"	INTEGER NOT NULL UNIQUE,
        "name"	TEXT NOT NULL UNIQUE,
        "address"	TEXT,
        "create_date"	datetime DEFAULT current_timestamp,
        PRIMARY KEY("id" AUTOINCREMENT)
      );
    ''');
  }

  // *LOT* //
  Future<int> insertLot(Lot lot) async {
    final db = await database;
    int id = await db.insert(
      'lot',
      lot.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<void> updateLot(Lot lot) async {
    if (lot.id == null) {
      throw ArgumentError("El lot debe tener un id para ser actualizado.");
    }
    final db = await database;
    await db.update(
      'lot',
      lot.toJson(),
      where: 'id = ?',
      whereArgs: [lot.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteLot(int id) async {
    final db = await database;
    await db.delete(
      'lot',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Lot>> getAllLots() async {
    final db = await database;
    // Ajusta esta consulta para incluir todos los campos necesarios de la tabla product.
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT lot.*, 
            product.id AS productId, 
            product.name AS productName,
            product.create_date AS productCreateDate
      FROM lot
      JOIN product ON lot.product = product.id
    ''');

    // Convertir la List<Map<String, dynamic>> en una List<Lot>.
    return List.generate(maps.length, (i) {
      // Construye el objeto Product a partir de los campos del producto.
      final product = Product(
        id: maps[i]['productId'],
        name: maps[i]['productName'],
        createDate: DateTime.parse(maps[i]['productCreateDate']),
        // Añade aquí más campos si tu objeto Product los requiere.
      );

      // Construye el objeto Lot, ahora incluyendo el objeto Product completo.
      return Lot(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createDate: DateTime.parse(maps[i]['create_date']),
        product: product, // Asigna el objeto Product completo aquí.
        // Añade cualquier otro campo que tu objeto Lot pueda requerir.
      );
    });
  }

  Future<List<Lot>> getAllLotsByWarehouseId(int warehouseId) async {
    final db = await database;
    // Añade la cláusula WHERE para filtrar por warehouseId.
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT lot.*, 
            product.id AS productId, 
            product.name AS productName,
            product.create_date AS productCreateDate
      FROM lot
      JOIN product ON lot.product = product.id
      WHERE lot.warehouse = ?
    ''', [warehouseId]); // Pasa warehouseId como parámetro a la consulta.

    // Convertir la List<Map<String, dynamic>> en una List<Lot>.
    return List.generate(maps.length, (i) {
      // Construye el objeto Product a partir de los campos del producto.
      final product = Product(
        id: maps[i]['productId'],
        name: maps[i]['productName'],
        createDate: DateTime.parse(maps[i]['productCreateDate']),
        // Añade aquí más campos si tu objeto Product los requiere.
      );

      // Construye el objeto Lot, ahora incluyendo el objeto Product completo y filtrado por warehouseId.
      return Lot(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createDate: DateTime.parse(maps[i]['create_date']),
        product: product, // Asigna el objeto Product completo aquí.
        // Añade cualquier otro campo que tu objeto Lot pueda requerir.
      );
    });
  }

  Future<List<Lot>> getAllLotsByWarehouseIdWithPallets(int warehouseId) async {
    final db = await database;
    // Modificamos la consulta para filtrar por pallets en el almacén especificado con is_out = 0
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
  SELECT lot.*, 
         product.id AS productId, 
         product.name AS productName,
         product.create_date AS productCreateDate
  FROM lot
  JOIN product ON lot.product = product.id
  JOIN pallet_lot ON pallet_lot.id_lot = lot.id
  JOIN pallet ON pallet_lot.id_pallet = pallet.id
  WHERE pallet.warehouse = ? AND pallet.is_out = 0
  GROUP BY lot.id
  ORDER BY lot.create_date DESC
  ''', [warehouseId]);

    List<Lot> lots = [];
    for (var map in maps) {
      final product = Product(
        id: map['productId'],
        name: map['productName'],
        createDate: DateTime.parse(map['productCreateDate']),
      );

      var lot = Lot(
        id: map['id'],
        name: map['name'],
        createDate: DateTime.parse(map['create_date']),
        product: product,
        pallet: [], // Inicializa la lista de pallets vacía.
      );

      // Modificamos esta consulta para obtener todos los pallets asociados a este lote que pertenecen al warehouseId
      final List<Map<String, dynamic>> palletMaps = await db.rawQuery('''
    SELECT pallet.*
    FROM pallet
    JOIN pallet_lot ON pallet_lot.id_pallet = pallet.id
    WHERE pallet_lot.id_lot = ? AND pallet.warehouse = ?
    ''', [lot.id, warehouseId]);

      var pallets =
          palletMaps.map((palletMap) => Pallet.fromJson(palletMap)).toList();
      lot = lot.copyWith(
          pallet: pallets); // Actualizar la lista de pallets del lote

      lots.add(lot);
    }

    return lots;
  }

  Future<List<Lot>> getAllLotsByWarehouseIdWithPalletsAndProductId(
      int warehouseId, int productId) async {
    final db = await database;
    // Se añade el filtro por productId en la consulta
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
    SELECT lot.*, 
          product.id AS productId, 
          product.name AS productName,
          product.create_date AS productCreateDate
    FROM lot
    JOIN product ON lot.product = product.id
    JOIN pallet_lot ON pallet_lot.id_lot = lot.id
    JOIN pallet ON pallet_lot.id_pallet = pallet.id
    WHERE pallet.warehouse = ? AND pallet.is_out = 0 AND product.id = ?
    GROUP BY lot.id
    ORDER BY lot.create_date DESC
    ''', [warehouseId, productId]);

    List<Lot> lots = [];
    for (var map in maps) {
      final product = Product(
        id: map['productId'],
        name: map['productName'],
        createDate: DateTime.parse(map['productCreateDate']),
      );

      var lot = Lot(
        id: map['id'],
        name: map['name'],
        createDate: DateTime.parse(map['create_date']),
        product: product,
        pallet: [], // Inicializa la lista de pallets vacía.
      );

      // Consulta para obtener todos los pallets asociados a este lote que pertenecen al warehouseId
      final List<Map<String, dynamic>> palletMaps = await db.rawQuery('''
      SELECT pallet.*
      FROM pallet
      JOIN pallet_lot ON pallet_lot.id_pallet = pallet.id
      WHERE pallet_lot.id_lot = ? AND pallet.warehouse = ?
      ''', [lot.id, warehouseId]);

      var pallets =
          palletMaps.map((palletMap) => Pallet.fromJson(palletMap)).toList();
      lot = lot.copyWith(
          pallet: pallets); // Actualiza la lista de pallets del lote

      lots.add(lot);
    }

    return lots;
  }

  Future<Lot?> findLotByName(String lotName) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'lot',
      where: 'name = ?',
      whereArgs: [lotName],
    );

    // Si encuentra al menos un lote, devuelve el primer lote encontrado
    if (results.isNotEmpty) {
      // Asumiendo que tienes un constructor fromMap o similar para crear un objeto Lot desde un Map
      return Lot.fromJson(results.first);
    }

    // Devuelve null si no se encuentra ningún lote con ese nombre
    return null;
  }

  // *WAREHOUSE* //
  // Función para obtener un almacén específico por su ID
  Future<Warehouse> getWarehouse(int id) async {
    final List<Map<String, dynamic>> maps = await _database!.query(
      'warehouse',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      // Si encontramos el almacén, construimos y devolvemos un objeto Warehouse
      return Warehouse.fromMap(maps.first);
    } else {
      // Maneja el caso en que el almacén no se encuentra, por ejemplo, lanzando una excepción
      throw Exception('Warehouse not found');
    }
  }

  // Función para obtener todos los almacenes
  Future<List<Warehouse>> getAllWarehouses() async {
    final List<Map<String, dynamic>> maps = await _database!.query('warehouse');

    // Construye y devuelve una lista de objetos Warehouse a partir de los registros recuperados
    return List.generate(maps.length, (i) {
      return Warehouse.fromMap(maps[i]);
    });
  }

  Future<int> createWarehouse(Warehouse warehouse) async {
    final db = await _database;
    return await db!.insert(
      'warehouse',
      warehouse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateWarehouse(Warehouse warehouse) async {
    final db = await _database;
    return await db!.update(
      'warehouse',
      warehouse.toMap(),
      where: 'id = ?',
      whereArgs: [warehouse.id],
    );
  }

  Future<int> deleteWarehouse(int id) async {
    final db = await _database;
    return await db!.delete(
      'warehouse',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // *PRODUCT*//
  Future<int> insertProduct(Product product) async {
    final db =
        await database; // Asegúrate de que esta línea obtiene correctamente tu instancia de base de datos
    final id = await db.insert(
      'product',
      product
          .toJson(), // Asume que tienes un método toJson() que convierte el producto a un mapa
      conflictAlgorithm: ConflictAlgorithm
          .replace, // Usa replace para evitar conflictos si el producto ya existe
    );
    return id; // Devuelve el ID del producto insertado
  }

  Future<void> updateProduct(Product product) async {
    if (product.id == null) {
      throw ArgumentError("El lot debe tener un id para ser actualizado.");
    }
    final db = await database;
    await db.update(
      'product',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'product',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getAllProduct() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('product');

    // Convertir la List<Map<String, dynamic>> en una List<Lot>.
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        createDate: DateTime.parse(maps[i]['create_date']),
      );
    });
  }

  Future<List<Product>> getProductsByPalletsNotOutWithCount(int warehouseId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT product.*, COUNT(pallet.id) AS numPallets
      FROM product
      JOIN lot ON product.id = lot.product
      JOIN pallet_lot ON lot.id = pallet_lot.id_lot
      JOIN pallet ON pallet_lot.id_pallet = pallet.id
      WHERE pallet.is_out = 0 AND pallet.warehouse = ?
      GROUP BY product.id
    ''', [warehouseId]);

    return List.generate(maps.length, (i) {
      // Asumiendo que tienes un constructor que pueda manejar numPallets o ajusta según tu implementación
      return Product.fromJson({
        ...maps[i],
        'numPallets': maps[i]['numPallets'],
      });
    });
  }



  Future<Product?> findProductByName(String productName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'product',
      where: 'name = ?',
      whereArgs: [productName],
    );

    if (maps.isNotEmpty) {
      return Product.fromJson(maps.first);
    }

    return null;
  }

  //*PALLET*//

  Future<void> createPalletAndLinkToLot(Pallet pallet, int lotId) async {
    final db = await database;

    // Obtén un mapa del objeto Pallet y actualiza el campo 'create_date' con la fecha y hora actuales
    Map<String, dynamic> palletData = pallet.toJson();
    palletData['create_date'] = DateTime.now().toIso8601String(); // Añade o sobrescribe la fecha de creación

    // Inserta el pallet en la base de datos con la fecha de creación actualizada
    int palletId = await db.insert(
      'pallet',
      palletData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Inserta la relación entre el pallet y el lote en la tabla 'pallet_lot'
    await db.insert(
      'pallet_lot',
      {
        'id_pallet': palletId,
        'id_lot': lotId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> updatePallet(Pallet pallet) async {
    if (pallet.id == null) {
      throw ArgumentError("El pallet debe tener un id para ser actualizado.");
    }
    final db = await database;
    await db.update(
      'pallet',
      pallet.toJson(),
      where: 'id = ?',
      whereArgs: [pallet.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePallet(int id) async {
    final db = await database;
    await db.delete(
      'pallet',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Pallet>> getPalletsForLot(int lotId) async {
  final db = await database;
  final List<Map<String, dynamic>> palletLotMaps = await db.query(
    'pallet_lot',
    columns: ['id_pallet'],
    where: 'id_lot = ?',
    whereArgs: [lotId],
  );

  final List<int> palletIds =
      palletLotMaps.map((map) => map['id_pallet'] as int).toList();

  List<Pallet> pallets = [];
  for (var palletId in palletIds) {
    final List<Map<String, dynamic>> palletMaps = await db.query(
      'pallet',
      where: 'id = ? AND defective = 0',
      whereArgs: [palletId],
    );
    if (palletMaps.isNotEmpty) {
      pallets.add(Pallet.fromJson(palletMaps.first));
    }
  }

  return pallets;
}

Future<void> markPalletsAsOut(int lotId, int numberOfPalletsToMark, int warehouseId) async {
  final db = await database;
  List<Map<String, dynamic>> palletIds = await db.rawQuery('''
    SELECT p.id FROM pallet p
    JOIN pallet_lot pl ON p.id = pl.id_pallet
    WHERE pl.id_lot = ? AND p.is_out = 0 AND p.defective = 0 AND p.warehouse = ?
    ORDER BY p.id ASC
    LIMIT ?
  ''', [lotId, warehouseId, numberOfPalletsToMark]);

  String currentDateTime = DateTime.now().toIso8601String();

  for (var row in palletIds) {
    await db.update(
      'pallet',
      {
        'is_out': 1,
        'out_date': currentDateTime,
      },
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }
}

Future<void> markPalletsAsOutDefective(int lotId, int numberOfPalletsToMark, int warehouseId) async {
  final db = await database;
  List<Map<String, dynamic>> palletIds = await db.rawQuery('''
    SELECT p.id FROM pallet p
    JOIN pallet_lot pl ON p.id = pl.id_pallet
    WHERE pl.id_lot = ? AND p.is_out = 0 AND p.defective = 1 AND p.warehouse = ?
    ORDER BY p.id ASC
    LIMIT ?
  ''', [lotId, warehouseId, numberOfPalletsToMark]);

  String currentDateTime = DateTime.now().toIso8601String();

  for (var row in palletIds) {
    await db.update(
      'pallet',
      {
        'is_out': 1,
        'out_date': currentDateTime,
      },
      where: 'id = ?',
      whereArgs: [row['id']],
    );
  }
}

  Future<void> markPalletsAsDefectuous(int lotId, int numberOfPalletsToMark, int warehouseId) async {
    final db = await database;

    // Seleccionar los primeros N palets de ese lote que no están marcados como defectuosos y no están marcados como salidos
    List<Map<String, dynamic>> palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.defective = 0 AND p.is_out = 0 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPalletsToMark]);

    // Marcar esos palets como defectuosos
    for (var row in palletIds) {
      await db.update(
        'pallet',
        {
          'defective': 1,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
  }

  // Cerrar la base de datos
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
