class Jar {
  final int? id;
  final String name;

  Jar({this.id, required this.name});

  factory Jar.fromMap(Map<String, dynamic> map) {
    return Jar(id: map['id'], name: map['name']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}
