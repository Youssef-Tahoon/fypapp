import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProvider with ChangeNotifier {
  User? _adminUser;
  bool _isLoading = false;

  User? get adminUser => _adminUser;
  bool get isLoading => _isLoading;
  bool get isAdminLoggedIn => _adminUser != null;

  void setAdmin(User user) {
    _adminUser = user;
    notifyListeners();
  }

  void clearAdmin() {
    _adminUser = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    clearAdmin();
  }
} 