import 'package:flutter/material.dart';

import 'data/CartService.dart';
import 'data/ConectionString.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen(this.product, this.userId, {super.key});

  final Map<String, dynamic> product;
  final int userId;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CartService cartService = CartService();

  int quantity = 1;
  bool isAdding = false;

  Future<void> _addToCart() async {
    setState(() => isAdding = true);
    try {
      final productId = (widget.product['id'] as num).toInt();
      await cartService.addToCart(widget.userId, productId, quantity);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to cart')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => isAdding = false);
    }
  }

  Widget _row(String label, Object? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text('${value ?? '-'}')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final String imagePath = product['imageUrl']?.toString() ?? '';
    final String imageUrl = imagePath.isEmpty
        ? ''
        : Uri.parse(ConectionString.dashboardUrl).resolve(imagePath).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(product['productName']?.toString() ?? 'Product'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  height: 260,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported, size: 80),
                ),
              ),
            const SizedBox(height: 16),
            _row('Type', product['type']),
            _row('Power (W)', product['powerWatt']),
            _row('Price', product['price']),
            _row('Stock', product['stockQuantity']),
            _row('Supplier', product['supplierName']),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: quantity > 1
                      ? () => setState(() => quantity--)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Text('$quantity', style: const TextStyle(fontSize: 18)),
                IconButton(
                  onPressed: () => setState(() => quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isAdding ? null : _addToCart,
                icon: const Icon(Icons.shopping_cart),
                label: Text(isAdding ? 'Adding...' : 'Add to cart'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
