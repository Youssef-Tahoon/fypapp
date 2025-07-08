import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../providers/admin_provider.dart';
import '../../colors/colors.dart';
import '../../widgets/pdf_preview_widget.dart';
import '../../models/case_model.dart';

class CaseApprovalPage extends StatefulWidget {
  @override
  State<CaseApprovalPage> createState() => _CaseApprovalPageState();
}

class _CaseApprovalPageState extends State<CaseApprovalPage> {
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

  // Handles viewing PDF regardless of storage format (new Base64 or legacy URL)
  void _viewPdf(BuildContext context, Map<String, dynamic> caseData) async {
    // Check if we have the new PDF data format
    if (caseData['pdfData'] != null) {
      _showPdfPreviewDialog(context, caseData['pdfData']);
      return;
    }
    
    // Legacy URL-based PDF handling
    final proofUrl = caseData['proofUrl'];
    if (proofUrl != null && proofUrl is String) {
      try {
        if (await canLaunchUrlString(proofUrl)) {
          await launchUrlString(proofUrl);
        } else {
          throw 'Could not launch $proofUrl';
        }
      } catch (e) {
        print('Error launching URL: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error viewing PDF: $e')),
        );
      }
      return;
    }
    
    // No PDF found
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No PDF document available')),
    );
  }
  
  // Show PDF preview dialog
  void _showPdfPreviewDialog(BuildContext context, Map<String, dynamic> pdfData) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: EdgeInsets.all(16),
            constraints: BoxConstraints(maxWidth: 600, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'PDF Document: ${pdfData['pdfName']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Expanded(
                  child: PdfPreviewWidget(
                    pdfData: pdfData,
                    isAdmin: true,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

              // Convert to Case model for cleaner code
              final Map<String, dynamic> rawData = caseDoc.data() as Map<String, dynamic>;
              rawData['id'] = caseDoc.id; // Ensure ID is included
              final caseItem = Case.fromMap(rawData);
              
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
                        'Case ID: ${caseItem.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        caseItem.title ?? 'Untitled Case',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        caseItem.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: AppColor.kPrimary),
                          SizedBox(width: 8),
                          Text(
                            'Amount Needed: RM ${caseItem.amountNeeded}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Submitted by: ${caseItem.userEmail}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      if (caseItem.proofUrl != null || caseItem.pdfData != null) ...[
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (caseItem.pdfData != null) {
                              _showPdfPreviewDialog(context, caseItem.pdfData!);
                            } else if (caseItem.proofUrl != null) {
                              _viewPdf(context, rawData);
                            }
                          },
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