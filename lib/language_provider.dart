import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  String _language = 'english';

  String get language => _language;

  void setLanguage(String newLang) {
    _language = newLang;
    notifyListeners();
  }
}