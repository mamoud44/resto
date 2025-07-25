class HomMenu {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final String preparationTime;

  HomMenu({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.preparationTime,
  });

  factory HomMenu.fromJson(Map<String, dynamic> json) {
    return HomMenu(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image'],
      preparationTime: json['preparation_time'],
    );
  }
}
