import 'package:jar/models/product.dart';
import 'package:jar/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class ProductRepository {
  final _dbService = DatabaseService.instance;

  Future<int> insert(Product product) async {
    final db = await _dbService.database;
    return await db.insert('product', product.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Product product) async {
    final db = await _dbService.database;
    return await db.update('product', product.toMap(),
        where: 'id = ?', whereArgs: [product.id]);
  }

  Future<Product?> findByName(String name) async {
    final db = await _dbService.database;
    final maps = await db.query('product', where: 'name = ?', whereArgs: [name]);
    if (maps.isNotEmpty) return Product.fromJson(maps.first);
    return null;
  }

  Future<List<Product>> getNotOutWithCount(int warehouseId) async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT p.*, COUNT(pal.id) AS numPallets
      FROM product p
      JOIN lot l ON p.id = l.product
      JOIN pallet_lot pl ON l.id = pl.id_lot
      JOIN pallet pal ON pl.id_pallet = pal.id
      WHERE pal.is_out = 0 AND pal.defective = 0 AND pal.warehouse = ?
      GROUP BY p.id
      ORDER BY p.name ASC
    ''', [warehouseId]);
    return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
  }
}
