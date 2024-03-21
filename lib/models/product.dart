class Product {
  final int? id;
  final String? name;
  final DateTime? createDate;

  Product({this.id, this.name, this.createDate});

  Map<String, dynamic> toJson() => {
        'name': name,
        /*  'create_date' : createDate */
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        createDate: json['create_date'] != null ? DateTime.parse(json['create_date']) : null,
      );
  @override
  bool operator ==(Object other) => identical(this, other) || other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
