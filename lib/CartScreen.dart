import 'package:flutter/material.dart';

import 'data/CartService.dart';
import 'data/OrderService.dart';
import 'data/ConectionString.dart';

class CartScreen extends StatefulWidget {
  const CartScreen(this.userId, {super.key});

  final int userId;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService cartService = CartService();
  final OrderService orderService = OrderService();

  late Future<List<dynamic>> cartItems;
  bool isOrdering = false;

  @override
  void initState() {
    super.initState();
    cartItems = cartService.getCart(widget.userId);
  }

  void _reload() {
    setState(() {
      cartItems = cartService.getCart(widget.userId);
    });
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _removeItem(int productId) async {
    try {
      await cartService.removeFromCart(widget.userId, productId);
      _reload();
    } catch (e) {
      _showMessage('Error: $e');
    }
  }

  Future<void> _checkout() async {
    setState(() => isOrdering = true);
    try {
      final orderId = await orderService.makeOrder(widget.userId);
      if (orderId == null) {
        _showMessage('Cart is empty');
      } else {
        _showMessage('Order #$orderId created');
        _reload();
      }
    } catch (e) {
      _showMessage('Error: $e');
    } finally {
      if (mounted) setState(() => isOrdering = false);
    }
  }

  double _total(List<dynamic> items) {
    double total = 0;
    for (final item in items) {
      final map = item as Map<String, dynamic>;
      total += (map['price'] as num).toDouble() *
          (map['quantity'] as num).toInt();
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index] as Map<String, dynamic>;

                    final String imagePath = item['imageUrl']?.toString() ?? '';
                    final String imageUrl = imagePath.isEmpty
                        ? ''
                        : Uri.parse(ConectionString.dashboardUrl)
                            .resolve(imagePath)
                            .toString();

                    return Card(
                      child: ListTile(
                        leading: imageUrl.isEmpty
                            ? const Icon(Icons.image, size: 40)
                            : Image.network(
                                imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                        title: Text(item['productName']?.toString() ?? ''),
                        subtitle: Text(
                          'Qty: ${item['quantity']}  •  ${item['price']} SAR',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeItem(
                            (item['productId'] as num).toInt(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total: ${_total(items).toStringAsFixed(2)} SAR',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isOrdering ? null : _checkout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          isOrdering ? 'Placing order...' : 'Place order',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
