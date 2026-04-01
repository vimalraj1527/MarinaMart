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

    // Get the first image from the images list
    String imageUrl = '';
    if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      imageUrl = json['images'][0];
    } else if (json['image'] != null) {
      imageUrl = json['image'];
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: parsedPrice,
      unit: json['unit'] ?? 'pcs',
      image: imageUrl,
      description: json['description'],
    );
  }
}
