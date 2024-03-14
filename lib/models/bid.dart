class Bid {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final double amount;
  final double? counterOfferAmount;
  final String status;
  final DateTime timestamp;

  Bid({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    this.counterOfferAmount,
    required this.status,
    required this.timestamp,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'],
      productId: json['product_id'],
      buyerId: json['buyer_id'],
      sellerId: json['seller_id'],
      amount: json['amount'].toDouble(),
      counterOfferAmount: json['counter_offer_amount'] != null
          ? json['counter_offer_amount'].toDouble()
          : null, // Handle optional field
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
