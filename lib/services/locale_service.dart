import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jar/l10n/app_localizations.dart';

class LocaleService extends ChangeNotifier {
  static const String _prefsKey = 'selectedLocale';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LocaleService();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLangCode = prefs.getString(_prefsKey);

    if (savedLangCode != null) {
      _currentLocale = Locale(savedLangCode);
    } else {
      final systemLocale = PlatformDispatcher.instance.locale;
      final isSupported = AppLocalizations.supportedLocales.any(
        (supportedLocale) =>
            supportedLocale.languageCode == systemLocale.languageCode,
      );

      if (isSupported) {
        _currentLocale = Locale(systemLocale.languageCode);
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (locale.languageCode == _currentLocale.languageCode) return;

    _currentLocale = locale;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    notifyListeners();
  }
}
