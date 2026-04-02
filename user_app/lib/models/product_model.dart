import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String image;
  final String? description;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.image,
    this.description,
    this.isAvailable = true,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Robust price parsing
    double parsedPrice;
    var priceValue = json['price'];
    if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    } else if (priceValue is num) {
      parsedPrice = priceValue.toDouble();
    } else {
      parsedPrice = 0.0;
    }

    // Image URL determination
    String imageUrl = '';
    if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      imageUrl = json['images'][0];
    } else if (json['image'] != null && json['image'] is String) {
      imageUrl = json['image'];
    }
    
    // We maintain 'localhost' URLs as-is to support physical devices with 'adb reverse'
    // as requested for the user's Motorola device environment.

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'Catalogue Product',
      category: json['category'] ?? 'Uncategorized',
      price: parsedPrice,
      unit: json['unit'] ?? 'pcs',
      image: imageUrl,
      description: json['description'],
      isAvailable: json['isAvailable'] ?? true,
    );
  }
}
