// lib/pages/cases_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../providers/case_provider.dart';
import '../providers/user_provider.dart';
import '../models/case_model.dart';
import '../colors/colors.dart';
import 'package:flutter/services.dart';

// Dialog state class to hold form validation states
class DialogState {
  String? titleError;
  String? descriptionError;
  String? amountError;
  String? pdfError;
}

class CasesPage extends StatefulWidget {
  const CasesPage({super.key});

  @override
  State<CasesPage> createState() => _CasesPageState();
}

class _CasesPageState extends State<CasesPage> {
  @override
  void initState() {
    super.initState();
    // Fetch approved cases when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CaseProvider>().fetchApprovedCases();
    });
  }

  Future<String?> _uploadPdf() async {
    try {
      print('Starting PDF upload process...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        final file = result.files.first;
        print('File selected: ${file.name}');
        print('File size: ${file.size} bytes');
        print('File path: ${file.path}');
        print('File bytes: ${file.bytes?.length ?? 'null'}');

        if (file.bytes == null) {
          print('Error: File bytes are null');
          return null;
        }

        if (file.bytes!.isEmpty) {
          print('Error: File bytes are empty');
          return null;
        }

        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        print('Uploading file: $fileName');

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('case_proofs')
            .child(fileName);

        print('Storage reference created: ${storageRef.fullPath}');

        final uploadTask = await storageRef.putData(
          file.bytes!,
          SettableMetadata(
            contentType: 'application/pdf',
            customMetadata: {
              'originalName': file.name,
              'uploadedAt': DateTime.now().toIso8601String(),
            },
          ),
        );

        print('Upload task completed');
        print('Bytes uploaded: ${uploadTask.bytesTransferred}');

        final downloadUrl = await uploadTask.ref.getDownloadURL();
        print('Download URL obtained: $downloadUrl');

        return downloadUrl;
      } else {
        print('No file selected');
        return null;
      }
    } catch (e) {
      print('Error uploading PDF: $e');
      print('Error type: ${e.runtimeType}');
      if (e is FirebaseException) {
        print('Firebase error code: ${e.code}');
        print('Firebase error message: ${e.message}');
      }
      return null;
    }
  }

  void _submitNewCase(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final userProvider = context.read<UserProvider>();
    String? pdfUrl;
    bool isUploading = false;
    final dialogState = DialogState();

    // Add listeners for character counting
    titleController.addListener(() {
      if (context.mounted) {
        setState(() {}); // This will update the counter display
      }
    });

    descriptionController.addListener(() {
      if (context.mounted) {
        setState(() {}); // This will update the counter display
      }
    });

    if (!userProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to submit a case')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Submit New Case'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      maxLength: 25,
                      decoration: InputDecoration(
                        labelText: 'Case Title',
                        hintText: 'Enter a brief title (max 25 characters)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '${titleController.text.length}/25',
                        counterStyle: TextStyle(
                          color: titleController.text.length > 25 
                              ? Colors.red 
                              : Colors.grey,
                        ),
                        errorText: dialogState.titleError,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      maxLength: 300,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Case Description',
                        hintText: 'Describe the case in detail (max 300 characters)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '${descriptionController.text.length}/300',
                        counterStyle: TextStyle(
                          color: descriptionController.text.length > 300 
                              ? Colors.red 
                              : Colors.grey,
                        ),
                        alignLabelWithHint: true,
                        errorText: dialogState.descriptionError,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount Needed (RM)',
                        hintText: 'Enter amount in RM',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: 'RM ',
                        errorText: dialogState.amountError,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: isUploading
                          ? null
                          : () async {
                              setDialogState(() => isUploading = true);
                              try {
                                pdfUrl = await _uploadPdf();
                                if (pdfUrl != null) {
                                  setDialogState(() {
                                    isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('PDF uploaded successfully!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  setDialogState(() {
                                    isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('PDF upload cancelled or failed.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              } catch (e) {
                                setDialogState(() {
                                  isUploading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error uploading PDF: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      icon: Icon(isUploading ? Icons.hourglass_empty : Icons.upload_file),
                      label: Text(isUploading ? 'Uploading...' : 'Upload PDF Proof (Optional)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.kPrimary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'PDF proof is optional for demonstration purposes',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    if (pdfUrl != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'PDF uploaded successfully!',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                    if (dialogState.pdfError != null) ...[
                      SizedBox(height: 8),
                      Text(
                        dialogState.pdfError!,
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final description = descriptionController.text.trim();
                    final amount = double.tryParse(amountController.text) ?? 0;
                    
                    // Reset errors
                    dialogState.titleError = null;
                    dialogState.descriptionError = null;
                    dialogState.amountError = null;
                    dialogState.pdfError = null;
                    
                    // Validation checks
                    bool hasError = false;
                    
                    if (title.isEmpty) {
                      dialogState.titleError = 'Please enter a title';
                      hasError = true;
                    }
                    
                    if (description.isEmpty) {
                      dialogState.descriptionError = 'Please enter a description';
                      hasError = true;
                    } else if (description.length < 25) {
                      dialogState.descriptionError = 'Description must be at least 25 characters';
                      hasError = true;
                    }
                    
                    if (amount <= 0) {
                      dialogState.amountError = 'Please enter a valid amount';
                      hasError = true;
                    }
                    
                    // PDF is now optional
                    // if (pdfUrl == null) {
                    //   dialogState.pdfError = 'Please upload a PDF proof document';
                    //   hasError = true;
                    // }
                    
                    if (hasError) {
                      setDialogState(() {}); // Update the UI to show errors
                      return;
                    }
                    
                    await context.read<CaseProvider>().submitCase(
                      Case(
                        title: title,
                        description: description,
                        amountNeeded: amount,
                        submittedBy: userProvider.user!.uid,
                        userEmail: userProvider.user!.email ?? '',
                        proofUrl: pdfUrl, // This can now be null
                      ),
                    );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Case submitted for approval')),
                    );
                  },
                  child: const Text('Submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.kPrimary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Cases'),
        backgroundColor: AppColor.kPrimary,
      ),
      body: Consumer<CaseProvider>(
        builder: (context, caseProvider, child) {
          if (caseProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (caseProvider.cases.isEmpty) {
            return Center(
              child: Text('No approved cases available at the moment.'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: caseProvider.cases.length,
            itemBuilder: (context, index) {
              final caseItem = caseProvider.cases[index];
              return Card(
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
                        caseItem.title ?? 'Untitled Case',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: 8),
                      Text(
                        caseItem.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: caseItem.progressPercentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            caseItem.progressPercentage >= 100 
                                ? Colors.green 
                                : AppColor.kPrimary,
                          ),
                          minHeight: 8,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Raised: RM ${caseItem.amountRaised.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.kPrimary,
                                ),
                              ),
                              Text(
                                'Goal: RM ${caseItem.amountNeeded.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (caseItem.proofUrl != null)
                            IconButton(
                              icon: Icon(Icons.description),
                              onPressed: () {
                                // TODO: Implement PDF viewer
                              },
                              tooltip: 'View Proof Document',
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      if (caseItem.donations != null && caseItem.donations!.isNotEmpty) ...[
                        Divider(),
                        Text(
                          'Recent Donations',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        ...caseItem.donations!.take(3).map((donation) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                donation['donorName'] ?? 'Anonymous',
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                'RM ${donation['amount'].toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.kPrimary,
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _submitNewCase(context),
        child: const Icon(Icons.add),
        backgroundColor: AppColor.kPrimary,
      ),
    );
  }
}
