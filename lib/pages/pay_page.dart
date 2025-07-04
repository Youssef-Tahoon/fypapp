import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:fyp_zakaty_app/pages/zakat_calculator_page.dart';
import 'package:fyp_zakaty_app/main.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/user_provider.dart';

class PayZakatPage extends StatefulWidget {
  const PayZakatPage({super.key});

  @override
  State<PayZakatPage> createState() => _PayZakatPageState();
}

class _PayZakatPageState extends State<PayZakatPage> {
  final amountController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    // If amount is passed from calculator
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args.containsKey('amount')) {
        amountController.text = args['amount'].toString();
      }
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user?.email != null) {
        emailController.text = userProvider.user!.email!;
      }
    });
  }

  Future<void> processPayment() async {
    if (!_validateFields()) return;
    setState(() => isProcessing = true);

    try {
      // 1. Call your backend to create a PaymentIntent
      final response = await http.post(
        Uri.parse(
            'https://buy.stripe.com/test_00w7sLbgm1v98JL1RxaEE01'), // <-- your backend endpoint
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': (double.parse(amountController.text) * 100).toInt(),
          'currency': 'myr',
          'email': emailController.text,
        }),
      );
      final paymentIntent = json.decode(response.body);

      // 2. Initialize payment sheet
      await stripe.Stripe.instance.initPaymentSheet(
        paymentSheetParameters: stripe.SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['clientSecret'],
          merchantDisplayName: 'ZakatEase',
          customerId: emailController.text,
        ),
      );

      // 3. Present payment sheet
      await stripe.Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(
        msg: "Payment Successful!",
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Payment failed: $e",
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Future<void> _launchStripeCheckout() async {
    const url = 'https://buy.stripe.com/test_00w7sLbgm1v98JL1RxaEE01';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  bool _validateFields() {
    if (amountController.text.isEmpty ||
        nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all required fields",
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(emailController.text)) {
      Fluttertoast.showToast(
        msg: "Please enter a valid email address",
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }

    // Validate phone number (basic validation for numbers only)
    final phoneRegex = RegExp(r'^\d{10,}$');
    if (!phoneRegex
        .hasMatch(phoneController.text.replaceAll(RegExp(r'[^0-9]'), ''))) {
      Fluttertoast.showToast(
        msg: "Please enter a valid phone number",
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }

    // Validate amount is a positive number
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: "Please enter a valid amount",
        toastLength: Toast.LENGTH_LONG,
      );
      return false;
    }

    return true;
  }

  void contributeToCase(String caseName) {
    // Placeholder: Logic to contribute to selected case
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Contributed to: $caseName")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pay Zakat'),
          bottom: TabBar(
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
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/zakat_calculator'),
                    child: const Text("Calculate My Zakat"),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    label: 'Amount (RM)',
                    controller: amountController,
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                  _buildTextField(
                    label: 'Full Name',
                    controller: nameController,
                    icon: Icons.person,
                  ),
                  _buildTextField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    readOnly: true,
                  ),
                  _buildTextField(
                    label: 'Phone Number',
                    controller: phoneController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 12,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d{0,12}'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : _launchStripeCheckout,
                      icon: isProcessing
                          ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Icon(Icons.payment),
                      label: Text(isProcessing ? 'Processing...' : 'Pay Now'),
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
                  description:
                      "Support orphans in completing their school year.",
                  raised: 1200,
                  goal: 3000,
                ),
                _buildCaseCard(
                  title: "Debt Relief",
                  description:
                      "Assist a struggling family with urgent debt payment.",
                  raised: 800,
                  goal: 2000,
                ),
              ],
            ),
          ],
        ),
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
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (raised / goal).clamp(0.0, 1.0),
              color: Colors.green,
              backgroundColor: Colors.grey[200],
            ),
            const SizedBox(height: 8),
            Text(
                "Raised: RM ${raised.toStringAsFixed(2)} / RM ${goal.toStringAsFixed(2)}"),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int? maxLength,
    bool readOnly = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType ?? TextInputType.text,
        maxLength: maxLength,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.green.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.green.shade700, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          labelStyle: TextStyle(color: Colors.grey.shade700),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}
