import 'package:coin_tracker_application/pages/home_page/home_page.dart';
import 'package:coin_tracker_application/pages/settings_page/settings_page.dart';
import 'package:coin_tracker_application/services/shared_prefs_service.dart';
import 'package:flutter/material.dart';
import '../../config/const.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Tracker',
      routes: {
        AppRoutes.home: (context) => const MyHomePage(title: 'Coin Tracker'),
        AppRoutes.settings: (context) => const SettingsPage(),
      },
      initialRoute: AppRoutes.home,
    );
  }
}
