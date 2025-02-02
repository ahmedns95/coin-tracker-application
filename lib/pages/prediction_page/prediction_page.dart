import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/prediction_service.dart';
import '../../config/app_colors.dart';
import '../../global_widgets/app_text.dart';
import '../../global_widgets/app_text_form_field.dart';
import '../../global_widgets/app_text_button.dart';

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final TextEditingController _coinController = TextEditingController();
  final PredictionService _predictionService = PredictionService();
  bool _isLoading = false;
  Map<String, dynamic>? _predictionData;
  String? _error;

  Future<void> _getPrediction() async {
    if (_coinController.text.isEmpty) {
      setState(() {
        _error = 'Please enter a coin ID';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _predictionService.predictPrice(_coinController.text);
      setState(() {
        _predictionData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimaryColor1,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor1,
        title: const AppText(title: 'Price Prediction'),
        iconTheme: IconThemeData(color: AppColors.kPrimaryTextColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              title: 'Enter coin ID (e.g., bitcoin, ethereum)',
            ),
            const SizedBox(height: 8),
            AppTextFormField(
              controller: _coinController,
              labelText: 'Coin ID',
            ),
            const SizedBox(height: 16),
            AppTextButton(
              title: 'Predict Price',
              onTap: _isLoading ? null : _getPrediction,
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else if (_error != null)
              AppText(
                title: 'Error: $_error',
              )
            else if (_predictionData != null) ...[
              const SizedBox(height: 24),
              _buildPriceChart(),
              const SizedBox(height: 24),
              _buildPredictionDetails(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChart() {
    final historicalData = _predictionData!['historical_data'] as List<FlSpot>;
    final predictionData = _predictionData!['prediction_data'] as List<FlSpot>;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kContainerBox,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kContainerBoarder),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Historical data line
            LineChartBarData(
              spots: historicalData,
              isCurved: true,
              color: AppColors.kTextPrimaryButton,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // Prediction data line
            LineChartBarData(
              spots: predictionData,
              isCurved: true,
              color: AppColors.kGreenColor,
              barWidth: 2,
              dotData: FlDotData(show: false),
              dashArray: [5, 5], // Make it dashed
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionDetails() {
    final predictions = _predictionData!['predicted_prices'] as List<double>;
    final upperBounds = _predictionData!['upper_bounds'] as List<double>;
    final lowerBounds = _predictionData!['lower_bounds'] as List<double>;
    final currentPrice = _predictionData!['current_price'] as double;
    final maxPrediction = _predictionData!['max_prediction'] as double;
    final minPrediction = _predictionData!['min_prediction'] as double;
    final confidenceScore = _predictionData!['confidence_score'] as double;
    final marketIndicators =
        _predictionData!['market_indicators'] as Map<String, dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            title: 'Current Price: \$${currentPrice.toStringAsFixed(6)}',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorCard(
                  'Confidence',
                  '${confidenceScore.toStringAsFixed(1)}%',
                  _getConfidenceColor(confidenceScore),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIndicatorCard(
                  'RSI',
                  marketIndicators['rsi'].toStringAsFixed(1),
                  _getRSIColor(marketIndicators['rsi']),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AppText(
            title: '7-Day Price Predictions:',
          ),
          const SizedBox(height: 8),
          _buildPredictionList(predictions, upperBounds, lowerBounds),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildIndicatorCard(
                  'Potential High',
                  '\$${maxPrediction.toStringAsFixed(4)}',
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildIndicatorCard(
                  'Potential Low',
                  '\$${minPrediction.toStringAsFixed(4)}',
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMarketIndicators(marketIndicators),
        ],
      ),
    );
  }

  Widget _buildIndicatorCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionList(
    List<double> predictions,
    List<double> upperBounds,
    List<double> lowerBounds,
  ) {
    final predictionDates =
        _predictionData!['prediction_dates'] as List<String>;

    return Column(
      children: List.generate(
        predictions.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Day ${index + 1} (${predictionDates[index]}):',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${predictions[index].toStringAsFixed(7)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Range: \$${lowerBounds[index].toStringAsFixed(7)} - \$${upperBounds[index].toStringAsFixed(7)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              if (index < predictions.length - 1)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Divider(
                    color: Colors.grey[200],
                    height: 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketIndicators(Map<String, dynamic> indicators) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          title: 'Market Indicators:',
        ),
        const SizedBox(height: 8),
        _buildIndicatorBar('Trend Strength', indicators['trend_strength']),
        const SizedBox(height: 4),
        _buildIndicatorBar('Market Sentiment', indicators['market_sentiment']),
        const SizedBox(height: 4),
        _buildIndicatorBar('Volatility', indicators['volatility'] / 100),
      ],
    );
  }

  Widget _buildIndicatorBar(String label, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 2),
        LinearProgressIndicator(
          value: value.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(_getIndicatorColor(value)),
        ),
      ],
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 70) return Colors.green;
    if (confidence >= 40) return Colors.orange;
    return Colors.red;
  }

  Color _getRSIColor(double rsi) {
    if (rsi >= 70) return Colors.red;
    if (rsi <= 30) return Colors.green;
    return Colors.blue;
  }

  Color _getIndicatorColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.3) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _coinController.dispose();
    super.dispose();
  }
}
