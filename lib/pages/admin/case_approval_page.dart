import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/admin_provider.dart';
import '../../colors/colors.dart';

class CaseApprovalPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _updateCaseStatus(String caseId, String status) async {
    try {
      await _firestore.collection('cases').doc(caseId).update({
        'status': status,
        '${status}At': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating case status: $e');
      throw e;
    }
  }

  Future<void> _viewPdf(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Case Approval'),
        backgroundColor: AppColor.kPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AdminProvider>().signOut();
              Navigator.pushReplacementNamed(context, '/admin-login');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('cases')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final cases = snapshot.data?.docs ?? [];

          if (cases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No pending cases to review',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: cases.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final caseDoc = cases[index];
              final caseData = caseDoc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Case ID: ${caseDoc.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        caseData['title']?.toString() ?? 'Untitled Case',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        caseData['description']?.toString() ?? 'No description provided',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: AppColor.kPrimary),
                          SizedBox(width: 8),
                          Text(
                            'Amount Needed: RM ${caseData['amountNeeded']?.toString() ?? '0'}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (caseData['userEmail'] != null) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Submitted by: ${caseData['userEmail']}',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ],
                      if (caseData['proofUrl'] != null) ...[
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _viewPdf(caseData['proofUrl']),
                          icon: Icon(Icons.description),
                          label: Text('View Proof Document'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.kPrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                await _updateCaseStatus(caseDoc.id, 'rejected');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Case rejected'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.close, color: Colors.red),
                            label: Text(
                              'Reject',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              try {
                                await _updateCaseStatus(caseDoc.id, 'approved');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Case approved'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.check),
                            label: Text('Approve'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
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
} 