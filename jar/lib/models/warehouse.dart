class Warehouse {
  final int? id;
  final String? address;
  final String name;

  Warehouse({this.id, this.address, required this.name});

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(id: map['id'], name: map['name'], address: map['address']);
  }

  Map<String, dynamic> toMap() {
    return {
      'location': address,
      'name': name,
    };
  }
}
