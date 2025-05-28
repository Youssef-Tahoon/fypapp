// lib/pages/payment_history_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/payment_history.dart';
import '../services/payment_history_service.dart';
import '../providers/user_provider.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatelessWidget {
  final PaymentHistoryService _paymentHistoryService = PaymentHistoryService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      return Center(child: Text('Please log in to view payment history'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment History'),
        backgroundColor: Colors.green.shade700,
      ),
      body: StreamBuilder<List<PaymentHistory>>(
        stream: _paymentHistoryService.getUserPaymentHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return Center(child: Text('No payment history found'));
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.receipt_long, color: Colors.green.shade700),
                  ),
                  title: Text(
                    'RM ${payment.amount.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('To: ${payment.destination}'),
                      Text(
                        'Date: ${DateFormat('dd MMM yyyy, HH:mm').format(payment.timestamp)}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '#${payment.receiptNumber}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // TODO: Show detailed receipt view
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Receipt Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Receipt Number: ${payment.receiptNumber}'),
                            SizedBox(height: 8),
                            Text('Amount: RM ${payment.amount.toStringAsFixed(2)}'),
                            Text('Destination: ${payment.destination}'),
                            Text('Date: ${DateFormat('dd MMM yyyy').format(payment.timestamp)}'),
                            Text('Time: ${DateFormat('HH:mm:ss').format(payment.timestamp)}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
