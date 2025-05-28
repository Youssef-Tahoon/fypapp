import 'package:flutter/material.dart';
import 'package:fyp_zakaty_app/pages/zakat_calculator_page.dart';
import 'package:fyp_zakaty_app/main.dart';

class PayZakatPage extends StatefulWidget {
  const PayZakatPage({super.key});

  @override
  State<PayZakatPage> createState() => _PayZakatPageState();
}

class _PayZakatPageState extends State<PayZakatPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final amountController = TextEditingController();
  final cardNumberController = TextEditingController();
  final cardNameController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    amountController.dispose();
    cardNumberController.dispose();
    cardNameController.dispose();
    emailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void processPayment() {
    // Placeholder: Logic to process payment securely
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment processed successfully!")),
    );
  }

  void contributeToCase(String caseName) {
    // Placeholder: Logic to contribute to selected case
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contributed to: $caseName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Zakat'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pay to Admin'),
            Tab(text: 'Support a Case'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            tooltip: 'Payment History',
            onPressed: () {
              Navigator.pushNamed(context, '/payment-history');
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/zakat_calculator'),
                  child: const Text("Calculate My Zakat"),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Zakat Amount (RM)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: cardNumberController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Card Number",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: cardNameController,
                  decoration: const InputDecoration(
                    labelText: "Cardholder Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: processPayment,
                    child: const Text("Pay Zakat"),
                  ),
                ),
              ],
            ),
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCaseCard(
                title: "Medical Emergency",
                description: "Help fund urgent surgery for a child in need.",
                raised: 2400,
                goal: 5000,
              ),
              _buildCaseCard(
                title: "Education Fund",
                description: "Support orphans in completing their school year.",
                raised: 1200,
                goal: 3000,
              ),
              _buildCaseCard(
                title: "Debt Relief",
                description: "Assist a struggling family with urgent debt payment.",
                raised: 800,
                goal: 2000,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaseCard({
    required String title,
    required String description,
    required double raised,
    required double goal,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (raised / goal).clamp(0.0, 1.0),
              color: Colors.green,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text("Raised: RM ${raised.toStringAsFixed(2)} / RM ${goal.toStringAsFixed(2)}"),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => contributeToCase(title),
                child: const Text("Contribute"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
