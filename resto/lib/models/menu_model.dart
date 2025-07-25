class MenuItem {
  final int id;
  final String name;
  final String description;
  final int price;
  final String? imageUrl;
  final String preparationTime;
  final bool isAvailable;
  final String categoryName;
  final int categoryId;
  final List<SupplementAvec> supplementsAvec;
  final List<SupplementSans> supplementsSans;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    required this.preparationTime,
    required this.isAvailable,
    required this.categoryName,
    required this.categoryId,
    required this.supplementsAvec,
    required this.supplementsSans,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      imageUrl: json['image'],
      preparationTime: json['preparation_time'],
      isAvailable: json['is_available'],
      categoryName: json['category_name'],
      categoryId: json['category'],
      supplementsAvec: (json['supplements_avec'] as List)
          .map((e) => SupplementAvec.fromJson(e))
          .toList(),
      supplementsSans: (json['supplements_sans'] as List)
          .map((e) => SupplementSans.fromJson(e))
          .toList(),
    );
  }

  /// ✅ Affichage formaté du temps de préparation (ex: "12 minutes")
  String get formattedPreparationTime {
    try {
      final parts = preparationTime.split(':');
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final totalMinutes = hours * 60 + minutes;
      return "$totalMinutes minutes";
    } catch (_) {
      return preparationTime;
    }
  }
}

class SupplementAvec {
  final int id;
  final String name;
  final int price;

  SupplementAvec({required this.id, required this.name, required this.price});

  factory SupplementAvec.fromJson(Map<String, dynamic> json) {
    return SupplementAvec(
      id: json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}

class SupplementSans {
  final int id;
  final String name;

  SupplementSans({required this.id, required this.name});

  factory SupplementSans.fromJson(Map<String, dynamic> json) {
    return SupplementSans(id: json['id'], name: json['name']);
  }
}
