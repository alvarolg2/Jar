import 'package:jar/models/pallet.dart';
import 'package:jar/models/report_item.dart';
import 'package:jar/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

class PalletRepository {
  final _dbService = DatabaseService.instance;

  Future<void> createAndLinkToLot(Pallet pallet, int lotId) async {
    final db = await _dbService.database;
    Map<String, dynamic> palletData = pallet.toJson();
    palletData['create_date'] = DateTime.now().toIso8601String();
    int palletId = await db.insert('pallet', palletData,
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('pallet_lot', {'id_pallet': palletId, 'id_lot': lotId},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> markAsOut(int lotId, int numberOfPallets, int warehouseId) async {
    final db = await _dbService.database;
    final palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.is_out = 0 AND p.defective = 0 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPallets]);
    for (var row in palletIds) {
      await db.update(
          'pallet', {'is_out': 1, 'out_date': DateTime.now().toIso8601String()},
          where: 'id = ?', whereArgs: [row['id']]);
    }
  }

  Future<void> markAsDefectuous(int lotId, int numberOfPallets, int warehouseId) async {
    final db = await _dbService.database;
    final palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.defective = 0 AND p.is_out = 0 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPallets]);
    for (var row in palletIds) {
      await db.update('pallet', {'defective': 1},
          where: 'id = ?', whereArgs: [row['id']]);
    }
  }

  Future<void> markAsOutDefective(int lotId, int numberOfPallets, int warehouseId) async {
    final db = await _dbService.database;
    final palletIds = await db.rawQuery('''
      SELECT p.id FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      WHERE pl.id_lot = ? AND p.is_out = 0 AND p.defective = 1 AND p.warehouse = ?
      ORDER BY p.id ASC
      LIMIT ?
    ''', [lotId, warehouseId, numberOfPallets]);
    for (var row in palletIds) {
      await db.update(
          'pallet', {'is_out': 1, 'out_date': DateTime.now().toIso8601String()},
          where: 'id = ?', whereArgs: [row['id']]);
    }
  }

  Future<Map<int, int>> getAllWarehousePalletCounts({required bool isDefective}) async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT warehouse, COUNT(id) as count
      FROM pallet
      WHERE is_out = 0 AND defective = ?
      GROUP BY warehouse
    ''', [isDefective ? 1 : 0]);
    return {for (var map in maps) map['warehouse'] as int: map['count'] as int};
  }

  Future<List<WarehouseReportItem>> getReportItems({required bool isDefective}) async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT
          w.name AS warehouseName,
          p.name AS productName,
          l.name AS lotName,
          COUNT(pal.id) AS palletCount
      FROM pallet pal
      JOIN warehouse w ON pal.warehouse = w.id
      JOIN pallet_lot pl ON pal.id = pl.id_pallet
      JOIN lot l ON pl.id_lot = l.id
      JOIN product p ON l.product = p.id
      WHERE pal.is_out = 0 AND pal.defective = ?
      GROUP BY w.id, p.id, l.id
      ORDER BY w.name, p.name, l.name;
    ''', [isDefective ? 1 : 0]);

    if (maps.isEmpty) return [];

    return maps.map((map) {
      return WarehouseReportItem(
        warehouseName: map['warehouseName'] as String,
        productName: map['productName'] as String,
        lotName: map['lotName'] as String,
        palletCount: map['palletCount'] as int,
      );
    }).toList();
  }

  Future<Map<String, int>> getGlobalStats() async {
    final db = await _dbService.database;
    final totalIn = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM pallet WHERE is_out = 0 AND defective = 0'));
    final totalOut = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM pallet WHERE is_out = 1'));
    final totalDefective = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM pallet WHERE defective = 1 AND is_out = 0'));

    return {
      'totalIn': totalIn ?? 0,
      'totalOut': totalOut ?? 0,
      'totalDefective': totalDefective ?? 0,
    };
  }

  Future<int> getDefectiveLast30Days() async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    final startDateStr = startDate.toIso8601String();
    final result = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM pallet WHERE defective = 1 AND create_date >= ?',
        [startDateStr]));
    return result ?? 0;
  }

  Future<List<Map<String, dynamic>>> getWarehouseDistribution() async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT w.name as warehouseName, COUNT(p.id) as count
      FROM pallet p
      JOIN warehouse w ON p.warehouse = w.id
      WHERE p.is_out = 0 AND p.defective = 0
      GROUP BY w.id
    ''');
  }

  Future<List<Map<String, dynamic>>> getTopProducts(int limit) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT pr.name as productName, pr.description as description, COUNT(DISTINCT p.id) as count
      FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      JOIN lot l ON pl.id_lot = l.id
      JOIN product pr ON l.product = pr.id
      WHERE p.is_out = 0 AND p.defective = 0
      GROUP BY pr.id
      ORDER BY count DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getMovementStats(int days) async {
    final db = await _dbService.database;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    final startDateStr = startDate.toIso8601String();

    final results = await db.rawQuery('''
      SELECT date(create_date) as date, 'in' as type, COUNT(*) as count
      FROM pallet
      WHERE create_date >= ? AND defective = 0
      GROUP BY date(create_date)

      UNION ALL

      SELECT date(out_date) as date, 'out' as type, COUNT(*) as count
      FROM pallet
      WHERE out_date >= ? AND is_out = 1
      GROUP BY date(out_date)
      
      ORDER BY date ASC
    ''', [startDateStr, startDateStr]);

    final Map<String, int> inData = {};
    final Map<String, int> outData = {};

    for (final row in results) {
      final date = row['date'] as String?;
      if (date == null) continue;

      final type = row['type'] as String;
      final count = row['count'] as int;

      if (type == 'in') {
        inData[date] = count;
      } else {
        outData[date] = count;
      }
    }

    final List<Map<String, dynamic>> filledData = [];
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: days - 1 - i));
      final dateStr = date.toIso8601String().split('T').first;

      filledData.add({
        'date': dateStr,
        'type': 'in',
        'count': inData[dateStr] ?? 0,
      });
      filledData.add({
        'date': dateStr,
        'type': 'out',
        'count': outData[dateStr] ?? 0,
      });
    }

    return filledData;
  }

  Future<int> getActiveProductsCount() async {
    final db = await _dbService.database;
    final result = Sqflite.firstIntValue(await db.rawQuery('''
      SELECT COUNT(DISTINCT pr.id)
      FROM product pr
      JOIN lot l ON l.product = pr.id
      JOIN pallet_lot pl ON pl.id_lot = l.id
      JOIN pallet p ON p.id = pl.id_pallet
      WHERE p.is_out = 0 AND p.defective = 0
    '''));
    return result ?? 0;
  }

  Future<List<Map<String, dynamic>>> getRecentLotActivity(int limit) async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT
        date(MAX(p.create_date)) as date,
        'in' as type,
        pr.name as productName,
        w.name as warehouseName,
        COUNT(p.id) as palletCount
      FROM pallet p
      JOIN pallet_lot pl ON p.id = pl.id_pallet
      JOIN lot l ON pl.id_lot = l.id
      JOIN product pr ON l.product = pr.id
      JOIN warehouse w ON p.warehouse = w.id
      WHERE p.defective = 0 AND p.is_out = 0
      GROUP BY date(p.create_date), pr.name, w.name
      ORDER BY date DESC, palletCount DESC
      LIMIT ?
    ''', [limit]);
  }

  Future<List<Map<String, dynamic>>> getWarehouseOccupancy() async {
    final db = await _dbService.database;
    return await db.rawQuery('''
      SELECT
        w.name as warehouseName,
        COUNT(p.id) as count,
        ROUND(COUNT(p.id) * 100.0 / (SELECT COUNT(*) FROM pallet WHERE is_out = 0 AND defective = 0), 1) as percentage
      FROM pallet p
      JOIN warehouse w ON p.warehouse = w.id
      WHERE p.is_out = 0 AND p.defective = 0
      GROUP BY w.id
      ORDER BY count DESC
    ''');
  }
}
