
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class LocalizationService {
  final SharedPreferences _prefs;
  Locale _currentLocale = const Locale('ar', 'EG');
  Map<String, String> _localizedStrings = {};

  LocalizationService(this._prefs) {
    _loadSavedLocale();
  }

  Locale get currentLocale => _currentLocale;

  List<Locale> get supportedLocales => const [
    Locale('ar', 'EG'), // Arabic (Egypt)
    Locale('en', 'US'), // English (US)
  ];

  Future<void> _loadSavedLocale() async {
    final savedLocale = _prefs.getString('app_locale');
    if (savedLocale != null) {
      final parts = savedLocale.split('_');
      _currentLocale = Locale(parts[0], parts.length > 1 ? parts[1] : '');
    }
    await loadTranslations();
  }

  Future<void> setLocale(Locale locale) async {
    _currentLocale = locale;
    await _prefs.setString('app_locale', '${locale.languageCode}_${locale.countryCode ?? ''}');
    await loadTranslations();
  }

  Future<void> loadTranslations() async {
    final String jsonString = await rootBundle.loadString(
      'assets/lang/${_currentLocale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  String translateWithParams(String key, Map<String, String> params) {
    String translation = translate(key);
    params.forEach((paramKey, paramValue) {
      translation = translation.replaceAll('{$paramKey}', paramValue);
    });
    return translation;
  }

  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  TextDirection get textDirection => isArabic ? TextDirection.rtl : TextDirection.ltr;
}

// Extension for easy access
extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return LocalizationService.of(this).translate(key);
  }
}
