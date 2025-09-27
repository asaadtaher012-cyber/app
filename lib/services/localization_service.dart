import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService extends ChangeNotifier {
  Map<String, dynamic> _localizedValues = {};
  String _currentLanguage = 'ar';

  String get currentLanguage => _currentLanguage;

  Future<void> loadLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    
    try {
      String jsonString = await rootBundle.loadString('assets/lang/$languageCode.json');
      _localizedValues = json.decode(jsonString);
    } catch (e) {
      // Error loading language file: $e
      // Fallback to English if language file not found
      if (languageCode != 'en') {
        await loadLanguage('en');
        return;
      }
    }
    
    notifyListeners();
  }

  String getText(String key) {
    return _localizedValues[key] ?? key;
  }

  void changeLanguage(String languageCode) {
    loadLanguage(languageCode);
  }
}