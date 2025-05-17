import 'package:almentor_clone/pages/subs%20and%20payment/payment.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:almentor_clone/models/payment_model.dart';

class CreditCardPayment extends StatefulWidget {
  final PaymentModel payment;

  const CreditCardPayment({super.key, required this.payment});

  @override
  _CreditCardPaymentState createState() => _CreditCardPaymentState();
}

class _CreditCardPaymentState extends State<CreditCardPayment> {
  int _selectedPaymentOption = -1;
  bool _showPromoCode = false;
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _handlePayment() {
    if (_selectedPaymentOption == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Payment(payment: widget.payment),
        ),
      );
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscribe to Almentor',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader(),
                      const SizedBox(height: 10),
                      _buildSummaryCard(),
                      const SizedBox(height: 16),
                      _buildSubscriptionTitleRow(),
                      const SizedBox(height: 10),
                      _buildPromoToggle(),
                      if (_showPromoCode) _buildPromoField(),
                      const SizedBox(height: 20),
                      _buildTotalDue(),
                      const SizedBox(height: 10),
                      _buildStatusAndDate(),
                      const SizedBox(height: 20),
                      _buildPaymentOption(
                        index: 0,
                        title: 'Pay with Card',
                        leading: _paymentIcon('assets/images/download.png'),
                      ),
                      _buildPaymentOption(
                        index: 1,
                        title: 'Pay with Fawry',
                        leading: _paymentIcon('assets/images/download.jpg'),
                      ),
                      if (_selectedPaymentOption == 1)
                        _buildPhoneField('Pay using any Fawry outlet.'),
                      _buildPaymentOption(
                        index: 2,
                        title: 'Pay with Vodafone Cash',
                        leading:
                            _paymentIcon('assets/images/vodafone-cash.png'),
                      ),
                      if (_selectedPaymentOption == 2)
                        _buildPhoneField('Pay using Vodafone Cash.'),
                      const SizedBox(height: 30),
                      _buildContinueButton(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // باقي الميثودز بدون تغيير: _buildSectionHeader, _buildSummaryCard, etc...
  // كلها سليمة

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
