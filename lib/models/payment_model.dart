// lib/models/payment_model.dart

class PaymentModel {
  final String id;
  final String subscriptionTitle;
  final String subscriptionDescription;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String statusAr;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.subscriptionTitle,
    required this.subscriptionDescription,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.statusAr,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] ?? '',
      subscriptionTitle: json['subscription']?['title'] ?? 'Subscription Plan',
      subscriptionDescription: json['subscription']?['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      statusAr: json['status']?['ar'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
