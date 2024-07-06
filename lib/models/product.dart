class Product {
  final int? id;
  final String? name;
  final DateTime? createDate;
  final int? numPallets; // Nueva propiedad para almacenar el número de pallets

  Product({this.id, this.name, this.createDate, this.numPallets});


  Map<String, dynamic> toJson() => {
        'name': name,
        /*  'create_date' : createDate */
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
      id: json['id'],
      name: json['name'],
      createDate: json['create_date'] != null ? DateTime.parse(json['create_date']) : null,
      numPallets: json['numPallets'], 
    );

  @override
  bool operator ==(Object other) => identical(this, other) || other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
