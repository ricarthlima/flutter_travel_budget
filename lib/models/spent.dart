class Spent {
  String id;
  String idTravel;
  String name;
  double cost;
  DateTime createdAt;

  Spent({
    required this.id,
    required this.idTravel,
    required this.name,
    required this.cost,
    required this.createdAt,
  });

  Spent.fromMap(map)
      : id = map["id"],
        idTravel = map["id_travel"],
        name = map["name"],
        cost = map["cost"],
        createdAt = DateTime.parse(map["created_at"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_travel': idTravel,
      'name': name,
      'cost': cost,
      'created_at': createdAt.toString(),
    };
  }
}
