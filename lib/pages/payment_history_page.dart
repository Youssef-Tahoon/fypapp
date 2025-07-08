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
      return Scaffold(
        appBar: AppBar(
          title: Text('Payment History'),
          backgroundColor: Colors.green.shade700,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Please log in to view your payment history',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Go to Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading payment history',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final payments = snapshot.data ?? [];

          if (payments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No payment history found',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your zakat payment records will appear here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/pay-zakat'),
                    icon: Icon(Icons.credit_card),
                    label: Text('Make a Payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.receipt_long, color: Colors.green.shade700),
                  ),
                  title: Row(
                    children: [
                      Text(
                        'RM ${payment.amount.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: payment.status == 'completed' ? Colors.green.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: payment.status == 'completed' ? Colors.green.shade200 : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          payment.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            color: payment.status == 'completed' ? Colors.green.shade700 : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#${payment.receiptNumber}',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    ],
                  ),
                  onTap: () {
                    // Show detailed receipt view
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.receipt_long, color: Colors.green.shade700),
                            SizedBox(width: 8),
                            Text('Receipt Details'),
                          ],
                        ),
                        content: Container(
                          width: double.maxFinite,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildReceiptRow('Receipt Number', payment.receiptNumber),
                                _buildReceiptRow('Payment ID', payment.paymentId.isNotEmpty 
                                    ? payment.paymentId 
                                    : 'Not available'),
                                Divider(),
                                _buildReceiptRow('Amount', 'RM ${payment.amount.toStringAsFixed(2)}', 
                                    valueStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                _buildReceiptRow('Destination', payment.destination),
                                _buildReceiptRow('Status', payment.status.toUpperCase(), 
                                    valueStyle: TextStyle(
                                      color: payment.status == 'completed' ? Colors.green : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    )),
                                Divider(),
                                _buildReceiptRow('Payment Date', 
                                    DateFormat('dd MMM yyyy').format(payment.timestamp)),
                                _buildReceiptRow('Payment Time', 
                                    DateFormat('HH:mm:ss').format(payment.timestamp)),
                                SizedBox(height: 16),
                                Text('If you need a formal receipt, please contact admin.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Close'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green.shade700,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              
                              try {
                                final userProvider = Provider.of<UserProvider>(context, listen: false);
                                await _paymentHistoryService.requestReceiptFromAdmin(
                                  payment.receiptNumber,
                                  userProvider.user!.uid,
                                  userProvider.user?.email ?? '',
                                );
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Receipt request submitted to admin'),
                                    backgroundColor: Colors.green.shade700,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to request receipt: ${e.toString()}'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.email),
                            label: Text('Request Receipt'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                            ),
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
  
  Widget _buildReceiptRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: valueStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
