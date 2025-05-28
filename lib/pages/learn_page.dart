import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LearnPage extends StatelessWidget {
  const LearnPage({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _buildResourceCard({
    required String title,
    required String description,
    required String articleUrl,
    required String videoUrl,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => _launchURL(articleUrl),
                  icon: const Icon(Icons.link),
                  label: const Text('Read Article'),
                ),
                const SizedBox(width: 10),
                TextButton.icon(
                  onPressed: () => _launchURL(videoUrl),
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Watch Video'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn About Zakat")),
      body: ListView(
        children: [
          _buildResourceCard(
            title: "Understanding Zakat: The Third Pillar of Islam",
            description: "Zakat is a fundamental aspect of Islam, emphasizing almsgiving and social welfare.",
            articleUrl: "https://www.transparenthands.org/concept-purpose-and-importance-of-zakat-in-islam/",
            videoUrl: "https://www.youtube.com/watch?v=BCoePhCIgpE",
          ),
          _buildResourceCard(
            title: "Calculating Zakat: A Practical Guide",
            description: "Simplified guidance for accurately calculating your Zakat obligation.",
            articleUrl: "https://www.hidaya.org/documents/mailers/HF_PracticalGuideforCalculatingZakat.pdf",
            videoUrl: "https://www.youtube.com/watch?v=27_NFmvwrpM",
          ),
          _buildResourceCard(
            title: "Distribution of Zakat: Who Are the Recipients?",
            description: "Zakat is designated for specific categories of beneficiaries.",
            articleUrl: "https://www.zakat.org/the-eight-kinds-of-people-who-receive-zakat",
            videoUrl: "https://www.youtube.com/watch?v=LBJ1iUNAm_c",
          ),
          _buildResourceCard(
            title: "The Importance of Zakat in Modern Society",
            description: "Zakat promotes economic justice and social welfare today.",
            articleUrl: "https://www.zakat.org/importance-of-zakat-in-islam",
            videoUrl: "https://www.youtube.com/watch?v=6YYlb_g09wo",
          ),
          _buildResourceCard(
            title: "Common Questions About Zakat Answered",
            description: "This resource addresses the most frequently asked questions about Zakat.",
            articleUrl: "https://www.investopedia.com/terms/z/zakat.asp",
            videoUrl: "https://www.youtube.com/watch?v=F1HgxsoBUYQ",
          ),
        ],
      ),
    );
  }
}
