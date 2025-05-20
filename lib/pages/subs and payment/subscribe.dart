import 'package:almentor_clone/Core/Localization/app_translations.dart';
import 'package:almentor_clone/Core/Providers/themeProvider.dart';
import 'package:almentor_clone/models/payment_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:almentor_clone/models/subscription.dart';
import 'package:provider/provider.dart';
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
          AppTranslations.getText('subscription_plans', locale),
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
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Subscription cards with almentor.net styling
            Expanded(
              child: ListView.builder(
                itemCount: subscriptions.length,
                itemBuilder: (context, index) {
                  final subscription = subscriptions[index];
                  return Card(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    elevation: 2,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      title: Text(
                        subscription.displayNameAr,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        subscription.descriptionAr,
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      trailing: Text(
                        '${subscription.amount} ${subscription.currency}',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () {
                        setState(() => selectedIndex = index);
                      },
                    ),
                  );
                },
              ),
            ),
            // Subscribe button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: subscribeToPlan,
                child: Text(
                  AppTranslations.getText('subscribe_now', locale),
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
}
