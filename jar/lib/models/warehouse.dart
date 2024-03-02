class Warehouse {
  final int? id;
  final String? address;
  String? name;

  Warehouse({this.id, this.address, this.name});

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(id: map['id'], name: map['name'], address: map['address']);
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'name': name,
    };
  }
}
