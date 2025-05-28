import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _adminUser;
  bool _isLoading = false;
  bool _isVerifiedAdmin = false;

  User? get adminUser => _adminUser;
  bool get isLoading => _isLoading;
  bool get isAdminLoggedIn => _adminUser != null && _isVerifiedAdmin;

  AdminProvider() {
    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      _adminUser = user;
      if (user != null) {
        await _verifyAdminStatus();
      } else {
        _isVerifiedAdmin = false;
      }
      notifyListeners();
    });
  }

  Future<void> _verifyAdminStatus() async {
    if (_adminUser == null) {
      _isVerifiedAdmin = false;
      notifyListeners();
      return;
    }

    try {
      print('Verifying admin status for user: ${_adminUser?.email}');
      
      // Check admins collection
      final adminDoc = await _firestore
          .collection('admins')
          .doc(_adminUser?.email)
          .get();

      // Check users collection for admin role
      final userDoc = await _firestore
          .collection('users')
          .doc(_adminUser?.uid)
          .get();

      _isVerifiedAdmin = adminDoc.exists || 
          (userDoc.exists && userDoc.data()?['role'] == 'admin');
      
      print('Admin verification result: $_isVerifiedAdmin');
      notifyListeners();
    } catch (e) {
      print('Error verifying admin status: $e');
      _isVerifiedAdmin = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('Attempting admin sign in: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _adminUser = userCredential.user;
      await _verifyAdminStatus();

      if (!_isVerifiedAdmin) {
        print('User is not an admin, signing out');
        await signOut();
        throw 'Unauthorized: Admin access required';
      }
    } catch (e) {
      print('Error during admin sign in: $e');
      _adminUser = null;
      _isVerifiedAdmin = false;
      throw e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _adminUser = null;
      _isVerifiedAdmin = false;
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      notifyListeners();
    }
  }
} 