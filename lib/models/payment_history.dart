import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentHistory {
  final String id;
  final String userId;
  final double amount;
  final String destination;
  final DateTime timestamp;
  final String receiptNumber;
  final String paymentId;
  final String userEmail;
  final String status;

  PaymentHistory({
    required this.id,
    required this.userId,
    required this.amount,
    required this.destination,
    required this.timestamp,
    required this.receiptNumber,
    this.paymentId = '',
    this.userEmail = '',
    this.status = 'completed',
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
      paymentId: data['paymentId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      status: data['status'] ?? 'completed',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'destination': destination,
      'timestamp': Timestamp.fromDate(timestamp),
      'receiptNumber': receiptNumber,
      'paymentId': paymentId,
      'userEmail': userEmail,
      'status': status,
    };
  }
} 