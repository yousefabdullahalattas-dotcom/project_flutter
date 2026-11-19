import 'package:flutter/material.dart';

import 'data/OrderService.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen(this.userId, {super.key});

  final int userId;

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final OrderService orderService = OrderService();

  late Future<List<dynamic>> orders;

  @override
  void initState() {
    super.initState();
    orders = orderService.getMyOrders(widget.userId);
  }

  // "2026-11-13T03:03:05.23" -> "2026-11-13 03:03"
  String _formatDate(Object? raw) {
    final String text = raw?.toString() ?? '';
    if (text.length >= 16) {
      return text.substring(0, 16).replaceFirst('T', ' ');
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final order = list[index] as Map<String, dynamic>;
              final items = (order['items'] as List<dynamic>?) ?? [];

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order['id']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Status: ${order['status']}'),
                      Text('Date: ${_formatDate(order['createdAt'])}'),
                      Text(
                        'Total: ${order['totalAmount']} SAR',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ...items.map((raw) {
                        final item = raw as Map<String, dynamic>;
                        return Text(
                          '${item['productName']}  x${item['quantity']}  -  ${item['price']} SAR',
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
