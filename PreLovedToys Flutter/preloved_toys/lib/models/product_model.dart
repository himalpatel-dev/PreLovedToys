class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final bool isPoints; // True = Coins, False = Rupees
  final String condition; // New, Like New, etc.
  final String status; // active, sold, etc.
  final List<String> images; // We will store just the URLs here for easy UI use
  final String? categoryName; // Optional: specific to how your API sends data

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
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // 1. Safely handle the Price (Database sends it as String/Decimal, Flutter needs Double)
    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    // 2. Extract Images safely
    // Your backend sends: { "images": [ { "imageUrl": "http...", "isPrimary": true } ] }
    List<String> imgList = [];
    if (json['images'] != null) {
      for (var img in json['images']) {
        if (img['imageUrl'] != null) {
          imgList.add(img['imageUrl']);
        }
      }
    }

    // 3. Extract Category Name if it exists
    String? catName;
    if (json['category'] != null && json['category']['name'] != null) {
      catName = json['category']['name'];
    }

    return Product(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      price: parsedPrice,
      isPoints: json['isPoints'] ?? false, // Default to real money if missing
      condition: json['condition'] ?? 'Good',
      status: json['status'] ?? 'active',
      images: imgList,
      categoryName: catName,
    );
  }
}
