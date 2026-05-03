import 'package:jar/models/warehouse.dart';
import 'package:jar/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class WarehouseRepository {
  final _dbService = DatabaseService.instance;

  Future<int> create(Warehouse warehouse) async {
    final db = await _dbService.database;
    return await db.insert('warehouse', warehouse.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> update(Warehouse warehouse) async {
    final db = await _dbService.database;
    return await db.update('warehouse', warehouse.toMap(),
        where: 'id = ?', whereArgs: [warehouse.id]);
  }

  Future<int> delete(int id) async {
    final db = await _dbService.database;
    return await db.delete('warehouse', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Warehouse>> getAll() async {
    final db = await _dbService.database;
    final maps = await db.query('warehouse', orderBy: 'name ASC');
    return List.generate(maps.length, (i) => Warehouse.fromMap(maps[i]));
  }
}
