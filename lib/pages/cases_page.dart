// lib/pages/cases_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/case_provider.dart';
import '../providers/user_provider.dart';
import '../models/case_model.dart';

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

  void _submitNewCase(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final userProvider = context.read<UserProvider>();

    if (!userProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to submit a case')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Submit New Case'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Case Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Case Description'),
              maxLines: 3,
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount Needed (RM)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text;
              final description = descriptionController.text;
              final amount = double.tryParse(amountController.text) ?? 0;
              
              if (title.isNotEmpty && description.isNotEmpty && amount > 0) {
                await context.read<CaseProvider>().submitCase(
                  Case(
                    title: title,
                    description: description,
                    amountNeeded: amount,
                    submittedBy: userProvider.user!.uid,
                  ),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Case submitted for approval')),
                );
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Cases'),
        backgroundColor: Colors.green.shade700,
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
                child: ListTile(
                  title: Text(caseItem.title ?? 'Untitled Case'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(caseItem.description ?? ''),
                      SizedBox(height: 4),
                      Text(
                        'Amount Needed: RM ${caseItem.amountNeeded.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _submitNewCase(context),
        child: const Icon(Icons.add),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }
}
