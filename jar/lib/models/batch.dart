class Batch {
  final int? id;
  final String name;
  final int jarId;

  Batch({this.id, required this.name, required this.jarId});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'jar_id': jarId,
    };
  }
}
