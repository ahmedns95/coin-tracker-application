import 'package:coin_tracker_application/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'global_widgets/app_text.dart';
import 'signal_screen.dart';
import 'global_widgets/app_text_button.dart';
import 'global_widgets/app_text_form_field.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Coin Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MyHomePage(title: 'Coin Tracker'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double coinPrice = 0;
  TextEditingController coinNameController = TextEditingController();
  TextEditingController coinPricePurchaseController = TextEditingController();
  TextEditingController coinsQuantityController = TextEditingController();
  TextEditingController targetPercentageController = TextEditingController();
  double priceChange = 0;
  double tradingVolume = 0;
  double marketCap = 0;

  Future<double?> fetchPrice(String coinName) async {
    String url =
        "https://api.coingecko.com/api/v3/simple/price?ids=$coinName&vs_currencies=usd&include_market_cap=true&include_24hr_vol=true&include_24hr_change=true&include_last_updated_at=true&precision=7";
    try {
      final response = await http.get(Uri.parse(url), headers: {
        "accept": "application/json",
        "x-cg-demo-api-key": "CG-ugm8MRqxgSuCAjmZGPVhsMMR"
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        coinPrice = data[coinName]['usd']?.toDouble();
        priceChange = data[coinName]['usd_24h_change']?.toDouble();
        tradingVolume = data[coinName]['usd_24h_vol']?.toDouble();
        marketCap = data[coinName]['usd_market_cap']?.toDouble();
        return data[coinName]['usd']?.toDouble();
      } else {
        debugPrint('Failed to fetch data. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching Dogecoin price: $e');
      return null;
    }
  }

  String determineTradeAction(double priceChange, double tradingVolume) {
    if (priceChange < -5.0 && tradingVolume > 500000000) {
      setColor("Buy");
      return 'Buy';
    } else if (priceChange > 5.0 && tradingVolume > 500000000) {
      setColor("Sell");
      return 'Sell';
    } else if (tradingVolume == 0) {
      setColor("No value");
      return 'No value';
    } else {
      setColor("Hold");
      return 'Hold';
    }
  }

  Color setColor(String? type) {
    switch (type) {
      case 'Buy':
        return Colors.green;
      case 'Sell':
        return Colors.red;
      case 'Hold':
        return Colors.yellow.shade700;
      default:
        return Colors.black;
    }
  }

  double calculateTargetPercentage(
    double purchasePrice,
    double currentPrice,
    double targetPercentage,
  ) {
    if (purchasePrice <= 0) {
      throw ArgumentError('Purchase price must be greater than zero.');
    }
    // Calculate the percentage change
    double percentageChange =
        ((currentPrice - purchasePrice) / purchasePrice) * 100;

    return percentageChange;
  }

  //this function return the price after doing the calculation for the percentage desire
  double calculateSellPriceUp() {
    if (targetPercentageController.text.isEmpty ||
        double.tryParse(targetPercentageController.text) == null) {
      return 0.0;
    }
    if (coinPricePurchaseController.text.isEmpty ||
        double.tryParse(coinPricePurchaseController.text) == null) {
      return 0.0;
    }
    double targetPercentage = double.parse(targetPercentageController.text);
    double purchasePrice = double.parse(coinPricePurchaseController.text);

    if (purchasePrice <= 0) {
      throw ArgumentError('Purchase price must be greater than zero.');
    }
    return purchasePrice * (1 + targetPercentage / 100);
  }

  double calculateSellPriceDown() {
    if (targetPercentageController.text.isEmpty ||
        double.tryParse(targetPercentageController.text) == null) {
      return 0.0;
    }
    if (coinPricePurchaseController.text.isEmpty ||
        double.tryParse(coinPricePurchaseController.text) == null) {
      return 0.0;
    }
    double targetPercentage = double.parse(targetPercentageController.text);
    double purchasePrice = double.parse(coinPricePurchaseController.text);

    if (purchasePrice <= 0) {
      throw ArgumentError('Purchase price must be greater than zero.');
    }
    return (purchasePrice * (1 - targetPercentage / 100));
  }

  double determinePricePercentage() {
    if (coinPricePurchaseController.text.isEmpty ||
        double.tryParse(coinPricePurchaseController.text) == null) {
      return 0.0;
    }
    double purchasePrice = double.parse(coinPricePurchaseController.text);
    return ((coinPrice - purchasePrice) / purchasePrice) * 100;
  }

  double priceVolume() {
    if (coinPricePurchaseController.text.isEmpty ||
        double.tryParse(coinPricePurchaseController.text) == null) {
      return 0.0;
    }
    if (coinsQuantityController.text.isEmpty ||
        double.tryParse(coinsQuantityController.text) == null) {
      return 0.0;
    }
    double coinQuantity = double.parse(coinsQuantityController.text);
    return coinPrice * coinQuantity;
  }

  double priceVolumeSellUp() {
    if (coinPricePurchaseController.text.isEmpty ||
        double.tryParse(coinPricePurchaseController.text) == null) {
      return 0.0;
    }
    if (coinsQuantityController.text.isEmpty ||
        double.tryParse(coinsQuantityController.text) == null) {
      return 0.0;
    }
    double coinQuantity = double.parse(coinsQuantityController.text);
    return calculateSellPriceUp() * coinQuantity;
  }

  double priceVolumeSellDown() {
    if (coinPricePurchaseController.text.isEmpty ||
        double.tryParse(coinPricePurchaseController.text) == null) {
      return 0.0;
    }
    if (coinsQuantityController.text.isEmpty ||
        double.tryParse(coinsQuantityController.text) == null) {
      return 0.0;
    }
    double coinQuantity = double.parse(coinsQuantityController.text);
    return calculateSellPriceDown() * coinQuantity;
  }

  String determineTradeActionAdvanced(
      double? priceChange, double? tradingVolume, double? marketCap) {
    if (priceChange == null ||
        tradingVolume == null ||
        marketCap == null ||
        marketCap == 0) {
      return 'No value';
    }

    double weightedChangeScore =
        (priceChange / 100) * (tradingVolume / marketCap);
    if (weightedChangeScore < -0.05) {
      return 'Buy: ${coinNameController.text} has a weighted change score of ${weightedChangeScore.toStringAsFixed(4)}.';
    } else if (weightedChangeScore > 0.05) {
      return 'Sell: ${coinNameController.text} has a weighted change score of ${weightedChangeScore.toStringAsFixed(4)}.';
    } else {
      return 'Hold: No strong signals for ${coinNameController.text}. Weighted change score: ${weightedChangeScore.toStringAsFixed(4)}.';
    }
  }

  Color? actionColor;
  String? action;
  bool isLoading=false;
  void _incrementCounter() async {
    setState(() {
      isLoading = true;
    });

    final fetchedPrice = await fetchPrice(coinNameController.text);

    setState(() {
      isLoading = false;
      if (fetchedPrice != null) {
        action = determineTradeAction(priceChange, tradingVolume);
        actionColor = setColor(action);
        determinePricePercentage();
        calculateSellPriceUp();
        calculateSellPriceDown();
        priceVolumeSellDown();
        priceVolumeSellUp();
      } else {
        action = 'Failed to fetch price';
        actionColor = Colors.black;
      }
    });
  }
  // void _incrementCounter() {
  //   setState(() {
  //     fetchPrice(coinNameController.text);
  //     action = determineTradeAction(priceChange, tradingVolume);
  //     actionColor = setColor(action);
  //     determinePricePercentage();
  //     calculateSellPriceUp();
  //     calculateSellPriceDown();
  //     priceVolumeSellDown();
  //     priceVolumeSellUp();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        //Theme.of(context).colorScheme.onPrimaryContainer,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),
              AppText(
                title: 'Pulling the currency price',
              ),
              AppTextFormField(
                controller: coinNameController,
                labelText: 'Enter coin name',
              ),
              AppTextFormField(
                controller: coinPricePurchaseController,
                labelText: 'Enter coin purchase price',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,5}')),
                ],
              ),
              AppTextFormField(
                controller: coinsQuantityController,
                labelText: 'Enter coin quantity',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,5}')),
                ],
              ),
              AppTextFormField(
                controller: targetPercentageController,
                labelText: 'Enter target percentage',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,5}')),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AppTextButton(
                    title: "Signal Chart",
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SignalScreen(
                                title: 'Signal buy & sell',
                              )));
                    },
                  ),
                  AppTextButton(
                    title: "Pull coin data",
                    onTap: () {
                      _incrementCounter();
                    },
                  ),
                ],
              ),
              AppText(
                title: "Current price: ${coinPrice.toStringAsFixed(5)}",
                  fontSize: 22,
              ),
              AppText(
                title: "Action: ${determineTradeAction(priceChange, tradingVolume)}",
                fontColor: actionColor,
                // fontSize: 30,
              ),
              AppText(
                title: "Sell when get the price to",
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      AppText(
                          title:
                              "${calculateSellPriceUp().toStringAsFixed(4)}\n${priceVolumeSellUp().toStringAsFixed(4)}",
                          fontColor: Colors.green),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      AppText(
                          title:
                              "${calculateSellPriceDown().toStringAsFixed(4)}\n${priceVolumeSellDown().toStringAsFixed(4)}",
                          fontColor: Colors.red),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
              AppText(title: "Volume buying : ${priceVolume().toStringAsFixed(4)}"),
              AppText(
                title: "Determine trade action advanced",
              ),
              AppText(
                title: determineTradeActionAdvanced(
                    priceChange, tradingVolume, marketCap),
                fontColor: actionColor,
              ),
              AppText(
                  title: "${determinePricePercentage().toStringAsFixed(2)}%",
                  fontSize: 25),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
// import 'app/data/local/my_shared_pref.dart';
// import 'app/routes/app_pages.dart';
// import 'config/theme/my_theme.dart';
// import 'config/translations/localization_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await MySharedPref.init();
//   // await Firebase.initializeApp(
//   //   options: DefaultFirebaseOptions.currentPlatform,
//   // );
//   // Stripe.publishableKey = ApiKeys.publishableKey;
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(375, 812),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       useInheritedMediaQuery: true,
//       rebuildFactor: (old, data) => true,
//       builder: (context, widget) {
//         return GetMaterialApp(
//           title: "Sezon App",
//           useInheritedMediaQuery: true,
//           debugShowCheckedModeBanner: false,
//           builder: (context,widget) {
//            // bool themeIsLight = MySharedPref.getThemeIsLight();
//             return Theme(
//               data: MyTheme.getThemeData(isLight: true),
//               child: MediaQuery(
//                 data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
//                 child: widget!,
//               ),
//             );
//           },
//           initialRoute: AppPages.INITIAL,
//           getPages: AppPages.routes,
//          // locale: MySharedPref.getCurrentLocal(),
//        //   translations: LocalizationService.getInstance(),
//         );
//       },
//     );
//   }
// }
//
