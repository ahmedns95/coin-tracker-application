import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsService {
  static SharedPrefsService? _instance;
  static SharedPreferences? _preferences;

  static Future<SharedPrefsService> getInstance() async {
    _instance ??= SharedPrefsService();
    _preferences ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Theme mode
  static const String _kThemeModeKey = 'themeMode';
  Future<bool> setDarkMode(bool isDark) async {
    return await _preferences!.setBool(_kThemeModeKey, isDark);
  }

  bool getDarkMode() {
    return _preferences!.getBool(_kThemeModeKey) ?? false;
  }

  // Currency preference
  static const String _kPreferredCurrencyKey = 'preferredCurrency';
  Future<bool> setPreferredCurrency(String currency) async {
    return await _preferences!.setString(_kPreferredCurrencyKey, currency);
  }

  String getPreferredCurrency() {
    return _preferences!.getString(_kPreferredCurrencyKey) ?? 'USD';
  }

  // Saved coin data
  static const String _kSavedCoinsKey = 'savedCoins';

  Future<bool> saveCoinData(Map<String, dynamic> coinData) async {
    final List<String> existingData =
        _preferences!.getStringList(_kSavedCoinsKey) ?? [];
    final String newData = json.encode({
      ...coinData,
      'savedAt': DateTime.now().toIso8601String(),
    });
    existingData.add(newData);
    return await _preferences!.setStringList(_kSavedCoinsKey, existingData);
  }

  List<Map<String, dynamic>> getSavedCoins() {
    final List<String> savedData =
        _preferences!.getStringList(_kSavedCoinsKey) ?? [];
    return savedData
        .map((String data) => json.decode(data) as Map<String, dynamic>)
        .toList();
  }

  Future<bool> deleteCoinData(int index) async {
    final List<String> existingData =
        _preferences!.getStringList(_kSavedCoinsKey) ?? [];
    if (index >= 0 && index < existingData.length) {
      existingData.removeAt(index);
      return await _preferences!.setStringList(_kSavedCoinsKey, existingData);
    }
    return false;
  }

  Future<bool> clearSavedCoins() async {
    return await _preferences!.setStringList(_kSavedCoinsKey, []);
  }

  // Clear all preferences
  Future<bool> clearPreferences() async {
    return await _preferences!.clear();
  }
}
