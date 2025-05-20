import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:almentor_clone/models/payment_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CraditPayment extends StatefulWidget {
  final PaymentModel payment;

  const CraditPayment({super.key, required this.payment});

  @override
  _CraditPaymentState createState() => _CraditPaymentState();
}

class _CraditPaymentState extends State<CraditPayment> {
  int _selectedPaymentOption = -1;
  bool _showPromoCode = false;
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _startStripePayment() async {
    final amount = (widget.payment.amount * 100).toInt();
    final currency = widget.payment.currency;

    try {
      print('Starting payment process...');
      print('Amount: $amount');
      print('Currency: $currency');

      // Get user token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final userId = prefs.getString('user_id');

      print('Token: ${token != null ? 'exists' : 'null'}');
      print('UserId: $userId');

      if (token == null || userId == null) {
        throw Exception('User not logged in');
      }

      // First create the payment record
      print('Creating payment record...');

      final paymentResponse = await http.post(
        Uri.parse('http://localhost:5000/api/payments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user': userId,
          'subscription': widget.payment.id,
          'amount': widget.payment.amount,
          'currency': widget.payment.currency,
          'transactionId': 'txn_${DateTime.now().millisecondsSinceEpoch}',
          'status': {'en': 'pending', 'ar': 'قيد الانتظار'},
          'paymentMethod': 'credit_card'
        }),
      );

      print('Payment record response status: ${paymentResponse.statusCode}');
      print('Payment record response body: ${paymentResponse.body}');

      if (paymentResponse.statusCode != 200 &&
          paymentResponse.statusCode != 201) {
        throw Exception(
            'Failed to create payment record: ${paymentResponse.body}');
      }

      // Then create Stripe checkout session
      print('Creating Stripe checkout session...');

      final stripeResponse = await http.post(
        Uri.parse('http://localhost:5000/api/stripe/createCheckoutSession'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'amount': amount,
          'currency': currency.toLowerCase(),
        }),
      );

      print('Stripe response status: ${stripeResponse.statusCode}');
      print('Stripe response body: ${stripeResponse.body}');

      if (stripeResponse.statusCode != 200 &&
          stripeResponse.statusCode != 201) {
        throw Exception(
            'Failed to create checkout session: ${stripeResponse.body}');
      }

      final jsonResponse = json.decode(stripeResponse.body);
      final checkoutUrl = jsonResponse['url'];

      print('Checkout URL: $checkoutUrl');

      // Open the Stripe checkout URL
      if (await canLaunch(checkoutUrl)) {
        print('Launching checkout URL...');
        final launched = await launch(checkoutUrl);
        print('Launch result: $launched');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Redirecting to payment page...')),
          );
        }
      } else {
        print('Could not launch URL: $checkoutUrl');
        throw Exception('Could not launch checkout URL');
      }
    } catch (e, stackTrace) {
      print('Error in _startStripePayment: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _handlePayment() {
    if (_selectedPaymentOption == 0) {
      _startStripePayment();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم اختيار طريقة دفع: ${_selectedPaymentOption == 1 ? "فوري" : "فودافون كاش"}\nرقم الهاتف: ${_phoneController.text}',
          ),
        ),
      );
    }
  }

  // Update build method
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        elevation: 0,
        title: Text(
          AppTranslations.getText('payment_methods', locale),
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Payment options with almentor.net styling
            // ... existing payment options code with updated colors

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _handlePayment,
                child: Text(
                  AppTranslations.getText('continue', locale),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Order Summary:',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Show More',
            style: TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.payment.subscriptionTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Change Plan',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.payment.subscriptionTitle,
            style: const TextStyle(fontSize: 20, color: Colors.white)),
        Text(
          '${widget.payment.amount} ${widget.payment.currency}',
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPromoToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showPromoCode = !_showPromoCode;
        });
      },
      child: const Text(
        'Use Promo Code',
        style: TextStyle(
            color: Colors.white, decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _buildPromoField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: 'Enter Code',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Promo Code "${_promoController.text}" applied.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Due',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        Text(
          '${widget.payment.amount} ${widget.payment.currency}',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStatusAndDate() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Status: ${widget.payment.statusAr}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(
          'Created At: ${DateFormat.yMMMd().format(widget.payment.createdAt)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required Widget leading,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              _selectedPaymentOption == index ? Colors.red : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: ListTile(
        leading: leading,
        title: Text(title,
            style: const TextStyle(fontSize: 16, color: Colors.white)),
        trailing: Radio<int>(
          value: index,
          groupValue: _selectedPaymentOption,
          activeColor: Colors.red,
          onChanged: (value) {
            setState(() {
              _selectedPaymentOption = value!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedPaymentOption = index;
          });
        },
      ),
    );
  }

  Widget _paymentIcon(String path) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(path, height: 40),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildPhoneField(String infoText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(infoText,
              style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 10),
          const Text(
            'Phone Number',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: '01XX-XXXX-XXXX',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[850],
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _selectedPaymentOption == -1 ? null : _handlePayment,
        child: const Text(
          'Continue to Payment',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
