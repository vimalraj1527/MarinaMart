class OrderModel {
  final String id;
  final String orderNumber;
  final String customerName;
  final String customerPhone;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final List<OrderItem> items;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerName,
    required this.customerPhone,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.items,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      String dateStr = (json['createdAt'] ?? '').toString();
      if (dateStr.isNotEmpty) {
        // Force treat as UTC if no timezone offset or Z suffix is present
        final hasTimezone = dateStr.endsWith('Z') || RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(dateStr);
        if (!hasTimezone) {
          dateStr = '${dateStr}Z';
        }
        parsedDate = DateTime.parse(dateStr).toUtc();
      } else {
        parsedDate = DateTime.now().toUtc();
      }
    } catch (e) {
      parsedDate = DateTime.now().toUtc();
    }

    return OrderModel(
      id: (json['id'] ?? '').toString(),
      orderNumber: (json['orderNumber'] ?? '').toString(),
      customerName: (json['customerName'] ?? 'Customer').toString(),
      customerPhone: (json['customerPhone'] ?? '').toString(),
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      status: (json['status'] ?? 'Pending').toString(),
      deliveryAddress: (json['deliveryAddress'] ?? '').toString(),
      items: (json['items'] as List?)?.map((i) {
        try {
           return OrderItem.fromJson(i as Map<String, dynamic>);
        } catch (e) {
           return OrderItem(productId: '', productName: 'Unknown Item', quantity: 0, price: 0);
        }
      }).toList() ?? [],
      createdAt: parsedDate,
    );
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({required this.productId, required this.productName, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: (json['productId'] ?? json['product_id'] ?? '').toString(),
      productName: (json['productName'] ?? json['product_name'] ?? json['name'] ?? 'Product').toString(),
      quantity: (json['quantity'] is num) ? json['quantity'].toInt() : 0,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
    );
  }
}
