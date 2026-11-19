import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ConectionString.dart';

class ProductService {
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse(ConectionString.products));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception('Failed to load products (${response.statusCode})');
  }
}
