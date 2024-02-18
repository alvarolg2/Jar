class Jar {
  final int? id;
  final String name;

  Jar({this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
