import 'dart:convert';

import 'package:http/http.dart' as http;

import 'ConectionString.dart';

class UserService {
  Future<Map<String, dynamic>?> login(String username, String password) async {
    final body = jsonEncode({'username': username, 'password': password});

    final response = await http.post(
      Uri.parse(ConectionString.login),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      return null;
    }
    if (response.statusCode == 403) {
      throw Exception('This user is locked');
    }
    throw Exception('Login failed (${response.statusCode})');
  }

  Future<Map<String, dynamic>?> register(
    String name,
    String email,
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse(ConectionString.register),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 409) {
      return null;
    }
    throw Exception('Registration failed (${response.statusCode})');
  }
}
