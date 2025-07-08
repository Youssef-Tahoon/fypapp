import 'package:flutter/material.dart';

class NisabChecker {
  /// Shows a dialog with detailed nisab eligibility information and explanation
  static void showNisabCheckDialog({
    required BuildContext context,
    required bool isEligible,
    required double goldGrams,
    required double silverGrams,
    required double monthlySalary,
    required bool goldEligible,
    required bool silverEligible,
    required bool salaryEligible,
    required double goldValue,
    required double silverValue,
    required double annualSalaryValue,
    required double nisabGoldGrams,
    required double nisabSilverGrams,
    required double minMonthlySalary,
    required double goldPricePerGram,
    required double silverPricePerGram,
    required Function calculateZakat,
    double cash = 0.0,
    double investments = 0.0,
    double otherAssets = 0.0,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with eligibility status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isEligible ? Colors.green.shade100 : Colors.orange.shade100,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isEligible ? Icons.check_circle : Icons.info,
                      color: isEligible ? Colors.green.shade700 : Colors.orange.shade700,
                      size: 48,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEligible ? 'You are eligible for Zakat' : 'You are not eligible for Zakat yet',
                      style: TextStyle(
                        color: isEligible ? Colors.green.shade700 : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // What is Nisab?
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What is Nisab?',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nisab is the minimum amount of wealth a Muslim must possess before they become eligible to pay Zakat. The Nisab threshold is based on the value of gold, silver, or annual income.',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nisab Thresholds
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nisab Thresholds:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          _buildComparisonRow(
                            'Gold',
                            '$nisabGoldGrams grams',
                            'RM ${(nisabGoldGrams * goldPricePerGram).toStringAsFixed(2)}',
                            goldGrams, 
                            nisabGoldGrams,
                            isThreshold: true,
                          ),
                          _buildComparisonRow(
                            'Silver',
                            '$nisabSilverGrams grams',
                            'RM ${(nisabSilverGrams * silverPricePerGram).toStringAsFixed(2)}',
                            silverGrams, 
                            nisabSilverGrams,
                            isThreshold: true,
                          ),
                          _buildComparisonRow(
                            'Monthly Salary',
                            'RM ${minMonthlySalary.toStringAsFixed(2)}',
                            'RM ${(minMonthlySalary * 12).toStringAsFixed(2)}/year',
                            monthlySalary, 
                            minMonthlySalary,
                            isThreshold: true,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Your Assets
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Assets:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          
                          // Traditional Nisab Assets
                          _buildComparisonRow(
                            'Gold',
                            '${goldGrams.toStringAsFixed(2)} grams',
                            'RM ${goldValue.toStringAsFixed(2)}',
                            goldGrams, 
                            nisabGoldGrams,
                            isEligible: goldEligible,
                          ),
                          _buildComparisonRow(
                            'Silver',
                            '${silverGrams.toStringAsFixed(2)} grams',
                            'RM ${silverValue.toStringAsFixed(2)}',
                            silverGrams, 
                            nisabSilverGrams,
                            isEligible: silverEligible,
                          ),
                          _buildComparisonRow(
                            'Monthly Salary',
                            'RM ${monthlySalary.toStringAsFixed(2)}',
                            'RM ${annualSalaryValue.toStringAsFixed(2)}/year',
                            monthlySalary, 
                            minMonthlySalary,
                            isEligible: salaryEligible,
                          ),
                          
                          // Add divider if we have additional assets
                          if (cash > 0 || investments > 0 || otherAssets > 0)
                            Divider(height: 24, color: Colors.green.shade200),
                          
                          // Additional Assets
                          if (cash > 0 || investments > 0 || otherAssets > 0)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Additional Assets (Compared to Gold Nisab):',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                          
                          // Cash in bank
                          if (cash > 0)
                            Builder(builder: (context) {
                              final bool cashEligible = cash >= (nisabGoldGrams * goldPricePerGram);
                              final double cashInGoldGrams = cash / goldPricePerGram;
                              return _buildComparisonRow(
                                'Cash in Bank',
                                'RM ${cash.toStringAsFixed(2)}',
                                '≈ ${cashInGoldGrams.toStringAsFixed(2)} g gold',
                                cashInGoldGrams,
                                nisabGoldGrams,
                                isEligible: cashEligible,
                              );
                            }),
                          
                          // Investments
                          if (investments > 0)
                            Builder(builder: (context) {
                              final bool investmentsEligible = investments >= (nisabGoldGrams * goldPricePerGram);
                              final double investmentsInGoldGrams = investments / goldPricePerGram;
                              return _buildComparisonRow(
                                'Investments',
                                'RM ${investments.toStringAsFixed(2)}',
                                '≈ ${investmentsInGoldGrams.toStringAsFixed(2)} g gold',
                                investmentsInGoldGrams,
                                nisabGoldGrams,
                                isEligible: investmentsEligible,
                              );
                            }),
                          
                          // Other assets
                          if (otherAssets > 0)
                            Builder(builder: (context) {
                              final bool otherAssetsEligible = otherAssets >= (nisabGoldGrams * goldPricePerGram);
                              final double otherAssetsInGoldGrams = otherAssets / goldPricePerGram;
                              return _buildComparisonRow(
                                'Other Assets',
                                'RM ${otherAssets.toStringAsFixed(2)}',
                                '≈ ${otherAssetsInGoldGrams.toStringAsFixed(2)} g gold',
                                otherAssetsInGoldGrams,
                                nisabGoldGrams,
                                isEligible: otherAssetsEligible,
                              );
                            }),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Explanation section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isEligible ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isEligible ? Colors.green.shade200 : Colors.orange.shade200,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explanation:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isEligible
                                ? 'You have reached the Nisab threshold. According to Islamic principles, you are required to pay 2.5% of your eligible wealth as Zakat once it has been in your possession for one lunar year.'
                                : 'Your assets have not reached any of the Nisab thresholds. According to Islamic principles, Zakat is not obligatory for you at this time.',
                            style: TextStyle(
                              color: isEligible ? Colors.green.shade700 : Colors.orange.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'How Nisab is Calculated:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Traditional method: Compare gold, silver, and income directly to their respective thresholds.\n'
                            '• Modern method: Convert monetary assets (cash, investments, etc.) to gold equivalent and compare to gold Nisab (${nisabGoldGrams.toStringAsFixed(0)} grams).',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          if (isEligible) ...[
                            Text(
                              'Note: Only assets that surpassed the nisab threshold AND have been in your possession for a full lunar year (Hawl) are subject to Zakat.',
                              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (isEligible)
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          calculateZakat();
                        },
                        icon: const Icon(Icons.calculate),
                        label: const Text("Proceed to Full Calculation"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Helper method to build comparison rows
  static Widget _buildComparisonRow(
    String label,
    String value1,
    String value2,
    double actual,
    double threshold,
    {bool isThreshold = false, bool? isEligible}
  ) {
    final bool eligible = isThreshold ? false : (isEligible ?? actual >= threshold);
    final Color textColor = isThreshold ? Colors.black87 : 
                          (eligible ? Colors.green.shade700 : Colors.black87);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value1,
              style: TextStyle(
                color: textColor,
                fontWeight: eligible && !isThreshold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value2,
              style: TextStyle(
                color: textColor,
                fontWeight: eligible && !isThreshold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          if (!isThreshold) 
            Icon(
              eligible ? Icons.check_circle : Icons.arrow_downward,
              color: eligible ? Colors.green : Colors.orange,
              size: 16,
            ),
        ],
      ),
    );
  }
}
