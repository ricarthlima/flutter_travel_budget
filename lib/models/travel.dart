class Travel {
  String id;
  String name;
  double budget;
  DateTime startDate;
  DateTime endDate;

  Travel({
    required this.id,
    required this.name,
    required this.budget,
    required this.startDate,
    required this.endDate,
  });

  Travel.fromMap(map)
      : id = map["id"],
        name = map["name"],
        budget = map["budget"],
        startDate = DateTime.parse(map["start_date"]),
        endDate = DateTime.parse(map["end_date"]);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'budget': budget,
      'start_date': startDate.toString(),
      'end_date': endDate.toString(),
    };
  }
}
