import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/payment_history.dart';

class PaymentHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPaymentRecord({
    required String userId,
    required double amount,
    required String destination,
    required String receiptNumber,
    String? paymentId,
    String? userEmail,
  }) async {
    // Create the payment record
    final paymentData = {
      'userId': userId,
      'amount': amount,
      'destination': destination,
      'timestamp': Timestamp.now(),
      'receiptNumber': receiptNumber,
      'paymentId': paymentId ?? '',
      'userEmail': userEmail ?? '',
      'status': 'completed',
    };
    
    try {
      // Add to user's payment history
      await _firestore.collection('payment_history').add(paymentData);
      
      // Also send a copy to the admin for receipting purposes
      await _firestore.collection('admin_receipts').add({
        ...paymentData,
        'adminProcessed': false,
        'sentToUser': false,
      });
      
      debugPrint('Payment record added successfully');
    } catch (e) {
      debugPrint('Error adding payment record: $e');
      rethrow;
    }
  }

  Stream<List<PaymentHistory>> getUserPaymentHistory(String userId) {
    return _firestore
        .collection('payment_history')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => PaymentHistory.fromFirestore(doc))
          .toList();
    });
  }
  
  // For admin to fetch receipt requests
  Stream<List<DocumentSnapshot>> getAdminReceipts() {
    return _firestore
        .collection('admin_receipts')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
  
  // Mark receipt as sent to user
  Future<void> markReceiptSent(String receiptId) async {
    await _firestore.collection('admin_receipts').doc(receiptId).update({
      'sentToUser': true,
      'sentTimestamp': Timestamp.now(),
    });
  }
  
  // Mark receipt as processed by admin
  Future<void> markReceiptProcessed(String receiptId) async {
    await _firestore.collection('admin_receipts').doc(receiptId).update({
      'adminProcessed': true,
      'processedTimestamp': Timestamp.now(),
    });
  }

  // Request receipt from admin
  Future<void> requestReceiptFromAdmin(String receiptId, String userId, String userEmail) async {
    try {
      // First, check if the receipt exists in admin_receipts
      var receiptDoc = await _firestore
          .collection('admin_receipts')
          .where('receiptNumber', isEqualTo: receiptId)
          .limit(1)
          .get();

      if (receiptDoc.docs.isEmpty) {
        // If not found, get it from payment_history
        var userReceipt = await _firestore
            .collection('payment_history')
            .where('receiptNumber', isEqualTo: receiptId)
            .limit(1)
            .get();

        if (userReceipt.docs.isEmpty) {
          throw Exception('Receipt not found');
        }

        // Create a copy in admin_receipts
        await _firestore.collection('admin_receipts').add({
          ...userReceipt.docs.first.data(),
          'adminProcessed': false,
          'sentToUser': false,
          'requestedByUser': true,
          'requestTimestamp': Timestamp.now(),
        });

        debugPrint('Created receipt request in admin_receipts');
      } else {
        // Update the existing receipt to mark it as requested
        await _firestore.collection('admin_receipts').doc(receiptDoc.docs.first.id).update({
          'requestedByUser': true,
          'requestTimestamp': Timestamp.now(),
        });

        debugPrint('Updated existing receipt to mark as requested');
      }
    } catch (e) {
      debugPrint('Error requesting receipt: $e');
      rethrow;
    }
  }
}