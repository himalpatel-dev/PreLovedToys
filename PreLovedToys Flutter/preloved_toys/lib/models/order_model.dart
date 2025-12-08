import 'product_model.dart';

class OrderModel {
  final int id;
  final double totalAmount;
  final String status; // placed, shipped, etc.
  final String paymentStatus;
  final bool isPoints;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.isPoints,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<OrderItem> itemsList = list.map((i) => OrderItem.fromJson(i)).toList();

    return OrderModel(
      id: json['id'],
      totalAmount: double.tryParse(json['totalAmount'].toString()) ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      isPoints: json['isPoints'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      items: itemsList,
    );
  }
}

class OrderItem {
  final int id;
  final int quantity;
  final double priceAtPurchase;
  final Product product;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.priceAtPurchase,
    required this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      quantity: json['quantity'] ?? 1,
      priceAtPurchase:
          double.tryParse(json['priceAtPurchase'].toString()) ?? 0.0,
      product: Product.fromJson(json['product']),
    );
  }
}
