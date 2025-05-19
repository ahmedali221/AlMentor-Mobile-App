import 'package:almentor_clone/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:almentor_clone/models/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscribePage extends StatefulWidget {
  const SubscribePage({super.key});

  @override
  State<SubscribePage> createState() => _SubscribePageState();
}

class _SubscribePageState extends State<SubscribePage> {
  List<Subscription> subscriptions = [];
  int selectedIndex = 0;
  bool isLoading = true;
  String? errorMessage;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadData();
  }

  Future<void> _checkLoginAndLoadData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    if (token == null || token.isEmpty) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      return;
    }

    setState(() {
      isAuthenticated = true;
    });

    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await fetchSubscriptions();
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ في تحميل البيانات';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

    final response = await http.get(
      Uri.parse('http://localhost:5000/api/subscriptions'),
      headers: token != null
          ? {'Authorization': 'Bearer $token'}
          : {},
    );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          subscriptions =
              data.map((json) => Subscription.fromJson(json)).toList();
        });
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        throw Exception('فشل في تحميل البيانات');
      }
    } catch (e) {
      print('Error fetching subscriptions: $e');
      rethrow;
    }
  }

  Future<void> subscribeToPlan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

  if (token == null || token.isEmpty) {
  if (mounted) {
    Navigator.pushReplacementNamed(context, '/login');
  }
  return;
}

    if (subscriptions.isEmpty) return;

    final selected = subscriptions[selectedIndex];

    try {
      setState(() => isLoading = true);

      final payment = PaymentModel(
        id: selected.id,
        subscriptionTitle: selected.displayNameAr,
        subscriptionDescription: selected.descriptionAr,
        amount: selected.amount,
        currency: selected.currency,
        paymentMethod: '',
        statusAr: 'جديد',
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        '/credit_card_payment',
        arguments: payment,
      );
    } catch (e) {
      setState(() {
        errorMessage = 'حدث خطأ أثناء الاشتراك';
      });
      print('Error subscribing to plan: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isAuthenticated) {
      // لا تعرض أي شيء لو مش متحقق من تسجيل الدخول
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'خطط المنتور',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : _buildSubscriptionPlans(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18),
        child: ElevatedButton(
          onPressed: isLoading ? null : subscribeToPlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('اشترك الآن', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans() {
    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: subscriptions.length,
      itemBuilder: (context, index) {
        final plan = subscriptions[index];
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white24,
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red[700],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'مختار',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    Text(
                      plan.displayNameAr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.descriptionAr,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ...plan.features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              feature.titleAr,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (plan.originalAmount != null) ...[
                            Text(
                              '${plan.currency} ${plan.originalAmount}',
                              style: const TextStyle(
                                color: Colors.white38,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${plan.currency} ${plan.amount}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const Text(' /شهرياً',
                              style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.currency} ${(plan.amount * plan.durationValue).toStringAsFixed(2)} يتم الدفع كل ${plan.durationValue} ${plan.durationUnit}',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
