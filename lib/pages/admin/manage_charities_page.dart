import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCharitiesPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _addCharity(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final websiteController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Charity'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Charity Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Name is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Description is required' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: websiteController,
                  decoration: InputDecoration(labelText: 'Website (Optional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                try {
                  await _firestore.collection('charities').add({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'website': websiteController.text,
                    'createdAt': FieldValue.serverTimestamp(),
                    'isActive': true,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Charity added successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding charity: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCharity(BuildContext context, String charityId, String charityName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Charity'),
        content: Text('Are you sure you want to delete $charityName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      try {
        await _firestore.collection('charities').doc(charityId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Charity deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting charity: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('charities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final charities = snapshot.data!.docs;

          if (charities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No charities added yet'),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _addCharity(context),
                    icon: Icon(Icons.add),
                    label: Text('Add Charity'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: charities.length,
            padding: EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final charity = charities[index];
              final data = charity.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  leading: Icon(Icons.volunteer_activism),
                  title: Text(data['name'] ?? 'Unnamed Charity'),
                  subtitle: Text(
                    data['description'] ?? 'No description',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(data['description'] ?? 'No description'),
                          if (data['website'] != null && data['website'].isNotEmpty) ...[
                            SizedBox(height: 8),
                            Text(
                              'Website:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(data['website']),
                          ],
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _deleteCharity(
                                  context,
                                  charity.id,
                                  data['name'] ?? 'Unnamed Charity',
                                ),
                                icon: Icon(Icons.delete, color: Colors.red),
                                label: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCharity(context),
        child: Icon(Icons.add),
        backgroundColor: Colors.red[700],
      ),
    );
  }
} 