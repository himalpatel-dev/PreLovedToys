class AgeGroup {
  final int id;
  final String name;

  AgeGroup({required this.id, required this.name});

  factory AgeGroup.fromJson(Map<String, dynamic> json) {
    return AgeGroup(id: json['id'], name: json['name']);
  }
}

class Gender {
  final int id;
  final String name;

  Gender({required this.id, required this.name});

  factory Gender.fromJson(Map<String, dynamic> json) {
    return Gender(id: json['id'], name: json['name']);
  }
}

class ColorItem {
  final int id;
  final String name;
  final String? hexCode;

  ColorItem({required this.id, required this.name, this.hexCode});

  factory ColorItem.fromJson(Map<String, dynamic> json) {
    return ColorItem(
      id: json['id'],
      name: json['name'],
      hexCode: json['hexCode'],
    );
  }
}

class MaterialItem {
  final int id;
  final String name;

  MaterialItem({required this.id, required this.name});

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(id: json['id'], name: json['name']);
  }
}

class ConditionItem {
  final String id; // value to send to backend e.g. 'new', 'used'
  final String name; // Display name

  ConditionItem({required this.id, required this.name});
}
