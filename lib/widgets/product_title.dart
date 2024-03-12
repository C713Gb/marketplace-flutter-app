import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductTitle extends StatelessWidget {
  final Product product;

  const ProductTitle({required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text(product.description),
      trailing: Text('\$${product.price}'),
    );
  }
}
