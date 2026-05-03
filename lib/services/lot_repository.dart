import 'package:jar/models/lot.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/product.dart';
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
      SELECT l.*, p.id AS productId, p.name AS productName, p.description AS productDescription, p.create_date AS productCreateDate      FROM lot l
      JOIN product p ON l.product = p.id
      WHERE l.id IN ($subQuery)
      ORDER BY l.create_date DESC
    ''';
    final maps = await db.rawQuery(mainQuery, subQueryParams);

    List<Lot> lots = [];
    for (var map in maps) {
      final product = Product.fromJson({
        'id': map['productId'],
        'name': map['productName'],
        'description': map['productDescription'],
        'create_date': map['productCreateDate'],
      });
      var lot = Lot(
        id: map['id'] as int?,
        name: map['name'] as String?,
        createDate: DateTime.parse(map['create_date'] as String),
        product: product,
        pallet: [],
      );
      final palletMaps = await db.rawQuery('''
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
}
