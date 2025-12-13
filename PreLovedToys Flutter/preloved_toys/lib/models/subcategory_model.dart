class SubCategory {
  final int id;
  final String name;
  final String image;
  final int categoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.categoryId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'] ?? '',
      image: json['image'] ?? 'https://via.placeholder.com/150',
      categoryId: json['categoryId'] ?? 0,
    );
  }
}
