import 'package:coin_tracker_application/global_widgets/app_text_button.dart';
import 'package:coin_tracker_application/global_widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

import 'config/app_colors.dart';

class SignalScreen extends StatefulWidget {
  const SignalScreen({super.key, required this.title});

  final String title;

  @override
  State<SignalScreen> createState() => _SignalScreenState();
}

class _SignalScreenState extends State<SignalScreen> {
  TextEditingController coinNameController = TextEditingController();
  List<List<dynamic>> prices = [];
  List<List<dynamic>> marketCaps = [];
  List<List<dynamic>> totalVolumes = [];
  List<String> signals = [];

  Future<void> fetchPriceData(String coinName) async {
    String url =
        "https://api.coingecko.com/api/v3/coins/$coinName/market_chart?vs_currency=usd&days=1";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          prices = List<List<dynamic>>.from(data['prices']);
          marketCaps = List<List<dynamic>>.from(data['market_caps']);
          totalVolumes = List<List<dynamic>>.from(data['total_volumes']);
          signals = generateSignals(prices, marketCaps, totalVolumes);
        });
      } else {
        print('Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching price data: $e');
    }
  }

  List<String> generateSignals(List<List<dynamic>> prices,
      List<List<dynamic>> marketCaps, List<List<dynamic>> totalVolumes) {
    List<String> signals = [];
    List<double> shortTermMA =
        calculateSMA(prices, 2); // 2-period short-term MA
    List<double> longTermMA = calculateSMA(prices, 3); // 3-period long-term MA

    for (int i = 0; i < prices.length; i++) {
      if (i == 0) {
        signals.add('Hold'); // No signals for the first data point
        continue;
      }

      double currentPrice = prices[i][1];
      double previousPrice = prices[i - 1][1];
      double currentVolume = totalVolumes[i][1];
      double previousVolume = totalVolumes[i - 1][1];

      // Buy signal
      if (shortTermMA[i] > longTermMA[i] && currentVolume > previousVolume) {
        signals.add('Buy');
      }
      // Sell signal
      else if (shortTermMA[i] < longTermMA[i] && currentPrice < previousPrice) {
        signals.add('Sell');
      }
      // Hold signal
      else {
        signals.add('Hold');
      }
    }

    return signals;
  }

  List<double> calculateSMA(List<List<dynamic>> data, int window) {
    List<double> sma = [];
    for (int i = 0; i < data.length; i++) {
      if (i < window - 1) {
        sma.add(0); // Not enough data points for this window
      } else {
        double sum = 0;
        for (int j = i; j > i - window; j--) {
          sum += data[j][1];
        }
        sma.add(sum / window);
      }
    }
    return sma;
  }

  LineChartData buildChart() {
    return LineChartData(
      backgroundColor: Colors.white10,
      clipData: FlClipData.all(),
      lineBarsData: [
        LineChartBarData(
          spots: prices
              .asMap()
              .entries
              .map((entry) => FlSpot(entry.key.toDouble(), entry.value[1]))
              .toList(),
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          belowBarData: BarAreaData(show: true),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              if (signals[index] == "Buy") {
                return FlDotCirclePainter(
                    radius: 5, color: Colors.green, strokeWidth: 2);
              } else if (signals[index] == "Sell") {
                return FlDotCirclePainter(
                    radius: 5, color: Colors.red, strokeWidth: 2);
              } else {
                return FlDotCirclePainter(
                    radius: 5, color: Colors.amber, strokeWidth: 2);
              }
            },
          ),
        ),
      ],
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10, // Adjust as needed
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 5, // Adjust as needed
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index >= 0 && index < prices.length) {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(prices[index][0]);
                return Text("${date.hour}:${date.minute}",
                    style: TextStyle(fontSize: 10));
              }
              return const Text('');
            },
          ),
        ),
        topTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 5)),
        rightTitles:
            AxisTitles(sideTitles: SideTitles(showTitles: false, interval: 3)),
      ),
      gridData: FlGridData(show: true),
      borderData: FlBorderData(show: true),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final index = spot.x.toInt();
              if (index >= 0 && index < prices.length) {
                DateTime date =
                    DateTime.fromMillisecondsSinceEpoch(prices[index][0]);
                return LineTooltipItem(
                  "\$${spot.y.toStringAsFixed(4)}\n${date.hour}:${date.minute}/${date.day}",
                  const TextStyle(
                    color: Colors.white,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Directionality(
              textDirection: TextDirection.rtl,
              child: BackButton(
                color: Colors.white,
                style: ButtonStyle(),
              ))
        ],
        backgroundColor: AppColors.kPrimaryColor,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              AppTextFormField(
                controller: coinNameController,
                labelText: 'Enter Coin Name',
              ),
              const SizedBox(height: 20),
              AppTextButton(
                title: "Pull Price List",
                onTap: () => fetchPriceData(coinNameController.text),
              ),
              const SizedBox(height: 20),
              if (prices.isNotEmpty) ...[
                Container(
                  height: 300,
                  margin: EdgeInsets.all(5),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: prices.length * 30.0,
                      // Dynamic width based on data length
                      child: LineChart(buildChart()),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: signals[index] == "Buy"
                          ? Colors.green
                          : signals[index] == "Sell"
                              ? Colors.red
                              : Colors.amber,
                      child: ListTile(
                        title: Text(
                            "Price: ${prices[index][1].toStringAsFixed(4)}"),
                        subtitle: Text(
                            "Signal: ${signals[index]} at time ${DateTime.fromMillisecondsSinceEpoch(prices[index][0])}"),
                      ),
                    );
                  },
                ),
              ],
              if (prices.isEmpty) Text('No data')
            ],
          ),
        ),
      ),
    );
  }
}
