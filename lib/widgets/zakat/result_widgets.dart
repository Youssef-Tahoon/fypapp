import 'package:flutter/material.dart';

/// Builds a result card to display zakat calculation results
class ZakatResultCard extends StatelessWidget {
  final double goldValue;
  final double silverValue;
  final double salaryValue;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final double zakatAmount;
  final bool isEligible;

  const ZakatResultCard({
    super.key,
    required this.goldValue,
    required this.silverValue,
    required this.salaryValue,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.zakatAmount,
    required this.isEligible,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isEligible ? Colors.green.shade200 : Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow("Gold Value", goldValue),
            _buildResultRow("Silver Value", silverValue),
            _buildResultRow("Annual Salary", salaryValue),
            const Divider(),
            _buildResultRow("Total Assets", totalAssets, bold: true),
            _buildResultRow("Total Liabilities", totalLiabilities, bold: true),
            _buildResultRow("Net Worth", netWorth, bold: true),
            const Divider(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    isEligible ? Colors.green.shade50 : Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    isEligible ? Icons.check_circle : Icons.warning,
                    color: isEligible ? Colors.green : Colors.orange,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEligible
                        ? "You are eligible to pay Zakat"
                        : "You are not eligible to pay Zakat",
                    style: TextStyle(
                      color: isEligible
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (isEligible) ...[
                    const SizedBox(height: 16),
                    Text(
                      "Zakat Amount (2.5%)",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "RM ${zakatAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            "RM ${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: bold ? Colors.green.shade700 : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget for displaying warning notes in the zakat calculator
class WarningNote extends StatelessWidget {
  final String message;

  const WarningNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(message, style: const TextStyle(color: Colors.black87)),
    );
  }
}
