import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';
  final storage = FlutterSecureStorage();

  Future<String> register(
      String username, String email, String password, String role) async {
    final url = Uri.parse('$_baseUrl/register');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final accessToken = responseBody['access_token'];
      final refreshToken = responseBody['refresh_token'];
      // Save the tokens
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
      return "Registration successful";
    } else {
      // Attempt to parse the response body to extract the detail message
      try {
        final Map<String, dynamic> decodedBody = json.decode(response.body);
        return decodedBody['detail'] ?? "Unknown error occurred";
      } catch (e) {
        return "Failed to parse error message";
      }
    }
  }

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/token');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final accessToken = responseBody['access_token'];
      final refreshToken = responseBody['refresh_token'];
      // Save the tokens
      await storage.write(key: 'access_token', value: accessToken);
      await storage.write(key: 'refresh_token', value: refreshToken);
      return true;
    } else {
      // Error handling
      print('Failed to log in: ${response.body}');
      return false;
    }
  }

  Future<Map<String, String>> getSavedTokens() async {
    final accessToken = await storage.read(key: 'access_token');
    final refreshToken = await storage.read(key: 'refresh_token');
    return {
      'access_token': accessToken ?? '',
      'refresh_token': refreshToken ?? '',
    };
  }

  // Additional method to check if the user is logged in (has tokens saved)
  Future<bool> isLoggedIn() async {
    final accessToken = await storage.read(key: 'access_token');
    return accessToken != null;
  }

  Future<String?> getToken() async {
    try {
      // Read value
      String? token = await storage.read(key: 'access_token');
      return token;
    } catch (e) {
      print('Error retrieving access token: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<void> saveCurrentUser(String userId, String username) async {
    await storage.write(key: 'userId', value: userId);
    await storage.write(key: 'username', value: username);
  }

  Future<String?> getCurrentUserId() async {
    return await storage.read(key: "userId");
  }
}
