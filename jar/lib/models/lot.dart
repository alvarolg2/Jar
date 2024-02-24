import 'package:jar/models/product.dart';
import 'package:jar/models/pallet.dart';
import 'package:jar/models/warehouse.dart';

class Lot {
  final int? id;
  final String? name;
  final Warehouse? warehouse;
  final DateTime? createDate;
  final Product? product;
  final List<Pallet>? pallet;

  Lot({
    this.id,
    this.name,
    this.warehouse,
    this.createDate,
    this.product,
    this.pallet,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'warehouse': warehouse!.id!,
        /* 'create_date': createDate?.toIso8601String(), */
        'product': product!.id!,
      };

  factory Lot.fromJson(Map<String, dynamic> json) => Lot(
        id: json['id'],
        name: json['name'],
        warehouse: Warehouse(id: json['warehouse']),
        createDate: json['create_date'] != null
            ? DateTime.parse(json['create_date']).toLocal()
            : null,
        product: json['product'] != null ? Product.fromJson(json) : null,
      );

  Lot copyWith({List<Pallet>? pallet}) {
    return Lot(
      id: this.id,
      name: this.name,
      warehouse: this.warehouse,
      createDate: this.createDate,
      product: this.product,
      pallet: pallet ?? this.pallet,
    );
  }
}
