import 'package:jar/models/lot.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/product.dart';
import 'package:jar/models/warehouse.dart';
import 'package:jar/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class LotRepository {
  final _dbService = DatabaseService.instance;

  Future<int> insert(Lot lot) async {
    final db = await _dbService.database;
    return await db.insert('lot', lot.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<Lot?> findByName(String name) async {
    final db = await _dbService.database;
    final results = await db.query('lot', where: 'name = ?', whereArgs: [name]);
    if (results.isNotEmpty) return Lot.fromJson(results.first);
    return null;
  }

  Future<List<Lot>> getWithPallets({
    required int warehouseId,
    required bool isDefective,
    int? productId,
  }) async {
    final db = await _dbService.database;

    String whereClause = '''
      WHERE pal.warehouse = ? AND pal.is_out = 0 AND pal.defective = ?
    ''';
    List<dynamic> queryParams = [warehouseId, isDefective ? 1 : 0];

    if (productId != null) {
      whereClause += ' AND l.product = ?';
      queryParams.add(productId);
    }

    final query = '''
      SELECT 
        l.id AS lotId, l.name AS lotName, l.create_date AS lotCreateDate,
        p.id AS productId, p.name AS productName, p.description AS productDescription, p.create_date AS productCreateDate,
        pal.id AS palletId, pal.name AS palletName, pal.warehouse AS palletWarehouse, 
        pal.create_date AS palletCreateDate, pal.out_date AS palletOutDate, pal.date AS palletDate,
        pal.is_out AS palletIsOut, pal.defective AS palletDefective
      FROM lot l
      JOIN product p ON l.product = p.id
      JOIN pallet_lot pl ON l.id = pl.id_lot
      JOIN pallet pal ON pl.id_pallet = pal.id
      $whereClause
      ORDER BY l.create_date DESC, pal.id ASC
    ''';

    final results = await db.rawQuery(query, queryParams);

    final Map<int, Lot> lotsMap = {};

    for (final row in results) {
      final lotId = row['lotId'] as int;

      if (!lotsMap.containsKey(lotId)) {
        final product = Product(
          id: row['productId'] as int?,
          name: row['productName'] as String?,
          description: row['productDescription'] as String?,
        );

        lotsMap[lotId] = Lot(
          id: lotId,
          name: row['lotName'] as String?,
          createDate: row['lotCreateDate'] != null
              ? DateTime.parse(row['lotCreateDate'] as String).toLocal()
              : null,
          product: product,
          pallet: [],
        );
      }

      final pallet = Pallet(
        id: row['palletId'] as int?,
        name: row['palletName'] as String?,
        warehouse: Warehouse(id: row['palletWarehouse'] as int?),
        createDate: row['palletCreateDate'] != null
            ? DateTime.parse(row['palletCreateDate'] as String)
            : null,
        outDate: row['palletOutDate'] != null
            ? DateTime.parse(row['palletOutDate'] as String)
            : null,
        date: row['palletDate'] != null
            ? DateTime.parse(row['palletDate'] as String)
            : null,
        isOut: (row['palletIsOut'] as int) == 1,
        defective: (row['palletDefective'] as int) == 1,
      );

      lotsMap[lotId]!.pallet!.add(pallet);
    }

    return lotsMap.values.toList();
  }
}
