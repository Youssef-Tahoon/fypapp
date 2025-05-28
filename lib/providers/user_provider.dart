import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? _user;
  String? _role;
  bool _isLoading = false;

  User? get user => _user;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _role == 'admin';

  UserProvider() {
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (user != null) {
        // Fetch user role when auth state changes
        await _fetchUserRole();
      } else {
        _role = null;
      }
      notifyListeners();
    });
  }

  Future<void> _fetchUserRole() async {
    try {
      print('Fetching user role for uid: ${_user!.uid}');
      final doc = await _firestore.collection('users').doc(_user!.uid).get();
      if (doc.exists) {
        _role = doc.data()?['role'] as String?;
        print('Fetched role: $_role');
      } else {
        print('No user document found, defaulting to user role');
        _role = 'user'; // Default role
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching user role: $e');
      _role = 'user'; // Default to regular user on error
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      print('Attempting to sign in user: $email');
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print('Successfully signed in, fetching role...');
      await _fetchUserRole();
      print('Sign in complete. Role: $_role');
    } catch (e) {
      print('Error during sign in: $e');
      throw _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, {String role = 'user'}) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': role,
      });

      await _fetchUserRole();
    } catch (e) {
      throw _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _auth.signOut();
      _role = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createAdminUser(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create admin document in both collections for redundancy
      await Future.wait([
        // Add to users collection with admin role
        _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'role': 'admin',
        }),
        
        // Add to admins collection
        _firestore.collection('admins').doc(email).set({
          'uid': userCredential.user!.uid,
          'email': email,
        })
      ]);

      print('Admin user created successfully in both collections');
      await _fetchUserRole();
    } catch (e) {
      print('Error creating admin user: $e');
      throw _handleAuthError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAdminStatus(String email) async {
    try {
      // Check admins collection
      final adminDoc = await _firestore.collection('admins').doc(email).get();
      if (adminDoc.exists) return true;

      // Check users collection if user is authenticated
      if (_user != null) {
        final userDoc = await _firestore.collection('users').doc(_user!.uid).get();
        if (userDoc.exists && userDoc.data()?['role'] == 'admin') return true;
      }

      return false;
    } catch (e) {
      print('Error verifying admin status: $e');
      return false;
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': newRole,
      });
      if (_user?.uid == uid) {
        await _fetchUserRole();
      }
    } catch (e) {
      print('Error updating user role: $e');
      throw e;
    }
  }

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email';
        case 'wrong-password':
          return 'Wrong password';
        case 'email-already-in-use':
          return 'Email is already registered';
        case 'invalid-email':
          return 'Invalid email address';
        case 'weak-password':
          return 'Password is too weak';
        default:
          return 'Authentication failed: ${e.message}';
      }
    }
    return 'An error occurred: $e';
  }
} 