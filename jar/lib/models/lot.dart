import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';

class Lot {
  final int? id;
  final String? name;
  final DateTime? createDate;
  final Product? product;
  final List<Pallet>? pallet;

  Lot({
    this.id,
    this.name,
    this.createDate,
    this.product,
    this.pallet,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        /* 'create_date': createDate?.toIso8601String(), */
        'product': product!.id!,
      };

  factory Lot.fromJson(Map<String, dynamic> json) => Lot(
        id: json['id'],
        name: json['name'],
        createDate: json['create_date'] != null
            ? DateTime.parse(json['create_date']).toLocal()
            : null,
        product: json['product'] != null ? Product.fromJson(json) : null,
      );

  Lot copyWith({List<Pallet>? pallet}) {
    return Lot(
      id: this.id,
      name: this.name,
      createDate: this.createDate,
      product: this.product,
      pallet: pallet ?? this.pallet,
    );
  }
}
