import 'product_model.dart';

class CartItem {
  final int id;
  final int quantity;
  final int userId;
  final int productId;
  final Product product;

  // UI State (Not from API, but needed for checkboxes)
  bool isSelected;

  CartItem({
    required this.id,
    required this.quantity,
    required this.userId,
    required this.productId,
    required this.product,
    this.isSelected = true, // Default to selected
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      quantity: json['quantity'] ?? 1,
      userId: json['userId'],
      productId: json['productId'],
      // Parse nested product
      product: Product.fromJson(json['product']),
    );
  }
}
