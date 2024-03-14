import 'package:flutter/material.dart';
import 'package:marketplace_flutter/services/auth_service.dart';
import '../models/product.dart'; // Your Product model
import '../models/bid.dart'; // Your Bid model
import '../services/bid_service.dart'; // Your BidService
import 'bid_screen.dart'; // BidScreen for placing bids

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  ProductDetailsScreen({required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final BidService _bidService = BidService();
  Bid? latestBid;
  final AuthService _authService = AuthService();
  String? currentUserId;
  bool productPurchased = false;

  @override
  void initState() {
    super.initState();

    _fetchCurrentUserId();
    _fetchLatestBid();
  }

  _fetchLatestBid() async {
    AuthService authService = AuthService();
    String? token = await authService.getToken();
    final fetchedBid =
        await _bidService.getLatestBidForProduct(widget.product.id, token!);
    setState(() {
      latestBid = fetchedBid;
    });
  }

  _fetchCurrentUserId() async {
    currentUserId = await _authService.getCurrentUserId();
    setState(() {});
  }

  _acceptBid() async {
    String? token = await _authService.getToken();
    if (token != null && latestBid != null) {
      await _bidService.acceptBid(latestBid!.id, token);
      _fetchLatestBid(); // Refresh bid info
    }
  }

  _rejectBid() async {
    String? token = await _authService.getToken();
    if (token != null && latestBid != null) {
      await _bidService.rejectBid(latestBid!.id, token);
      _fetchLatestBid(); // Refresh bid info
    }
  }

  _makeCounterOffer(double counterOfferAmount) async {
    String? token = await _authService.getToken();
    if (token != null && latestBid != null) {
      await _bidService.counterOfferBid(
          latestBid!.id, counterOfferAmount, token);
      _fetchLatestBid(); // Refresh bid info
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${widget.product.description}'),
            Text('Seller: ${widget.product.sellerName}'),
            if (productPurchased) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Product purchased',
                  style: TextStyle(fontSize: 20, color: Colors.green),
                ),
              ),
            ] else ...[
              _buildLatestBidInfo(),
              _buildPurchaseOption(),
            ],
            if (latestBid == null)
              ElevatedButton(
                onPressed: () => _navigateToBidScreen(context),
                child: Text('Place a Bid'),
              ),
            if (latestBid?.buyerId == currentUserId &&
                latestBid?.status == "pending")
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text("Bid Pending Seller's Response",
                    style: TextStyle(color: Colors.orange)),
              ),
            if (latestBid?.sellerId == currentUserId &&
                latestBid?.status == "pending")
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _acceptBid,
                    child: Text('Accept Bid'),
                  ),
                  ElevatedButton(
                    onPressed: _rejectBid,
                    child: Text('Reject Bid'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showCounterOfferDialog(),
                    child: Text('Make Counteroffer'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseOption() {
    if (latestBid?.buyerId == currentUserId &&
        latestBid?.status == "accepted") {
      return ElevatedButton(
        onPressed: _purchaseProduct,
        child: Text('Purchase Product'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green, // Set the button color to green
        ),
      );
    } else {
      return Container(); // Return an empty container if no purchase option should be shown
    }
  }

  void _purchaseProduct() async {
    String? token = await _authService.getToken();
    if (token != null && latestBid != null) {
      final isSuccess = await _bidService.purchaseProduct(latestBid!.id, token);

      if (isSuccess) {
        setState(() {
          productPurchased = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Product purchased successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to purchase product. Please try again.")),
        );
      }
    }
  }

  Widget _buildLatestBidInfo() {
    if (latestBid == null) return Container(); // No bid information

    final isCurrentUserTheBuyer = latestBid?.buyerId == currentUserId;
    final isCounterOfferMade =
        latestBid?.status == "counteroffer" && isCurrentUserTheBuyer;

    if (isCurrentUserTheBuyer && latestBid?.status == "pending") {
      return Text('Waiting for seller to respond...');
    } else if (isCounterOfferMade) {
      // New condition for counteroffer made
      return Text(
          'Counter offer made: \$${latestBid!.counterOfferAmount}. Waiting for your response...');
    } else if (latestBid != null) {
      // Only show the "Latest Bid" text if there is a latest bid available
      return Text('Latest Bid: \$${latestBid!.amount}');
    } else {
      // Return an empty Container widget if there's no bid information to display
      return Container();
    }
  }

  _navigateToBidScreen(BuildContext context) async {
    // Navigate to BidScreen and await result in case a new bid is placed
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BidScreen(productId: widget.product.id),
      ),
    );

    // If a new bid is placed, refresh the latest bid information
    if (result == true) {
      _fetchLatestBid();
    }
  }

  void _showCounterOfferDialog() {
    final TextEditingController _counterOfferController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Make Counteroffer'),
          content: TextField(
            controller: _counterOfferController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter counteroffer amount',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () {
                final double? counterOfferAmount =
                    double.tryParse(_counterOfferController.text);
                if (counterOfferAmount != null) {
                  _makeCounterOffer(counterOfferAmount);
                  Navigator.of(context).pop();
                } else {
                  // Optionally show an error message if the input is not a valid number
                }
              },
            ),
          ],
        );
      },
    );
  }
}
