// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/case_provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  final List<Map<String, String>> _zakatFacts = [
    {
      'title': 'Understanding Zakat',
      'description': 'Zakat is one of the Five Pillars of Islam, requiring Muslims to give 2.5% of their wealth to those in need.',
      'videoUrl': 'https://www.youtube.com/watch?v=wj8SxkzHwVM',
      'imageUrl': 'https://img.youtube.com/vi/wj8SxkzHwVM/0.jpg',
    },
    {
      'title': 'Who Receives Zakat?',
      'description': 'There are eight categories of people eligible to receive Zakat, including the poor, needy, and wayfarers.',
      'videoUrl': 'https://www.youtube.com/watch?v=E0KkYZXn4I0',
      'imageUrl': 'https://img.youtube.com/vi/E0KkYZXn4I0/0.jpg',
    },
    {
      'title': 'Calculating Zakat',
      'description': 'Learn how to calculate your Zakat accurately based on your assets and wealth.',
      'videoUrl': 'https://www.youtube.com/watch?v=7Q3iAD8f5_E',
      'imageUrl': 'https://img.youtube.com/vi/7Q3iAD8f5_E/0.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCases();
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);
    await context.read<CaseProvider>().fetchApprovedCases();
    setState(() => _isLoading = false);
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quick Actions",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.calculate,
                    label: "Calculate Zakat",
                    color: Colors.blue,
                    onTap: () => Navigator.pushNamed(context, '/zakat-calculator'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.payment,
                    label: "Pay Zakat",
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/pay-zakat'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCasesList() {
    return Consumer<CaseProvider>(
      builder: (context, caseProvider, child) {
        if (_isLoading) {
          return _buildShimmerLoading();
        }

        final cases = caseProvider.cases;
        if (cases.isEmpty) {
          return Center(child: Text('No cases available'));
        }

        return AnimationLimiter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseItem = cases[index];
              // Simulated progress - you should track actual donations in your database
              final progress = 0.3; // Replace with actual progress calculation

              return AnimationConfiguration.staggeredList(
                position: index,
                duration: Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              caseItem.title ?? 'Untitled Case',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            SizedBox(height: 8),
                            Text(caseItem.description),
                            SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'RM ${(caseItem.amountNeeded * progress).toStringAsFixed(2)} raised',
                                  style: TextStyle(color: Colors.green),
                                ),
                                Text(
                                  'Goal: RM ${caseItem.amountNeeded.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  '/pay-zakat',
                                  arguments: caseItem,
                                ),
                                child: Text('Donate Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 3,
        itemBuilder: (_, __) => Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(height: 160),
        ),
      ),
    );
  }

  Widget _buildZakatFacts() {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _zakatFacts.length,
        itemBuilder: (context, index) {
          final fact = _zakatFacts[index];
          return Container(
            width: 280,
            margin: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == _zakatFacts.length - 1 ? 16 : 8,
            ),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _launchURL(fact['videoUrl']!),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      fact['imageUrl']!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fact['title']!,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            fact['description']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadCases,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildQuickActions(),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Learn About Zakat",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: 16),
              _buildZakatFacts(),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Active Cases",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(height: 16),
              _buildCasesList(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
