import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LanguageService extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', '');
  Map<String, dynamic> _translations = {};
  bool _isLoaded = false;

  Locale get currentLocale => _currentLocale;
  bool get isLoaded => _isLoaded;

  // Add this method for explicit initialization
  Future<void> initialize() async {
    await _loadSavedLanguage();
    await _loadTranslations();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('language_code');
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage, '');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved language: $e');
    }
  }

  Future<void> _loadTranslations() async {
    try {
      final String response = await rootBundle.loadString('assets/translations/translations.json');
      _translations = json.decode(response);
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading translations: $e');
      // Create a basic translation map if loading fails
      _translations = {
        'en': {'error': 'Translations not loaded'},
        'te': {'error': 'అనువాదాలు లోడ్ కాలేదు'}
      };
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode, '');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('language_code', languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
    notifyListeners();
  }

  String translate(String key) {
    if (!_isLoaded) return key;
    
    final langCode = _currentLocale.languageCode;
    if (_translations.containsKey(langCode) && _translations[langCode].containsKey(key)) {
      return _translations[langCode][key];
    }
    
    // Fallback to English
    if (_translations.containsKey('en') && _translations['en'].containsKey(key)) {
      return _translations['en'][key];
    }
    
    return key;
  }
}

class AppLocalizations {
  final Locale locale;
  final LanguageService _languageService;

  AppLocalizations(this.locale, this._languageService);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String translate(String key) {
    return _languageService.translate(key);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'te'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final languageService = LanguageService();
    await Future.delayed(const Duration(milliseconds: 100)); // Wait for service to initialize
    return AppLocalizations(locale, languageService);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}