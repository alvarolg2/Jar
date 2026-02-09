import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _prefsKey = 'selectedLocale';

  Locale _currentLocale = const Locale('es');

  Locale get currentLocale => _currentLocale;

  LocaleService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString(_prefsKey);
    
    if (savedLangCode != null) {
      _currentLocale = Locale(savedLangCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _currentLocale.languageCode) return;

    _currentLocale = locale;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    notifyListeners();
  }
}