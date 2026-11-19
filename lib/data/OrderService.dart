import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ConectionString.dart';

class OrderService {

  Future<int?> makeOrder(int userId) async {
    final response = await http.post(
      Uri.parse('${ConectionString.orders}/$userId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return (data['orderId'] as num).toInt();
    }
    if (response.statusCode == 400) {
      return null;
    }
    throw Exception('Failed to create order (${response.statusCode})');
  }

  Future<List<dynamic>> getMyOrders(int userId) async {
    final response = await http.get(
      Uri.parse('${ConectionString.orders}/user/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load orders (${response.statusCode})');
  }
}
