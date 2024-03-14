import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/bid.dart';

class BidService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';

  Future<Bid?> createBid(String productId, double amount, String token) async {
    // print(token);
    // print(amount);
    // print(productId);
    // return null;
    final url = Uri.parse('$_baseUrl/bids/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      return Bid.fromJson(json.decode(response.body));
    } else {
      print('Failed to create bid: ${response.body}');
      return null;
    }
  }

  Future<Bid?> getLatestBidForProduct(String productId, String token) async {
    final url = Uri.parse('$_baseUrl/bids/latest/$productId');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return Bid.fromJson(responseData);
    } else {
      print('Failed to fetch latest bid: ${response.body}');
      return null;
    }
  }

  Future<bool> acceptBid(String bidId, String token) async {
    final url = Uri.parse('$_baseUrl/bids/$bidId/accept');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> rejectBid(String bidId, String token) async {
    final url = Uri.parse('$_baseUrl/bids/$bidId/reject');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<bool> counterOfferBid(
      String bidId, double counterOfferAmount, String token) async {
    final url = Uri.parse('$_baseUrl/bids/$bidId/counteroffer');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'counter_offer_amount': counterOfferAmount,
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> purchaseProduct(String bidId, String token) async {
    final url = Uri.parse('$_baseUrl/transactions/create');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'bid_id': bidId,
      }),
    );
    return response.statusCode == 200;
  }
}
