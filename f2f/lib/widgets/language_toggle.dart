import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:f2f/services/language_service.dart';

class LanguageToggle extends StatelessWidget {
  final bool isCompact;
  
  const LanguageToggle({
    Key? key,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);
    final currentLanguage = languageService.currentLocale.languageCode;
    
    if (isCompact) {
      return IconButton(
        icon: const Icon(Icons.language),
        onPressed: () {
          _showLanguageDialog(context, languageService, currentLanguage);
        },
        tooltip: 'Change Language',
      );
    }
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(
        currentLanguage == 'en' ? 'Language' : 'భాష',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        currentLanguage == 'en' ? 'English' : 'తెలుగు',
      ),
      onTap: () {
        _showLanguageDialog(context, languageService, currentLanguage);
      },
    );
  }
  
  void _showLanguageDialog(BuildContext context, LanguageService languageService, String currentLanguage) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(currentLanguage == 'en' ? 'Select Language' : 'భాషను ఎంచుకోండి'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('English'),
                leading: Radio<String>(
                  value: 'en',
                  groupValue: currentLanguage,
                  onChanged: (value) {
                    languageService.changeLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  languageService.changeLanguage('en');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('తెలుగు (Telugu)'),
                leading: Radio<String>(
                  value: 'te',
                  groupValue: currentLanguage,
                  onChanged: (value) {
                    languageService.changeLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
                onTap: () {
                  languageService.changeLanguage('te');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}