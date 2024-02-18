class Received {
  final int? id;
  final String? date;
  final int? warehouseId;
  final int? userId;

  Received({this.id, this.date, this.warehouseId, this.userId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'warehouse_id': warehouseId,
      'user_id': userId,
    };
  }
}
