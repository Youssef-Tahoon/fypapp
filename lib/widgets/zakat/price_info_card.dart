import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget that displays current gold and silver prices
class PriceInfoCard extends StatelessWidget {
  final double goldPricePerGram;
  final double silverPricePerGram;
  final DateTime? lastUpdated;
  final bool isLoading;

  const PriceInfoCard({
    super.key,
    required this.goldPricePerGram,
    required this.silverPricePerGram,
    required this.lastUpdated,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.update, size: 16, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  'Current Metal Prices',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on,
                        color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 4),
                    Text('Gold: '),
                  ],
                ),
                Text(
                  'RM ${goldPricePerGram.toStringAsFixed(2)}/g',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.monetization_on_outlined,
                        color: Colors.blueGrey, size: 16),
                    const SizedBox(width: 4),
                    Text('Silver: '),
                  ],
                ),
                Text(
                  'RM ${silverPricePerGram.toStringAsFixed(2)}/g',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (lastUpdated != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Last updated: ${DateFormat('dd MMM, HH:mm').format(lastUpdated!)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
