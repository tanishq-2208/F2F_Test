import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:f2f/services/language_service.dart';

extension StringTranslationExtension on String {
  String tr(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    return languageService.translate(this);
  }
}