class Warehouse {
  final int? id;
  final String? address;
  String? name;
  final DateTime? createDate;

  Warehouse({this.id, this.address, this.name, this.createDate});

  factory Warehouse.fromMap(Map<String, dynamic> map) {
    return Warehouse(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      createDate: map['create_date'] != null
          ? DateTime.parse(map['create_date'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'address': address,
      'name': name,
    };
  }
}
