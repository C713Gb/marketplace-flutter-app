import 'package:flutter/material.dart';
import 'package:marketplace_flutter/services/auth_service.dart';
import '../services/bid_service.dart';

class BidScreen extends StatefulWidget {
  final String productId;

  BidScreen({required this.productId});

  @override
  _BidScreenState createState() => _BidScreenState();
}

class _BidScreenState extends State<BidScreen> {
  final _amountController = TextEditingController();
  final _bidService = BidService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Place a Bid')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Bid Amount'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitBid(),
              child: Text('Submit Bid'),
            ),
          ],
        ),
      ),
    );
  }

  _submitBid() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    AuthService authService = AuthService();
    String? token = await authService.getToken();
    final result = await _bidService.createBid(widget.productId, amount, token!);

    if (result != null) {
      // Successfully placed a bid
      Navigator.pop(context,
          true); // Pass 'true' to indicate a bid was successfully placed
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to place bid")));
    }
  }
}
