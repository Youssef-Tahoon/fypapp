import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSection(),
          SizedBox(height: 24),
          _buildQuickActions(context),
          SizedBox(height: 24),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cases').snapshots(),
      builder: (context, casesSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, usersSnapshot) {
            if (casesSnapshot.hasError || usersSnapshot.hasError) {
              return Center(
                child: Text('Error loading statistics'),
              );
            }

            if (casesSnapshot.connectionState == ConnectionState.waiting ||
                usersSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Safely calculate statistics
            int totalCases = casesSnapshot.data?.docs.length ?? 0;
            int pendingCases = casesSnapshot.data?.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>?;
              return data?['status'] == 'pending';
            }).length ?? 0;
            int totalUsers = usersSnapshot.data?.docs.length ?? 0;

            // Get active charities count
            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('charities')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, charitiesSnapshot) {
                int activeCharities = charitiesSnapshot.data?.docs.length ?? 0;

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildStatCard(
                      'Total Cases',
                      totalCases.toString(),
                      Icons.cases,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Pending Cases',
                      pendingCases.toString(),
                      Icons.pending_actions,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Total Users',
                      totalUsers.toString(),
                      Icons.people,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'Active Charities',
                      activeCharities.toString(),
                      Icons.volunteer_activism,
                      Colors.purple,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildActionButton(
              context,
              'Add Charity',
              Icons.add_circle,
              Colors.green,
              () {
                // TODO: Implement add charity action
              },
            ),
            _buildActionButton(
              context,
              'Review Cases',
              Icons.approval,
              Colors.orange,
              () {
                // Navigate to case approval page
              },
            ),
            _buildActionButton(
              context,
              'Manage Users',
              Icons.people,
              Colors.blue,
              () {
                // Navigate to manage users page
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cases')
          .orderBy('submittedAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading activities'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No recent activities'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(_getActivityIcon(data['status'] as String?)),
                    title: Text(data['title']?.toString() ?? 'Untitled Case'),
                    subtitle: Text('Status: ${data['status']?.toString() ?? 'Unknown'}'),
                    trailing: Text(
                      '\$${data['amountNeeded']?.toString() ?? '0'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  IconData _getActivityIcon(String? status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      default:
        return Icons.help;
    }
  }
} 