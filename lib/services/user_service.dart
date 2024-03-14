import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';

class UserService {
  final String _baseUrl = dotenv.env['API_URL'] ?? "http://127.0.0.1:8000";

  Future<User?> getCurrentUser(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      print('Failed to fetch current user: ${response.body}');
      return null;
    }
  }
}
