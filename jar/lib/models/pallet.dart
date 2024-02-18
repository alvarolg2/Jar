class Pallet {
  final int? id;
  final int batchId;
  final String number;

  Pallet({this.id, required this.batchId, required this.number});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'batch_id': batchId,
      'number': number,
    };
  }
}
