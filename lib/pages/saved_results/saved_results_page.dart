import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/shared_prefs_service.dart';
import '../../global_widgets/app_text.dart';
import '../../config/app_colors.dart';

class SavedResultsPage extends StatefulWidget {
  const SavedResultsPage({super.key});

  @override
  State<SavedResultsPage> createState() => _SavedResultsPageState();
}

class _SavedResultsPageState extends State<SavedResultsPage> {
  List<Map<String, dynamic>> savedCoins = [];

  @override
  void initState() {
    super.initState();
    _loadSavedCoins();
  }

  Future<void> _loadSavedCoins() async {
    final prefs = await SharedPrefsService.getInstance();
    setState(() {
      savedCoins = prefs.getSavedCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPrimaryColor1,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor1,
        title: AppText(title: 'Saved Results'),
        iconTheme: IconThemeData(color: AppColors.kPrimaryTextColor),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
            ),
            onPressed: () async {
              final prefs = await SharedPrefsService.getInstance();
              await prefs.clearSavedCoins();
              setState(() {
                savedCoins.clear();
              });
            },
          ),
        ],
      ),
      body: savedCoins.isEmpty
          ? const Center(
              child: AppText(
                title: 'No saved results yet',
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: savedCoins.length,
              reverse: true,
              itemBuilder: (context, index) {
                final coin = savedCoins[index];
                final savedAt = DateTime.parse(coin['savedAt']);
                final formattedDate =
                    DateFormat('MMM dd, yyyy HH:mm a').format(savedAt);

                return Card(
                  color: AppColors.kContainerBox,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.kContainerBoarder,
                    ),
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              title: coin['coinName']?.toUpperCase() ?? 'N/A',
                            ),
                            AppText(
                              title: formattedDate,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Current Price',
                            '\$${coin['currentPrice']?.toStringAsFixed(7)}'),
                        _buildInfoRow('Purchase Price',
                            '\$${coin['purchasePrice']?.toStringAsFixed(7)}'),
                        _buildInfoRow(
                            'Quantity', coin['quantity']?.toString() ?? 'N/A'),
                        _buildInfoRow('Current Volume',
                            '\$${coin['currentVolume']?.toStringAsFixed(2) ?? 'N/A'}'),
                        _buildInfoRow('Purchase Volume',
                            '\$${coin['purchaseVolume']?.toStringAsFixed(2) ?? 'N/A'}'),
                        _buildInfoRow('Profit or Loss',
                            '\$${coin['profitOrLoss']?.toStringAsFixed(2) ?? 'N/A'},${coin['currentPercentage'] ?? 'N/A'}%'),
                        _buildInfoRow(
                            'Target %', '${coin['targetPercentage']}%'),
                        _buildInfoRow('24h Change',
                            '${coin['priceChange']?.toStringAsFixed(2)}%'),
                        _buildInfoRow('Volume',
                            '\$${_formatNumber(coin['tradingVolume'])}'),
                        _buildInfoRow('Market Cap',
                            '\$${_formatNumber(coin['marketCap'])}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getActionColor(coin['action']),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            title: coin['action'] ?? 'N/A',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            title: label,
          ),
          AppText(
            title: value,
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic number) {
    if (number == null) return 'N/A';
    if (number >= 1000000000) {
      return '${(number / 1000000000).toStringAsFixed(2)}B';
    } else if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(2)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}K';
    }
    return number.toStringAsFixed(2);
  }

  Color _getActionColor(String? action) {
    switch (action?.toLowerCase()) {
      case 'buy':
        return AppColors.kGreenColor;
      case 'sell':
        return AppColors.kRedColor;
      case 'hold':
        return AppColors.kYellowColor;
      default:
        return Colors.grey;
    }
  }
}
