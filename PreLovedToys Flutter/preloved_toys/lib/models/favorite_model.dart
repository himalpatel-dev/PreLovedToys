import 'product_model.dart';

class Favorite {
  final int id;
  final int userId;
  final int productId;
  final Product product;

  Favorite({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      // Reuse your existing Product logic to parse the nested product
      product: Product.fromJson(json['product']),
    );
  }
}
