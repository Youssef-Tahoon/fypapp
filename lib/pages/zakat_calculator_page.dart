import 'package:flutter/material.dart';
import '../widgets/zakat_input_field.dart';

class ZakatCalculatorPage extends StatefulWidget {
  const ZakatCalculatorPage({super.key});

  @override
  State<ZakatCalculatorPage> createState() => _ZakatCalculatorPageState();
}

class _ZakatCalculatorPageState extends State<ZakatCalculatorPage> {
  final goldController = TextEditingController();
  final silverController = TextEditingController();
  final salaryController = TextEditingController();
  final cashController = TextEditingController();
  final investmentController = TextEditingController();
  final propertyController = TextEditingController();
  final businessController = TextEditingController();
  final otherAssetsController = TextEditingController();
  final debtsController = TextEditingController();
  final expensesController = TextEditingController();

  double goldValue = 0;
  double silverValue = 0;
  double salaryValue = 0;
  double totalAssets = 0;
  double totalLiabilities = 0;
  double netWorth = 0;
  double zakatAmount = 0;
  bool isEligible = false;
  bool showResult = false;
  bool goldEligible = true;
  bool silverEligible = true;
  bool salaryEligible = true;

  final double goldPricePerGram = 456.0;
  final double silverPricePerGram = 4.45;
  final double nisabGoldGrams = 85.0;
  final double nisabSilverGrams = 595.0;
  final double minMonthlySalary = 2400.0;

  void calculateZakat() {
    double goldGrams = double.tryParse(goldController.text) ?? 0;
    double silverGrams = double.tryParse(silverController.text) ?? 0;
    double monthlySalary = double.tryParse(salaryController.text) ?? 0;
    double cash = double.tryParse(cashController.text) ?? 0;
    double investment = double.tryParse(investmentController.text) ?? 0;
    double property = double.tryParse(propertyController.text) ?? 0;
    double business = double.tryParse(businessController.text) ?? 0;
    double other = double.tryParse(otherAssetsController.text) ?? 0;
    double debts = double.tryParse(debtsController.text) ?? 0;
    double expenses = double.tryParse(expensesController.text) ?? 0;

    goldValue = goldGrams * goldPricePerGram;
    silverValue = silverGrams * silverPricePerGram;
    salaryValue = monthlySalary * 12;

    totalAssets = goldValue + silverValue + salaryValue + cash + investment + property + business + other;
    totalLiabilities = debts + expenses;
    netWorth = totalAssets - totalLiabilities;

    goldEligible = goldGrams >= nisabGoldGrams;
    silverEligible = silverGrams >= nisabSilverGrams;
    salaryEligible = monthlySalary >= minMonthlySalary;

    isEligible = goldEligible || silverEligible || salaryEligible;
    zakatAmount = isEligible ? netWorth * 0.025 : 0;

    setState(() {
      showResult = true;
    });
  }

  void resetFields() {
    for (var controller in [
      goldController,
      silverController,
      salaryController,
      cashController,
      investmentController,
      propertyController,
      businessController,
      otherAssetsController,
      debtsController,
      expensesController
    ]) {
      controller.clear();
    }
    setState(() {
      showResult = false;
    });
  }

  Widget _buildWarningNote(String message) {
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Zakat Calculator'),
          backgroundColor: Colors.green.shade700,
          elevation: 0,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.shade700,
                Colors.green.shade50,
              ],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!showResult) ...[
                      Text(
                        'Assets',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ZakatInputField(
                        label: "Gold (grams)",
                        controller: goldController,
                        tooltip: "Gold in grams (24K). Must be at least 85g.",
                        icon: Icons.monetization_on,
                      ),
                      if (double.tryParse(goldController.text) != null &&
                          double.tryParse(goldController.text)! < nisabGoldGrams)
                        _buildWarningNote("Gold amount is less than 85g. Not eligible for Zakat."),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Silver (grams)",
                        controller: silverController,
                        tooltip: "Silver in grams. Must be at least 595g.",
                        icon: Icons.monetization_on_outlined,
                      ),
                      if (double.tryParse(silverController.text) != null &&
                          double.tryParse(silverController.text)! < nisabSilverGrams)
                        _buildWarningNote("Silver amount is less than 595g. Not eligible for Zakat."),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Monthly Salary (RM)",
                        controller: salaryController,
                        tooltip: "Minimum RM 2400 per month required.",
                        icon: Icons.account_balance_wallet,
                      ),
                      if (double.tryParse(salaryController.text) != null &&
                          double.tryParse(salaryController.text)! < minMonthlySalary)
                        _buildWarningNote("Monthly salary is less than RM 2400. Not eligible for Zakat."),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Cash & Bank",
                        controller: cashController,
                        tooltip: "Cash, savings, and checking.",
                        icon: Icons.savings,
                      ),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Investments",
                        controller: investmentController,
                        tooltip: "Stocks, bonds, etc.",
                        icon: Icons.trending_up,
                      ),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Properties (Investment)",
                        controller: propertyController,
                        tooltip: "Exclude primary home.",
                        icon: Icons.home_work,
                      ),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Business Assets",
                        controller: businessController,
                        tooltip: "Inventory, receivables, etc.",
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Other Assets",
                        controller: otherAssetsController,
                        tooltip: "Held for 1 lunar year.",
                        icon: Icons.more_horiz,
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.green),
                      const SizedBox(height: 10),
                      Text(
                        'Liabilities',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ZakatInputField(
                        label: "Debts",
                        controller: debtsController,
                        tooltip: "Outstanding debts.",
                        icon: Icons.money_off,
                      ),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Essential Expenses",
                        controller: expensesController,
                        tooltip: "Before next income.",
                        icon: Icons.receipt_long,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: calculateZakat,
                              icon: const Icon(Icons.calculate),
                              label: const Text("Calculate Zakat"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade700,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: resetFields,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Reset"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Text(
                        "Zakat Calculation Results",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 20),
                      _buildResultCard(),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (isEligible) {
                                  Navigator.pushNamed(
                                    context,
                                    '/pay-zakat',
                                    arguments: {'amount': zakatAmount},
                                  );
                                }
                              },
                              icon: const Icon(Icons.payment),
                              label: const Text("Pay Zakat"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isEligible ? Colors.green.shade700 : Colors.grey,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: () => setState(() => showResult = false),
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Back"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
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
                color: isEligible ? Colors.green.shade50 : Colors.orange.shade50,
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
                    isEligible ? "You are eligible to pay Zakat" : "You are not eligible to pay Zakat",
                    style: TextStyle(
                      color: isEligible ? Colors.green.shade700 : Colors.orange.shade700,
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
