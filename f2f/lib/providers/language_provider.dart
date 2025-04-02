import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  String _selectedLanguage = 'en'; // Default language is English
  
  String get selectedLanguage => _selectedLanguage;
  
  LanguageProvider() {
    _loadLanguagePreference();
  }
  
  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }
  
  Future<void> setLanguage(String languageCode) async {
    if (_selectedLanguage != languageCode) {
      _selectedLanguage = languageCode;
      
      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language', languageCode);
      
      notifyListeners();
    }
  }
  
  bool get isTeluguSelected => _selectedLanguage == 'te';
}