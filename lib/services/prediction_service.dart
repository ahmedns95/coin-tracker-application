import 'dart:convert';
import 'package:coin_tracker_application/config/const.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class PredictionService {
  Future<Map<String, dynamic>> getHistoricalData(
      String coinId, int days) async {
    final url =
        '${AppConst.baseUrl}/coins/$coinId/market_chart?vs_currency=usd&days=$days&interval=daily';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'accept': 'application/json',
          'x-cg-demo-api-key': AppConst.apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'prices': data['prices'] as List<dynamic>,
          'market_caps': data['market_caps'] as List<dynamic>,
          'total_volumes': data['total_volumes'] as List<dynamic>,
        };
      }
      throw Exception('Failed to fetch historical data');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Enhanced prediction model with detailed analytics
  Future<Map<String, dynamic>> predictPrice(String coinId) async {
    try {
      // Get last 90 days of data for better trend analysis
      final historicalData = await getHistoricalData(coinId, 90);
      final prices = historicalData['prices'] as List<dynamic>;
      final volumes = historicalData['total_volumes'] as List<dynamic>;
      final marketCaps = historicalData['market_caps'] as List<dynamic>;

      final List<FlSpot> historicalSpots = [];
      final List<FlSpot> predictionSpots = [];
      final List<double> shortTermMA = []; // 7-day MA
      final List<double> longTermMA = []; // 21-day MA
      final List<double> vwap = []; // Volume-weighted average price
      final List<double> volatility = []; // Price volatility
      final List<double> rsi = []; // Relative Strength Index
      final List<double> momentum = []; // Price Momentum

      // Calculate technical indicators
      for (int i = 0; i < prices.length; i++) {
        final price = (prices[i][1] as num).toDouble();
        final volume = (volumes[i][1] as num).toDouble();
        final marketCap = (marketCaps[i][1] as num).toDouble();
        historicalSpots.add(FlSpot(i.toDouble(), price));

        // Short-term MA (7 days)
        if (i >= 6) {
          double sum = 0;
          for (int j = i - 6; j <= i; j++) {
            sum += (prices[j][1] as num).toDouble();
          }
          shortTermMA.add(sum / 7);
        }

        // Long-term MA (21 days)
        if (i >= 20) {
          double sum = 0;
          for (int j = i - 20; j <= i; j++) {
            sum += (prices[j][1] as num).toDouble();
          }
          longTermMA.add(sum / 21);
        }

        // VWAP calculation
        if (i >= 6) {
          double priceVolumeSum = 0;
          double volumeSum = 0;
          for (int j = i - 6; j <= i; j++) {
            final p = (prices[j][1] as num).toDouble();
            final v = (volumes[j][1] as num).toDouble();
            priceVolumeSum += p * v;
            volumeSum += v;
          }
          vwap.add(priceVolumeSum / volumeSum);
        }

        // RSI calculation (14 periods)
        if (i >= 14) {
          List<double> gains = [];
          List<double> losses = [];
          for (int j = i - 13; j <= i; j++) {
            double change = (prices[j][1] as num).toDouble() - 
                          (prices[j - 1][1] as num).toDouble();
            if (change >= 0) {
              gains.add(change);
              losses.add(0);
            } else {
              gains.add(0);
              losses.add(-change);
            }
          }
          double avgGain = gains.reduce((a, b) => a + b) / 14;
          double avgLoss = losses.reduce((a, b) => a + b) / 14;
          double rs = avgGain / (avgLoss > 0 ? avgLoss : 0.00001);
          rsi.add(100 - (100 / (1 + rs)));
        }

        // Momentum (10-day price change)
        if (i >= 9) {
          double momentumValue = price - (prices[i - 9][1] as num).toDouble();
          momentum.add(momentumValue);
        }

        // Volatility calculation (14-day standard deviation)
        if (i >= 13) {
          List<double> window = [];
          for (int j = i - 13; j <= i; j++) {
            window.add((prices[j][1] as num).toDouble());
          }
          double mean = window.reduce((a, b) => a + b) / window.length;
          double sumSquares = window.fold(0.0, (sum, x) => sum + (x - mean) * (x - mean));
          volatility.add(sqrt(sumSquares / window.length));
        }
      }

      // Calculate market conditions and trends
      double shortTermTrend = calculateTrend(shortTermMA);
      double longTermTrend = calculateTrend(longTermMA);
      double vwapTrend = calculateTrend(vwap);
      double momentumTrend = calculateTrend(momentum);
      double currentRSI = rsi.last;
      double avgVolatility = volatility.sublist(volatility.length - 14).reduce((a, b) => a + b) / 14;

      // Current market state
      double lastPrice = (prices.last[1] as num).toDouble();
      List<double> predictions = [];
      List<double> upperBounds = [];
      List<double> lowerBounds = [];
      List<String> predictionDates = [];
      DateTime currentDate = DateTime.now();
      
      // Market condition weights
      double trendStrength = calculateTrendStrength(shortTermTrend, longTermTrend);
      double marketSentiment = calculateMarketSentiment(currentRSI, momentumTrend);
      double volatilityImpact = 1.0 - (avgVolatility / lastPrice);

      // Composite trend calculation with dynamic weights
      double compositeTrend = calculateCompositeTrend(
        shortTermTrend,
        longTermTrend,
        vwapTrend,
        momentumTrend,
        trendStrength,
        marketSentiment
      );

      // Generate predictions with confidence intervals
      for (int i = 1; i <= 7; i++) {
        double alpha = exp(-i / 7); // Time decay factor
        double beta = 1.0 - (i / 7); // Confidence decay factor
        
        // Base prediction
        double predictedPrice = lastPrice + (compositeTrend * i * alpha);
        
        // Confidence intervals based on volatility and market conditions
        double confidenceRange = avgVolatility * i * beta * (1.0 + (1.0 - marketSentiment));
        
        predictions.add(predictedPrice);
        upperBounds.add(predictedPrice + confidenceRange);
        lowerBounds.add(max(0, predictedPrice - confidenceRange));
        
        // Add prediction date
        DateTime predictionDate = currentDate.add(Duration(days: i));
        predictionDates.add('${predictionDate.year}-${predictionDate.month.toString().padLeft(2, '0')}-${predictionDate.day.toString().padLeft(2, '0')}');
        
        predictionSpots.add(FlSpot((prices.length + i - 1).toDouble(), predictedPrice));
      }

      // Find extreme predictions
      double maxPrediction = upperBounds.reduce(max);
      double minPrediction = lowerBounds.reduce(min);
      
      // Calculate prediction confidence score (0-100)
      double confidenceScore = calculateConfidenceScore(
        trendStrength,
        marketSentiment,
        volatilityImpact,
        currentRSI
      );

      return {
        'historical_data': historicalSpots,
        'prediction_data': predictionSpots,
        'current_price': lastPrice,
        'predicted_prices': predictions,
        'upper_bounds': upperBounds,
        'lower_bounds': lowerBounds,
        'prediction_dates': predictionDates,
        'max_prediction': maxPrediction,
        'min_prediction': minPrediction,
        'confidence_score': confidenceScore,
        'market_indicators': {
          'trend_strength': trendStrength,
          'market_sentiment': marketSentiment,
          'volatility': avgVolatility,
          'rsi': currentRSI,
        }
      };
    } catch (e) {
      throw Exception('Prediction error: $e');
    }
  }

  // Helper method to calculate trend
  double calculateTrend(List<double> data) {
    if (data.length < 2) return 0;
    
    double sumChange = 0;
    int weight = 1;
    int totalWeight = 0;
    
    for (int i = 1; i < data.length; i++) {
      sumChange += (data[i] - data[i - 1]) * weight;
      totalWeight += weight;
      weight++;
    }
    
    return sumChange / totalWeight;
  }

  // Calculate trend strength (0-1)
  double calculateTrendStrength(double shortTerm, double longTerm) {
    double alignment = (shortTerm * longTerm > 0) ? 1.0 : -1.0;
    double magnitude = (shortTerm.abs() + longTerm.abs()) / 2;
    return (alignment * magnitude).clamp(0.0, 1.0);
  }

  // Calculate market sentiment (0-1)
  double calculateMarketSentiment(double rsi, double momentum) {
    double rsiScore = (rsi - 30) / (70 - 30); // Normalize RSI between oversold (30) and overbought (70)
    double momentumScore = momentum > 0 ? 1.0 : 0.0;
    return ((rsiScore + momentumScore) / 2).clamp(0.0, 1.0);
  }

  // Calculate composite trend with dynamic weights
  double calculateCompositeTrend(
    double shortTerm,
    double longTerm,
    double vwap,
    double momentum,
    double trendStrength,
    double sentiment
  ) {
    // Base weights
    const double shortTermBase = 0.35;
    const double longTermBase = 0.25;
    const double vwapBase = 0.25;
    const double momentumBase = 0.15;

    // Adjust weights based on market conditions
    double shortTermWeight = shortTermBase * (1 + trendStrength);
    double longTermWeight = longTermBase * (1 + (1 - sentiment));
    double vwapWeight = vwapBase;
    double momentumWeight = momentumBase * sentiment;

    // Normalize weights
    double totalWeight = shortTermWeight + longTermWeight + vwapWeight + momentumWeight;
    shortTermWeight /= totalWeight;
    longTermWeight /= totalWeight;
    vwapWeight /= totalWeight;
    momentumWeight /= totalWeight;

    return (shortTerm * shortTermWeight) +
           (longTerm * longTermWeight) +
           (vwap * vwapWeight) +
           (momentum * momentumWeight);
  }

  // Calculate confidence score (0-100)
  double calculateConfidenceScore(
    double trendStrength,
    double sentiment,
    double volatilityImpact,
    double rsi
  ) {
    double baseScore = (trendStrength + sentiment + volatilityImpact) / 3;
    double rsiImpact = (rsi > 30 && rsi < 70) ? 1.0 : 0.7; // Penalize extreme RSI values
    
    return (baseScore * rsiImpact * 100).clamp(0.0, 100.0);
  }
}
