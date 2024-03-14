import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_details_screen.dart'; // Make sure to import ProductDetailsScreen

class ProductTitle extends StatelessWidget {
  final Product product;

  const ProductTitle({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to ProductDetailsScreen on tap
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product)),
        );
      },
      child: ListTile(
        title: Text(product.name),
        subtitle: Text(product.description),
        trailing: Text('\$${product.price}'),
      ),
    );
  }
}
