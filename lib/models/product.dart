import 'dart:convert';

class Product {
  final String id;
  final String name;
  final String price;
  final String description;
  final String categoryName;
  final List<String> images;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.categoryName,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      price: json["price"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      categoryName: json["category_name"]?.toString() ?? "",
      images: _parseImages(json["image"]),
    );
  }

  static List<String> _parseImages(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }

    final text = value.toString();
    if (text.isEmpty) return [];

    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return [text];
  }
}
