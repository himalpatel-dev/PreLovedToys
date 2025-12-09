class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final bool isPoints;
  final String condition;
  final String status;
  final List<String> images;
  final String? categoryName;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? sellerName;
  // --- NEW DETAILS ---
  final String? sellerMobile;
  final String? color;
  final String? material;
  final String? ageGroup;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isPoints,
    required this.condition,
    required this.status,
    required this.images,
    this.categoryName,
    this.createdAt,
    this.updatedAt,
    this.sellerName,
    // --- NEW ---
    this.sellerMobile,
    this.color,
    this.material,
    this.ageGroup,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    List<String> imgList = [];
    if (json['images'] != null) {
      for (var img in json['images']) {
        if (img['imageUrl'] != null) {
          imgList.add(img['imageUrl']);
        }
      }
    }

    String? catName;
    if (json['category'] != null && json['category']['name'] != null) {
      catName = json['category']['name'];
    }

    // --- PARSE NESTED OBJECTS ---
    String? seller;
    String? mobile;
    if (json['seller'] != null && json['seller'] is Map) {
      seller = json['seller']['name'];
      mobile = json['seller']['mobile'];
    }

    String? colorName;
    if (json['color'] != null && json['color'] is Map) {
      colorName = json['color']['name'];
    }

    String? matName;
    if (json['material'] != null && json['material'] is Map) {
      matName = json['material']['name'];
    }

    String? ageName;
    if (json['ageGroup'] != null && json['ageGroup'] is Map) {
      ageName = json['ageGroup']['name'];
    }

    return Product(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      price: parsedPrice,
      isPoints: json['isPoints'] ?? false,
      condition: json['condition'] ?? 'Good',
      status: json['status'] ?? 'active',
      images: imgList,
      categoryName: catName,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      sellerName: seller,
      sellerMobile: mobile,
      color: colorName,
      material: matName,
      ageGroup: ageName,
    );
  }
}
