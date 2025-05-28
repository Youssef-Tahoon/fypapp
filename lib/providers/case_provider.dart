import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_model.dart';

class CaseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Case> _cases = [];
  bool _isLoading = false;

  List<Case> get cases => _cases;
  bool get isLoading => _isLoading;

  // Fetch approved cases only for regular users
  Future<void> fetchApprovedCases() async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('cases')
          .where('status', isEqualTo: 'approved')
          .get();

      _cases = snapshot.docs
          .map((doc) => Case.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching cases: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Submit a new case (will be pending by default)
  Future<void> submitCase(Case newCase) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('cases').add({
        ...newCase.toMap(),
        'status': 'pending',
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error submitting case: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stream of cases for the current user
  Stream<List<Case>> getUserCases(String userId) {
    return _firestore
        .collection('cases')
        .where('submittedBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Case.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Delete a case
  Future<void> deleteCase(String caseId) async {
    try {
      await _firestore.collection('cases').doc(caseId).delete();
    } catch (e) {
      print('Error deleting case: $e');
    }
  }
}