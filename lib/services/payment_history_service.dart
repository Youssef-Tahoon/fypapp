import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment_history.dart';

class PaymentHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addPaymentRecord({
    required String userId,
    required double amount,
    required String destination,
    required String receiptNumber,
  }) async {
    await _firestore.collection('payment_history').add({
      'userId': userId,
      'amount': amount,
      'destination': destination,
      'timestamp': Timestamp.now(),
      'receiptNumber': receiptNumber,
    });
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
} 