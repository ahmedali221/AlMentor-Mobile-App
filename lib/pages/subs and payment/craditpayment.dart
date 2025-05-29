import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:almentor_clone/models/payment_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Localization/app_translations.dart';

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
  

  Future<void> _createSubscriptionRecord(String userId, String subscriptionId, String paymentId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('User not logged in');
      }

      // Calculate subscription dates
      final startDate = DateTime.now();
      final endDate = startDate.add(const Duration(days: 30)); 

      final response = await http.post(
        Uri.parse('http://localhost:5000/api/user-subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'subscriptionId': subscriptionId,
          'paymentId': paymentId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'status': {'en': 'active', 'ar': 'نشط'},
        }),
      );

      print('Subscription record response status: ${response.statusCode}');
      print('Subscription record response body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create subscription record: ${response.body}');
      }

      // Update payment status to completed
      await _updatePaymentStatus(paymentId, token);

    } catch (e) {
      print('Error creating subscription record: $e');
      rethrow;
    }
  }

  Future<void> _updatePaymentStatus(String paymentId, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('http://localhost:5000/api/payments/$paymentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'status': {'en': 'completed', 'ar': 'مكتمل'},
        }),
      );

      if (response.statusCode != 200) {
        print('Warning: Failed to update payment status: ${response.body}');
      }
    } catch (e) {
      print('Error updating payment status: $e');
    }
  }

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
          'paymentMethod': 'credit_card',
        }),
      );
      
      final paymentData = json.decode(paymentResponse.body);
      String? paymentId;
      if (paymentData != null && paymentData['payment'] != null && paymentData['payment']['_id'] != null) {
           paymentId = paymentData['payment']['_id'];
      } else {
          print('Error: Could not extract payment _id from response body: ${paymentResponse.body}');
          throw Exception('Failed to get payment ID from backend.');
      }

      print('Extracted paymentId from backend: $paymentId');
      print('Payment record response status: ${paymentResponse.statusCode}');
      print('Payment record response body: ${paymentResponse.body}');

      if (paymentResponse.statusCode != 200 && paymentResponse.statusCode != 201) {
        throw Exception('Failed to create payment record: ${paymentResponse.body}');
      }

      if (paymentId == null) {
           throw Exception('Payment ID is null after extraction.');
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
          'userId': userId,
          'subscriptionId': widget.payment.id,
          'paymentId': paymentId,
          'successUrl': 'almentor://payment/success?paymentId=$paymentId',
          'cancelUrl': 'almentor://payment/cancel',
        }),
      );

      print('Stripe response status: ${stripeResponse.statusCode}');
      print('Stripe response body: ${stripeResponse.body}');

      if (stripeResponse.statusCode != 200 && stripeResponse.statusCode != 201) {
        throw Exception('Failed to create checkout session: ${stripeResponse.body}');
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

        // Start polling for payment status
        _pollPaymentStatus(paymentId, token, userId);
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

  Future<void> _pollPaymentStatus(String paymentId, String token, String userId) async {
    int attempts = 0;
    const maxAttempts = 30; // 5 minutes total (10 seconds * 30)
    
    while (attempts < maxAttempts) {
      try {
        final response = await http.get(
          Uri.parse('http://localhost:5000/api/payments/$paymentId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final paymentData = json.decode(response.body);
          final status = paymentData['status']['en'];

          if (status == 'completed') {
            // Payment is successful, create subscription
            await _createSubscriptionRecord(userId, widget.payment.id, paymentId);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إنشاء الاشتراك بنجاح')),
              );
              Navigator.pop(context, true);
            }
            return;
          } else if (status == 'failed' || status == 'cancelled') {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('فشلت عملية الدفع')),
              );
              Navigator.pop(context, false);
            }
            return;
          }
        }

        // Wait for 10 seconds before next attempt
        await Future.delayed(const Duration(seconds: 10));
        attempts++;
      } catch (e) {
        print('Error polling payment status: $e');
        attempts++;
      }
    }

    // If we get here, we've timed out
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('انتهت مهلة انتظار الدفع')),
      );
      Navigator.pop(context, false);   }
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppTranslations.getText('payment_methods', locale) ?? 'طرق الدفع',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(isDark, locale),
                    const SizedBox(height: 10),
                    _buildSummaryCard(isDark),
                    const SizedBox(height: 16),
                    _buildSubscriptionTitleRow(isDark),
                    const SizedBox(height: 10),
                    _buildPromoToggle(isDark, locale),
                    if (_showPromoCode) _buildPromoField(isDark, locale),
                    const SizedBox(height: 20),
                    _buildTotalDue(isDark, locale),
                    const SizedBox(height: 10),
                    _buildStatusAndDate(isDark, locale),
                    const SizedBox(height: 20),
                    _buildPaymentOption(
                      index: 0,
                      title: AppTranslations.getText('pay_with_card', locale) ??
                          'Pay with Card',
                      leading: _paymentIcon('assets/images/download.png'),
                      isDark: isDark,
                    ),
                    _buildPaymentOption(
                      index: 1,
                      title:
                          AppTranslations.getText('pay_with_fawry', locale) ??
                              'Pay with Fawry',
                      leading: _paymentIcon('assets/images/download.jpg'),
                      isDark: isDark,
                    ),
                    if (_selectedPaymentOption == 1)
                      _buildPhoneField(
                          isDark,
                          AppTranslations.getText('pay_using_fawry', locale) ??
                              'Pay using any Fawry outlet.'),
                    _buildPaymentOption(
                      index: 2,
                      title: AppTranslations.getText(
                              'pay_with_vodafone', locale) ??
                          'Pay with Vodafone Cash',
                      leading: _paymentIcon('assets/images/vodafone-cash.png'),
                      isDark: isDark,
                    ),
                    if (_selectedPaymentOption == 2)
                      _buildPhoneField(
                          isDark,
                          AppTranslations.getText(
                                  'pay_using_vodafone', locale) ??
                              'Pay using Vodafone Cash.'),
                    const SizedBox(height: 30),
                    _buildContinueButton(isDark, locale),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String locale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppTranslations.getText('order_summary', locale) ?? 'Order Summary:',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            AppTranslations.getText('show_more', locale) ?? 'Show More',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        )
      ],
    );
  }

  Widget _buildSummaryCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.payment.subscriptionTitle,
            style: TextStyle(
                color: isDark ? Colors.white : Colors.black, fontSize: 16),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppTranslations.getText(
                      'change_plan',
                      Provider.of<LanguageProvider>(context, listen: false)
                          .currentLocale
                          .languageCode) ??
                  'Change Plan',
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTitleRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(widget.payment.subscriptionTitle,
            style: TextStyle(
                fontSize: 20, color: isDark ? Colors.white : Colors.black)),
        Text(
          '${widget.payment.amount} ${widget.payment.currency}',
          style: TextStyle(
              fontSize: 20, color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }

  Widget _buildPromoToggle(bool isDark, String locale) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showPromoCode = !_showPromoCode;
        });
      },
      child: Text(
        AppTranslations.getText('use_promo_code', locale) ?? 'Use Promo Code',
        style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            decoration: TextDecoration.underline),
      ),
    );
  }

  Widget _buildPromoField(bool isDark, String locale) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promoController,
              decoration: InputDecoration(
                hintText: AppTranslations.getText('enter_code', locale) ??
                    'Enter Code',
                hintStyle:
                    TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppTranslations.getText('promo_code_applied', locale) ?? 'Promo Code applied.'} "${_promoController.text}"'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: Text(AppTranslations.getText('apply', locale) ?? 'Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDue(bool isDark, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslations.getText('total_due', locale) ?? 'Total Due',
          style: TextStyle(
              fontSize: 16, color: isDark ? Colors.white70 : Colors.black54),
        ),
        Text(
          '${widget.payment.amount} ${widget.payment.currency}',
          style: TextStyle(
              fontSize: 18, color: isDark ? Colors.white : Colors.black),
        ),
      ],
    );
  }

  Widget _buildStatusAndDate(bool isDark, String locale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppTranslations.getText('payment_status', locale) ?? 'Payment Status'}: ${widget.payment.statusAr}',
          style: TextStyle(
              fontSize: 12, color: isDark ? Colors.grey : Colors.black54),
        ),
        const SizedBox(height: 5),
        Text(
          '${AppTranslations.getText('created_at', locale) ?? 'Created At'}: ${DateFormat.yMMMd().format(widget.payment.createdAt)}',
          style: TextStyle(
              fontSize: 12, color: isDark ? Colors.grey : Colors.black54),
        ),
      ],
    );
  }

  Widget _buildPaymentOption({
    required int index,
    required String title,
    required Widget leading,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[200],
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
            style: TextStyle(
                fontSize: 16, color: isDark ? Colors.white : Colors.black)),
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

  Widget _buildPhoneField(bool isDark, String infoText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(infoText,
              style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54)),
          const SizedBox(height: 10),
          Text(
            AppTranslations.getText(
                    'phone_number',
                    Provider.of<LanguageProvider>(context, listen: false)
                        .currentLocale
                        .languageCode) ??
                'Phone Number',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              hintText: '01XX-XXXX-XXXX',
              hintStyle:
                  TextStyle(color: isDark ? Colors.white54 : Colors.black54),
              filled: true,
              fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
            ),
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(bool isDark, String locale) {
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
        child: Text(
          AppTranslations.getText('continue_to_payment', locale) ??
              'Continue to Payment',
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
