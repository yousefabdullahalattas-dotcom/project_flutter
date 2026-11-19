import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ConectionString.dart';

class CartService {

  Future<List<dynamic>> getCart(int userId) async {
    final response = await http.get(Uri.parse('${ConectionString.cart}/$userId'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load cart (${response.statusCode})');
  }


  Future<void> addToCart(int userId, int productId, int quantity) async {
    final response = await http.post(
      Uri.parse(ConectionString.cart),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart (${response.statusCode})');
    }
  }


  Future<void> removeFromCart(int userId, int productId) async {
    final response = await http.delete(
      Uri.parse('${ConectionString.cart}/$userId/$productId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart (${response.statusCode})');
    }
  }
}
