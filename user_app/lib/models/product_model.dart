class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String image;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.image,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      image: json['image'] ?? '',
      description: json['description'],
    );
  }
}
