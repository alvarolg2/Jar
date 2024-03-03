import 'package:jar/models/warehouse.dart';

class Pallet {
  final int? id;
  final String? name;
  final Warehouse? warehouse;
  final DateTime? createDate;
  final DateTime? outDate;
  final DateTime? date;
  final bool? isOut;

  Pallet({
    this.id,
    this.name,
    this.warehouse,
    this.createDate,
    this.outDate,
    this.date,
    this.isOut,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name, // Añadido lotId al mapa
        'warehouse': warehouse!.id!,
        'create_date': createDate?.toIso8601String(),
        'out_date': outDate?.toIso8601String(),
        'date': date?.toIso8601String(),
        'is_out': isOut ?? false ? 1 : 0,
      };

  factory Pallet.fromJson(Map<String, dynamic> json) => Pallet(
        id: json['id'],
        name: json['name'], // Añadido lotId a partir del JSON
        warehouse: Warehouse(id: json['warehouse']),
        createDate: json['create_date'] != null
            ? DateTime.parse(json['create_date'])
            : null,
        outDate:
            json['out_date'] != null ? DateTime.parse(json['out_date']) : null,
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        isOut: json['is_out'] == 1 ? true : false,
      );
}
