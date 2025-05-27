import 'package:almentor_clone/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:almentor_clone/models/subscription.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/themeProvider.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Localization/app_translations.dart';

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
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
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
        statusAr: AppTranslations.getText(
                'new',
                Provider.of<LanguageProvider>(context, listen: false)
                    .currentLocale
                    .languageCode) ??
            'جديد',
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
        errorMessage = AppTranslations.getText(
                'error_message',
                Provider.of<LanguageProvider>(context, listen: false)
                    .currentLocale
                    .languageCode) ??
            'حدث خطأ أثناء الاشتراك';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final locale = languageProvider.currentLocale.languageCode;

    if (!isAuthenticated) {
      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black87 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppTranslations.getText('subscription_plans', locale) ??
              'خطط المنتور',
          style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh,
                color: isDark ? Colors.white : Colors.black),
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
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text(AppTranslations.getText('retry', locale) ??
                            'إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : _buildSubscriptionPlans(isDark, locale),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18),
        child: ElevatedButton(
          onPressed: isLoading ? null : subscribeToPlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            minimumSize: const Size.fromHeight(50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              : Text(
                  AppTranslations.getText('subscribe_now', locale) ??
                      'اشترك الآن',
                  style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildSubscriptionPlans(bool isDark, String locale) {
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
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.red
                    : (isDark ? Colors.white24 : Colors.black12),
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
                        child: Text(
                          AppTranslations.getText('selected', locale) ??
                              'مختار',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    Text(
                      plan.displayNameAr,
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan.descriptionAr,
                  style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54),
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
                              style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black45 : Colors.grey[200],
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
                              style: TextStyle(
                                color: isDark ? Colors.white38 : Colors.black38,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '${plan.currency} ${plan.amount}',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                              ' /${AppTranslations.getText('monthly', locale) ?? 'شهرياً'}',
                              style: TextStyle(
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black54)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${plan.currency} ${(plan.amount * plan.durationValue).toStringAsFixed(2)} ${AppTranslations.getText('pay_every', locale) ?? 'يتم الدفع كل'} ${plan.durationValue} ${plan.durationUnit}',
                        style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45),
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
