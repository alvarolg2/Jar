class Travel {
  final int? id;
  final String? date;
  final int batchId;
  final int palletId;
  final int warehouseId;

  Travel(
      {this.id,
      this.date,
      required this.batchId,
      required this.palletId,
      required this.warehouseId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'batch_id': batchId,
      'pallet_id': palletId,
      'warehouse_id': warehouseId,
    };
  }
}
