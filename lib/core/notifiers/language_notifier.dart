import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LanguageNotifier extends ChangeNotifier {
  static const String _langBox = 'settings';
  static const String _langKey = 'languageCode';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LanguageNotifier() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final box = await Hive.openBox(_langBox);
    final String? code = box.get(_langKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final box = await Hive.openBox(_langBox);
    await box.put(_langKey, locale.languageCode);
    notifyListeners();
  }
}
