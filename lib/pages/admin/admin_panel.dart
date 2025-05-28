import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import 'case_approval_page.dart';

class AdminPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();

    if (!adminProvider.isAdminLoggedIn) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Unauthorized Access'),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/admin-login'),
                child: Text('Go to Admin Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
        backgroundColor: Colors.red[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              adminProvider.signOut();
              Navigator.pushReplacementNamed(context, '/admin-login');
            },
          ),
        ],
      ),
      body: CaseApprovalPage(),
    );
  }
} 