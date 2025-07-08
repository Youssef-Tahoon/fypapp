// lib/pages/cases_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/case_provider.dart';
import '../providers/user_provider.dart';
import '../models/case_model.dart';
import '../colors/colors.dart';
import 'package:flutter/services.dart';
import '../widgets/pdf_preview_widget.dart';

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

  Future<Map<String, dynamic>?> _uploadPdf() async {
    try {
      print('Starting PDF selection process...');
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null) {
        final file = result.files.first;
        print('File selected: ${file.name}');
        print('File size: ${file.size} bytes');
        print('File path: ${file.path}');
        print('Has bytes: ${file.bytes != null}');
        
        // Check if file is too large (10MB limit documents)
        if (file.size > 10 * 1024 * 1024) {
          print('Error: File is too large (max 10MB)');
          throw Exception('PDF file is too large (max 10MB). Please select a smaller file.');
        }

        if (file.bytes == null) {
          print('Error: File bytes are null');
          // Try to read the file using path instead if bytes are null
          try {
            if (file.path != null) {
              final bytes = await File(file.path!).readAsBytes();
              if (bytes.isNotEmpty) {
                print('Successfully read ${bytes.length} bytes from file path');
                
                // Encode bytes to base64
                final base64String = base64Encode(bytes);
                final base64File = 'data:application/pdf;base64,$base64String';
                
                print('Successfully encoded PDF from path to base64 format (${base64String.length} chars)');
                
                // Return PDF data
                return {
                  'pdfName': file.name,
                  'pdfSize': bytes.length,
                  'pdfData': base64File,
                  'uploadTime': DateTime.now().toIso8601String(),
                };
              }
            }
          } catch (e) {
            print('Error reading file from path: $e');
          }
          return null;
        }

        if (file.bytes!.isEmpty) {
          print('Error: File bytes are empty');
          return null;
        }

        try {
          // Convert PDF bytes to base64 string for storage in Firestore
          final bytes = file.bytes!;
          final base64String = base64Encode(bytes);
          final base64File = 'data:application/pdf;base64,$base64String';
          
          print('Successfully encoded PDF to base64 format (${base64String.length} chars)');
          
          // Return PDF data
          return {
            'pdfName': file.name,
            'pdfSize': file.size,
            'pdfData': base64File,
            'uploadTime': DateTime.now().toIso8601String(),
          };
        } catch (e) {
          print('Error encoding PDF: $e');
          throw Exception('Error processing the PDF file. Please try again with a different file.');
        }
      } else {
        print('No file selected');
        return null;
      }
    } catch (e) {
      print('Error with PDF: $e');
      print('Error type: ${e.runtimeType}');
      
      // Add specific error messages based on the error type
      if (e is FileSystemException) {
        throw Exception('File system error: ${e.message}. Please try another file.');
      } else if (e.toString().contains('bytes')) {
        throw Exception('Could not read file data. Please try another file.');
      } else if (e.toString().contains('encode') || e.toString().contains('base64')) {
        throw Exception('Could not encode the PDF file. The file may be corrupted.');
      } else {
        // Rethrow the original exception
        rethrow;
      }
    }
  }

  void _submitNewCase(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final userProvider = context.read<UserProvider>();
    Map<String, dynamic>? pdfData;
    bool isUploading = false;
    final dialogState = DialogState();

    //listeners for character counting
    titleController.addListener(() {
      if (context.mounted) {
        setState(() {});
      }
    });

    descriptionController.addListener(() {
      if (context.mounted) {
        setState(() {});
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
                      maxLength: 40,
                      decoration: InputDecoration(
                        labelText: 'Case Title',
                        hintText: 'Enter a brief title (max 40 characters)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        counterText: '${titleController.text.length}/40',
                        counterStyle: TextStyle(
                          color: titleController.text.length > 40 
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
                                print('Starting PDF upload process...');
                                pdfData = await _uploadPdf();
                                if (pdfData != null) {
                                  print('PDF data received successfully');
                                  setDialogState(() {
                                    isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('PDF selected successfully: ${pdfData!['pdfName']}'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  print('PDF selection returned null');
                                  setDialogState(() {
                                    isUploading = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('PDF selection cancelled or failed.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
                              } catch (e) {
                                print('Error in PDF upload button: $e');
                                setDialogState(() {
                                  isUploading = false;
                                });
                                
                                // Display a user-friendly error message
                                String errorMessage = 'Error with PDF';
                                if (e.toString().contains('too large')) {
                                  errorMessage = 'PDF file is too large (max 10MB).';
                                } else if (e.toString().contains('permission')) {
                                  errorMessage = 'Cannot access file. Please check permissions.';
                                }
                                
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(errorMessage),
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
                      'PDF proof is for proof purposes',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    if (pdfData != null) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Selected PDF: ${pdfData!['pdfName']} (${(pdfData!['pdfSize'] / 1024).toStringAsFixed(1)} KB)',
                              style: TextStyle(color: Colors.green),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                    } else if (description.length < 40) {
                      dialogState.descriptionError = 'Description must be at least 40 characters';
                      hasError = true;
                    }
                    
                    if (amount <= 0) {
                      dialogState.amountError = 'Please enter a valid amount';
                      hasError = true;
                    }
                    
                    if (hasError) {
                      setDialogState(() {});
                      return;
                    }
                    
                    await context.read<CaseProvider>().submitCase(
                      Case(
                        title: title,
                        description: description,
                        amountNeeded: amount,
                        submittedBy: userProvider.user!.uid,
                        userEmail: userProvider.user!.email ?? '',
                        proofUrl: pdfData != null ? pdfData!['pdfName'] : null,
                        pdfData: pdfData, // Store the entire PDF data object
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

  // Show PDF preview dialog for admins or users
  void _showPdfPreview(BuildContext context, Case caseItem) {
    if (caseItem.pdfData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No PDF data available')),
      );
      return;
    }

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
                        'PDF Document: ${caseItem.pdfData!['pdfName']}',
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
                    pdfData: caseItem.pdfData!,
                    isAdmin: _isAdmin(context),
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

  // Check if current user is an admin
  bool _isAdmin(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    // You'd typically check a role field in your user data
    // For this example, let's say users with certain emails are admins
    return userProvider.isAuthenticated && 
           (userProvider.user!.email?.endsWith('@admin.com') ?? false);
  }

  // Method removed - functionality moved to PdfPreviewWidget

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
                          if (caseItem.pdfData != null)
                            IconButton(
                              icon: Icon(Icons.description),
                              onPressed: () {
                                _showPdfPreview(context, caseItem);
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
