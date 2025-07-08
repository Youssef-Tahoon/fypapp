// lib/pages/admin/receipt_management_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../services/payment_history_service.dart';
import '../../colors/colors.dart';

class ReceiptManagementPage extends StatefulWidget {
  @override
  State<ReceiptManagementPage> createState() => _ReceiptManagementPageState();
}

class _ReceiptManagementPageState extends State<ReceiptManagementPage> {
  final PaymentHistoryService _paymentHistoryService = PaymentHistoryService();
  bool _showOnlyUnprocessed = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt Management'),
        backgroundColor: AppColor.kPrimary,
        actions: [
          IconButton(
            icon: Icon(_showOnlyUnprocessed ? Icons.filter_alt : Icons.filter_alt_off),
            tooltip: _showOnlyUnprocessed ? 'Showing unprocessed only' : 'Showing all receipts',
            onPressed: () {
              setState(() {
                _showOnlyUnprocessed = !_showOnlyUnprocessed;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<DocumentSnapshot>>(
        stream: _paymentHistoryService.getAdminReceipts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final receipts = snapshot.data ?? [];
          
          // Filter receipts if showing only unprocessed
          final filteredReceipts = _showOnlyUnprocessed
              ? receipts.where((doc) => doc.get('adminProcessed') == false).toList()
              : receipts;

          if (filteredReceipts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    _showOnlyUnprocessed 
                        ? 'No unprocessed receipts' 
                        : 'No receipts available',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (_showOnlyUnprocessed) ...[
                    SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showOnlyUnprocessed = false;
                        });
                      },
                      icon: Icon(Icons.filter_alt_off),
                      label: Text('Show all receipts'),
                    )
                  ]
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredReceipts.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final receipt = filteredReceipts[index];
              final data = receipt.data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final amount = (data['amount'] ?? 0.0).toDouble();
              final processed = data['adminProcessed'] ?? false;
              final sent = data['sentToUser'] ?? false;
              final userEmail = data['userEmail'] ?? 'Not provided';
              final requested = data['requestedByUser'] ?? false;
              
              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: processed ? 1 : 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: processed ? Colors.grey.shade300 : AppColor.kPrimary.withOpacity(0.5),
                    width: processed ? 0.5 : 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Receipt #${data['receiptNumber']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          _buildStatusChip(processed, sent),
                        ],
                      ),
                      SizedBox(height: 8),
                      Divider(),
                      SizedBox(height: 8),
                      _buildInfoRow('Amount', 'RM ${amount.toStringAsFixed(2)}'),
                      _buildInfoRow('Date', DateFormat('dd MMM yyyy, HH:mm').format(timestamp)),
                      _buildInfoRow('User Email', userEmail),
                      _buildInfoRow('Payment ID', data['paymentId'] ?? 'N/A'),
                      if (requested) 
                        _buildInfoRow('Status', 'Requested by user', valueStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        )),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (!processed) ...[
                            OutlinedButton.icon(
                              onPressed: () {
                                _paymentHistoryService.markReceiptProcessed(receipt.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Receipt marked as processed')),
                                );
                              },
                              icon: Icon(Icons.check),
                              label: Text('Mark Processed'),
                            ),
                            SizedBox(width: 8),
                          ],
                          if (!sent) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                _showEmailReceiptDialog(context, data, receipt.id);
                              },
                              icon: Icon(Icons.send),
                              label: Text('Send Receipt'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.kPrimary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(bool processed, bool sent) {
    if (processed && sent) {
      return Chip(
        label: Text('Completed'),
        backgroundColor: Colors.green.shade100,
        labelStyle: TextStyle(color: Colors.green.shade800),
        avatar: Icon(Icons.check_circle, size: 16, color: Colors.green.shade800),
      );
    } else if (processed) {
      return Chip(
        label: Text('Processed'),
        backgroundColor: Colors.amber.shade100,
        labelStyle: TextStyle(color: Colors.amber.shade800),
        avatar: Icon(Icons.done, size: 16, color: Colors.amber.shade800),
      );
    } else {
      return Chip(
        label: Text('New'),
        backgroundColor: Colors.blue.shade100,
        labelStyle: TextStyle(color: Colors.blue.shade800),
        avatar: Icon(Icons.new_releases, size: 16, color: Colors.blue.shade800),
      );
    }
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: valueStyle ?? TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEmailReceiptDialog(
    BuildContext context, 
    Map<String, dynamic> data,
    String receiptId,
  ) {
    final TextEditingController messageController = TextEditingController();
    messageController.text = 'Dear valued contributor,\n\nThank you for your zakat payment. Please find your receipt attached.\n\nBest regards,\nZakatEase Admin';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Send Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Send receipt to: ${data['userEmail']}'),
            SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Email Message',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              // In a real app, this would send an actual email with the receipt
              // For now, we'll just mark it as sent
              await _paymentHistoryService.markReceiptSent(receiptId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Receipt sent to ${data['userEmail']}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: Icon(Icons.send),
            label: Text('Send'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.kPrimary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
