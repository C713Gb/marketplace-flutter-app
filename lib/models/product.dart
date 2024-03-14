class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String sellerName;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.sellerName,
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
