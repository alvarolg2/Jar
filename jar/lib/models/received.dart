class Received {
  final int id;
  final String date;
  final int warehouseId;
  final int userId;
  final int? jarId;
  final int? batchId;

  Received(
      {required this.id,
      required this.date,
      required this.warehouseId,
      required this.userId,
      this.jarId,
      this.batchId});

  factory Received.fromMap(Map<String, dynamic> map) {
    return Received(
      id: map['id'],
      date: map['date'],
      warehouseId: map['warehouse_id'],
      userId: map['user_id'],
      jarId: map['jar_id'],
      batchId: map['batch_id'],
    );
  }
}
