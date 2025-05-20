import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Core/Providers/language_provider.dart';
import '../../Core/Localization/app_translations.dart';

class CongratulationsPage extends StatelessWidget {
  final VoidCallback? onDownloadCertificate;

  const CongratulationsPage({super.key, this.onDownloadCertificate});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final languageCode = languageProvider.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.getText('congratulations', languageCode)),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 100),
              const SizedBox(height: 24),
              Text(
                AppTranslations.getText('congratulations', languageCode),
                style:
                    const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                AppTranslations.getText('course_completed', languageCode),
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: Text(AppTranslations.getText(
                    'download_certificate', languageCode)),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: onDownloadCertificate ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppTranslations.getText(
                              'certificate_coming_soon', languageCode)),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child:
                    Text(AppTranslations.getText('back_to_home', languageCode)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
