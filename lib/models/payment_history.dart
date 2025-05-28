import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistory {
  final String id;
  final String userId;
  final double amount;
  final String destination;
  final DateTime timestamp;
  final String receiptNumber;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.amount,
    required this.destination,
    required this.timestamp,
    required this.receiptNumber,
  });

  factory PaymentHistory.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return PaymentHistory(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      destination: data['destination'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      receiptNumber: data['receiptNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'destination': destination,
      'timestamp': Timestamp.fromDate(timestamp),
      'receiptNumber': receiptNumber,
    };
  }
} 