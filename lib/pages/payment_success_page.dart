// lib/pages/payment_success_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_provider.dart';
import '../services/payment_history_service.dart';
import '../widgets/navigation_helper.dart';

class PaymentSuccessPage extends StatelessWidget {
  final PaymentHistoryService _paymentHistoryService = PaymentHistoryService();

  @override
  Widget build(BuildContext context) {
    // Extract payment data from the arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final double amount = args['amount'] ?? 0.0;
    final String paymentId = args['paymentId'] ?? 'N/A';
    final String receiptNumber = args['receiptNumber'] ?? 'N/A';
    final DateTime timestamp = args['timestamp'] ?? DateTime.now();
    final String destination = args['destination'] ?? 'Zakat Payment';

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid;
    final userEmail = userProvider.user?.email ?? 'anonymous';

    // Save payment record to Firestore
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userId != null) {
        try {
          _paymentHistoryService.addPaymentRecord(
            userId: userId,
            amount: amount,
            destination: destination,
            receiptNumber: receiptNumber,
            paymentId: paymentId,
            userEmail: userEmail,
          );
          print('Payment record saved successfully');
        } catch (e) {
          print('Error saving payment record: $e');
        }
      } else {
        print('Cannot save payment record: User ID is null');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 80,
              ),
            ),
            SizedBox(height: 24),

            // Success message
            Text(
              'Payment Successful!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
            ),
            SizedBox(height: 8),
            Text(
              'Your zakat payment has been processed successfully',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 32),

            // Payment details card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Receipt',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '#$receiptNumber',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _buildDetailRow(
                        'Amount', 'RM ${amount.toStringAsFixed(2)}'),
                    _buildDetailRow(
                        'Date', DateFormat('dd MMM yyyy').format(timestamp)),
                    _buildDetailRow(
                        'Time', DateFormat('HH:mm:ss').format(timestamp)),
                    _buildDetailRow('Payment ID', paymentId),
                    _buildDetailRow('Email', userEmail),
                    SizedBox(height: 8),
                    Text(
                      'A copy of this receipt has been sent to the admin for record keeping.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Push the payment history page onto the stack
                      Navigator.of(context).pushNamed('/payment-history');
                    },
                    icon: Icon(Icons.history),
                    label: Text('View History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Ensure we clear the navigation stack and go to the main navigation
                      _navigateBackToMain(context);
                    },
                    icon: Icon(Icons.home),
                    label: Text('Back to Home'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Method to navigate back to the main app safely
  void _navigateBackToMain(BuildContext context) {
    // Use our dedicated navigation helper widget to ensure proper navigation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => NavigationHelper(destination: '/main_navigation'),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
