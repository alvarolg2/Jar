class Batch2 {
  final int? id;
  final String? name;
  final int? jarId;
  List<int>? palletIds = []; // Añade esto

  Batch2(
      {this.id,
      required this.name,
      required this.jarId,
      this.palletIds = const []});

  factory Batch2.fromMap(Map<String, dynamic> map) {
    return Batch2(
        id: map['id'],
        name: map['name'],
        jarId: map['jarId'],
        palletIds: map['palletIds']);
  }

  Map<String, dynamic> toMap() {
    // Este método probablemente no necesite cambios, ya que los IDs de los pallets no se almacenan con los lotes directamente
    return {
      'id': id,
      'name': name,
      'jar_id': jarId,
    };
  }

  // Considera añadir un método para facilitar la actualización de palletIds si es necesario
}
