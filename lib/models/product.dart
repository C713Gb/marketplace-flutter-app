class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String sellerName; // Assuming this field is added

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sellerName, // Initialize in constructor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      sellerName: json['seller']['username'],
    );
  }
}
