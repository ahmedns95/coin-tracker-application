import 'package:flutter/material.dart';
import '../../services/shared_prefs_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SharedPrefsService _prefsService;
  bool _isDarkMode = false;
  String _preferredCurrency = 'USD';
  final List<String> _availableCurrencies = ['USD', 'EUR', 'GBP', 'JPY'];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefsService = await SharedPrefsService.getInstance();
    setState(() {
      _isDarkMode = _prefsService.getDarkMode();
      _preferredCurrency = _prefsService.getPreferredCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (bool value) async {
                await _prefsService.setDarkMode(value);
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),
          ),
          ListTile(
            title: const Text('Preferred Currency'),
            trailing: DropdownButton<String>(
              value: _preferredCurrency,
              items: _availableCurrencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  await _prefsService.setPreferredCurrency(newValue);
                  setState(() {
                    _preferredCurrency = newValue;
                  });
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Reset All Settings'),
            leading: const Icon(Icons.restore),
            onTap: () async {
              await _prefsService.clearPreferences();
              await _loadPreferences();
            },
          ),
        ],
      ),
    );
  }
}
