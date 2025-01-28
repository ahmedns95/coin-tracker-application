import 'package:coin_tracker_application/pages/home_page/home_page.dart';
import 'package:coin_tracker_application/pages/settings_page/settings_page.dart';
import 'package:coin_tracker_application/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPrefsService.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatefulWidget {
  final SharedPrefsService prefs;
  const MyApp({super.key, required this.prefs});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.prefs.getDarkMode();
  }

  void _updateTheme(bool isDark) {
    setState(() {
      _isDarkMode = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Tracker',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: Colors.blue,
      //     brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      //   ),
      //   useMaterial3: true,
      //   brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      // ),
      routes: {
        '/': (context) => const MyHomePage(title: 'Coin Tracker'),
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
