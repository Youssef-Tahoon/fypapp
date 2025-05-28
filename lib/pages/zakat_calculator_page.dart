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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zakat Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!showResult) ...[
              const Text('Assets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ZakatInputField(label: "Gold (grams)", controller: goldController, tooltip: "Gold in grams (24K). Must be at least 85g."),
              if (double.tryParse(goldController.text) != null && double.tryParse(goldController.text)! < nisabGoldGrams)
                _buildWarningNote("Gold amount is less than 85g. Not eligible for Zakat."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Silver (grams)", controller: silverController, tooltip: "Silver in grams. Must be at least 595g."),
              if (double.tryParse(silverController.text) != null && double.tryParse(silverController.text)! < nisabSilverGrams)
                _buildWarningNote("Silver amount is less than 595g. Not eligible for Zakat."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Monthly Salary (RM)", controller: salaryController, tooltip: "Minimum RM 2400 per month required."),
              if (double.tryParse(salaryController.text) != null && double.tryParse(salaryController.text)! < minMonthlySalary)
                _buildWarningNote("Monthly salary is less than RM 2400. Not eligible for Zakat."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Cash & Bank", controller: cashController, tooltip: "Cash, savings, and checking."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Investments", controller: investmentController, tooltip: "Stocks, bonds, etc."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Properties (Investment)", controller: propertyController, tooltip: "Exclude primary home."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Business Assets", controller: businessController, tooltip: "Inventory, receivables, etc."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Other Assets", controller: otherAssetsController, tooltip: "Held for 1 lunar year."),
              const SizedBox(height: 20),
              const Divider(),
              const Text('Liabilities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ZakatInputField(label: "Debts", controller: debtsController, tooltip: "Outstanding debts."),
              const SizedBox(height: 10),
              ZakatInputField(label: "Essential Expenses", controller: expensesController, tooltip: "Before next income."),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: calculateZakat, child: const Text("Calculate Zakat")),
              const SizedBox(height: 10),
              TextButton(onPressed: resetFields, child: const Text("Reset")),
            ] else ...[
              const Text("Zakat Calculation Results", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildResultRow("Gold Value", goldValue),
              _buildResultRow("Silver Value", silverValue),
              _buildResultRow("Annual Salary", salaryValue),
              _buildResultRow("Total Assets", totalAssets),
              _buildResultRow("Total Liabilities", totalLiabilities),
              _buildResultRow("Net Worth", netWorth),
              const SizedBox(height: 10),
              Text(
                isEligible ? "✅ You are eligible to pay Zakat" : "⚠️ You are not eligible to pay Zakat",
                style: TextStyle(color: isEligible ? Colors.green : Colors.orange, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (isEligible)
                _buildResultRow("Zakat Amount (2.5%)", zakatAmount, highlight: true),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => showResult = false),
                child: const Text("Back to Calculator"),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, double value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text("RM ${value.toStringAsFixed(2)}",
              style: TextStyle(fontWeight: highlight ? FontWeight.bold : FontWeight.normal, color: highlight ? Colors.green : null)),
        ],
      ),
    );
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
}
