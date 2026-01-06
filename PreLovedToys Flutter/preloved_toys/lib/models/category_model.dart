import '../utils/constants.dart';

class Category {
  final int id;
  final String name;
  final String? image; // URL to the category icon
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.image,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    String? img = json['image'];
    if (img != null && img.isNotEmpty && !img.startsWith('http')) {
      img = '${Constants.imageBaseUrl}$img';
    }

    return Category(
      id: json['id'],
      name: json['name'],
      // Handle null images safely
      image: img,
      isActive: json['isActive'] ?? true,
    );
  }
}
