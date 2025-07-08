import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfPreviewWidget extends StatefulWidget {
  final Map<String, dynamic> pdfData;
  final bool isAdmin;
  
  const PdfPreviewWidget({
    super.key, 
    required this.pdfData,
    this.isAdmin = false,
  });

  @override
  State<PdfPreviewWidget> createState() => _PdfPreviewWidgetState();
}

class _PdfPreviewWidgetState extends State<PdfPreviewWidget> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  final PdfViewerController _pdfViewerController = PdfViewerController();
  Uint8List? _pdfBytes;

  @override
  void initState() {
    super.initState();
    _loadPdfData();
  }

  Future<void> _loadPdfData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      String? base64Data = widget.pdfData['pdfData'];
      if (base64Data != null && base64Data.isNotEmpty) {
        // Remove the data URL prefix if it exists
        if (base64Data.startsWith('data:application/pdf;base64,')) {
          base64Data = base64Data.substring('data:application/pdf;base64,'.length);
        }

        // Decode the base64 string to bytes
        _pdfBytes = base64Decode(base64Data);
        
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Invalid PDF data';
        });
      }
    } catch (e) {
      print('Error loading PDF data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Error loading PDF: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading PDF document...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPdfData,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_pdfBytes == null) {
      return Center(
        child: Text('No PDF data available'),
      );
    }

    // Show PDF metadata and buttons
    return Column(
      children: [
        // PDF metadata
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filename: ${widget.pdfData['pdfName']}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Size: ${(widget.pdfData['pdfSize'] / 1024).toStringAsFixed(1)} KB',
                style: TextStyle(fontSize: 12),
              ),
              if (widget.pdfData['uploadTime'] != null) 
                Text(
                  'Uploaded: ${widget.pdfData['uploadTime']}',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
        
        SizedBox(height: 12),
        
        // PDF viewer
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SfPdfViewer.memory(
                _pdfBytes!,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDoubleTapZooming: true,
                enableTextSelection: true,
              ),
            ),
          ),
        ),
        
        SizedBox(height: 12),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                _pdfViewerController.zoomLevel = 1.0; // Reset zoom
              },
              icon: Icon(Icons.zoom_out_map),
              label: Text('Fit to Screen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            if (widget.isAdmin) ...[
              SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _downloadPdf(context),
                icon: Icon(Icons.download),
                label: Text('Save PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> _downloadPdf(BuildContext context) async {
    try {
      // Display a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Processing PDF...')),
      );
      
      // Get the downloads directory or a suitable storage location
      final directory = await getApplicationDocumentsDirectory();
      final fileName = widget.pdfData['pdfName'] ?? 'downloaded_pdf.pdf';
      final filePath = '${directory.path}/$fileName';
      
      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(_pdfBytes!);
      
      // Share the file using share_plus
      if (context.mounted) {
        try {
          await Share.shareXFiles(
            [XFile(filePath)],
            text: 'PDF Document: ${widget.pdfData['pdfName']}',
          );
          
          Fluttertoast.showToast(
            msg: "PDF ready to share",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } catch (shareError) {
          print('Error sharing file: $shareError');
          // If sharing fails, show the save dialog instead
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('PDF Saved'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('File saved successfully!'),
                      SizedBox(height: 8),
                      Text('Location: $filePath', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      Text(
                        'You can access this file through your device\'s file manager.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error downloading PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
