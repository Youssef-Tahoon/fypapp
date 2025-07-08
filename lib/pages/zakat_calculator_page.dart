import 'package:flutter/material.dart';
import '../widgets/zakat_input_field.dart';
import '../services/metal_price_service.dart';
import '../widgets/zakat/price_info_card.dart';
import '../widgets/zakat/result_widgets.dart';
import '../widgets/zakat/nisab_checker.dart';

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
  bool isLoading = true;

  // Default values until API fetches real-time prices
  double goldPricePerGram = 455.8;
  double silverPricePerGram = 4.94;
  DateTime? lastUpdated;

  final double nisabGoldGrams = 85.0;
  final double nisabSilverGrams = 595.0;
  final double minMonthlySalary = 3200.0;

  @override
  void initState() {
    super.initState();
    // Fetch metal prices when the page loads
    _fetchMetalPrices();
  }

  Future<void> _fetchMetalPrices() async {
    setState(() {
      isLoading = true;
    });

    try {
      final metalPrices = await MetalPriceService.getMetalPrices();
      setState(() {
        goldPricePerGram = metalPrices.goldPricePerGram;
        silverPricePerGram = metalPrices.silverPricePerGram;
        lastUpdated = metalPrices.lastUpdated;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching metal prices: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

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

    totalAssets = goldValue +
        silverValue +
        salaryValue +
        cash +
        investment +
        property +
        business +
        other;
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

  // New method to check Nisab eligibility without calculating full zakat
  void checkNisab() {
    double goldGrams = double.tryParse(goldController.text) ?? 0;
    double silverGrams = double.tryParse(silverController.text) ?? 0;
    double monthlySalary = double.tryParse(salaryController.text) ?? 0;
    double cash = double.tryParse(cashController.text) ?? 0;
    double investments = double.tryParse(investmentController.text) ?? 0;
    double otherAssets = double.tryParse(otherAssetsController.text) ?? 0;

    bool goldEligible = goldGrams >= nisabGoldGrams;
    bool silverEligible = silverGrams >= nisabSilverGrams;
    bool salaryEligible = monthlySalary >= minMonthlySalary;
    bool cashEligible = cash >= (nisabGoldGrams * goldPricePerGram);
    bool investmentsEligible = investments >= (nisabGoldGrams * goldPricePerGram);
    bool otherAssetsEligible = otherAssets >= (nisabGoldGrams * goldPricePerGram);

    bool isEligible = goldEligible || silverEligible || salaryEligible || 
                      cashEligible || investmentsEligible || otherAssetsEligible;

    // Calculate values for display
    double goldValue = goldGrams * goldPricePerGram;
    double silverValue = silverGrams * silverPricePerGram;
    double annualSalaryValue = monthlySalary * 12;

    // Show the eligibility result in a dialog
    _showNisabCheckDialog(
      isEligible,
      goldGrams,
      silverGrams,
      monthlySalary,
      goldEligible,
      silverEligible,
      salaryEligible,
      goldValue,
      silverValue,
      annualSalaryValue,
      cash: cash,
      investments: investments,
      otherAssets: otherAssets,
    );
  }

  // Show a dialog with detailed nisab eligibility information
  void _showNisabCheckDialog(
    bool isEligible,
    double goldGrams,
    double silverGrams,
    double monthlySalary,
    bool goldEligible,
    bool silverEligible,
    bool salaryEligible,
    double goldValue,
    double silverValue,
    double annualSalaryValue,
    {
      double cash = 0.0,
      double investments = 0.0,
      double otherAssets = 0.0,
    }
  ) {
    NisabChecker.showNisabCheckDialog(
      context: context,
      isEligible: isEligible,
      goldGrams: goldGrams,
      silverGrams: silverGrams,
      monthlySalary: monthlySalary,
      goldEligible: goldEligible,
      silverEligible: silverEligible,
      salaryEligible: salaryEligible,
      goldValue: goldValue,
      silverValue: silverValue,
      annualSalaryValue: annualSalaryValue,
      nisabGoldGrams: nisabGoldGrams,
      nisabSilverGrams: nisabSilverGrams,
      minMonthlySalary: minMonthlySalary,
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
      calculateZakat: calculateZakat,
      cash: cash,
      investments: investments,
      otherAssets: otherAssets,
    );
  }

  Widget _buildWarningNote(String message) {
    return WarningNote(message: message);
  }

  Widget _buildPriceInfoCard() {
    return PriceInfoCard(
      goldPricePerGram: goldPricePerGram,
      silverPricePerGram: silverPricePerGram,
      lastUpdated: lastUpdated,
      isLoading: isLoading,
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
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              tooltip: 'Refresh metal prices',
              onPressed: _fetchMetalPrices,
            ),
          ],
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
                    // Add the metal prices info card at the top
                    _buildPriceInfoCard(),
                    const SizedBox(height: 16),
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
                          double.tryParse(goldController.text)! <
                              nisabGoldGrams)
                        _buildWarningNote(
                            "Gold amount is less than 85g. Not eligible for Zakat."),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Silver (grams)",
                        controller: silverController,
                        tooltip: "Silver in grams. Must be at least 595g.",
                        icon: Icons.monetization_on_outlined,
                      ),
                      if (double.tryParse(silverController.text) != null &&
                          double.tryParse(silverController.text)! <
                              nisabSilverGrams)
                        _buildWarningNote(
                            "Silver amount is less than 595g. Not eligible for Zakat."),
                      const SizedBox(height: 10),
                      ZakatInputField(
                        label: "Monthly Salary (RM)",
                        controller: salaryController,
                        tooltip: "Minimum RM 3200 per month required.",
                        icon: Icons.account_balance_wallet,
                      ),
                      if (double.tryParse(salaryController.text) != null &&
                          double.tryParse(salaryController.text)! <
                              minMonthlySalary)
                        _buildWarningNote(
                            "Monthly salary is less than RM 3200. Not eligible for Zakat."),
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
                      // Check Nisab Button
                      ElevatedButton.icon(
                        onPressed: checkNisab,
                        icon: const Icon(Icons.help_outline),
                        label: const Text("Check Eligibility (Nisab Calculation)"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Check if you meet the minimum threshold (Nisab) to pay Zakat",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      // Calculate and Reset Buttons
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
                                backgroundColor: isEligible
                                    ? Colors.green.shade700
                                    : Colors.grey,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
    return ZakatResultCard(
      goldValue: goldValue,
      silverValue: silverValue,
      salaryValue: salaryValue,
      totalAssets: totalAssets,
      totalLiabilities: totalLiabilities,
      netWorth: netWorth,
      zakatAmount: zakatAmount,
      isEligible: isEligible,
    );
  }
}
