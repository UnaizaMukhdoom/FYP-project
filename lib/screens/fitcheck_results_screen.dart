// lib/screens/fitcheck_results_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'fitcheck_camera_screen.dart';

/// FitCheck Results Screen - Shows analysis results with scores and recommendations
class FitCheckResultsScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, dynamic> results;

  const FitCheckResultsScreen({
    super.key,
    required this.imagePath,
    required this.results,
  });

  Future<void> _shareToWhatsApp(BuildContext context) async {
    try {
      // Create share text with results
      final shareText = '''
🎨 FitCheck Results

📊 Scores:
• Coherence: ${results['coherence']}%
• Color Match: ${results['colorMatch']}%
• Trendiness: ${results['trendiness']}%
• Flattering: ${results['flattering']}%
• Proportion: ${results['proportion']}%
• Versatility: ${results['versatility']}%

⭐ Fit Grade: ${results['fitGrade']}
🍂 Color Season: ${results['colorSeason']}

💬 ${results['summary']}

Check out VOGUE AI for personalized fashion recommendations! 👗✨
      ''';

      // Use system share which will show WhatsApp if installed
      // The share_plus package will automatically include WhatsApp in the share sheet
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        subject: 'My FitCheck Results',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Select WhatsApp from the share options'),
            backgroundColor: Color(0xFF25D366),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareToGeneral(BuildContext context) async {
    try {
      final shareText = '''
🎨 FitCheck Results

📊 Scores:
• Coherence: ${results['coherence']}%
• Color Match: ${results['colorMatch']}%
• Trendiness: ${results['trendiness']}%
• Flattering: ${results['flattering']}%
• Proportion: ${results['proportion']}%
• Versatility: ${results['versatility']}%

⭐ Fit Grade: ${results['fitGrade']}
🍂 Color Season: ${results['colorSeason']}

💬 ${results['summary']}

Check out VOGUE AI for personalized fashion recommendations! 👗✨
      ''';

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        subject: 'My FitCheck Results',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing: $e')),
        );
      }
    }
  }

  void _showShareOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1F22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Share FitCheck Results',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // WhatsApp Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366), // WhatsApp green
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat,
                  color: Colors.white,
                ),
              ),
              title: const Text(
                'Share to WhatsApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Share with your friends',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _shareToWhatsApp(context);
              },
            ),
            const SizedBox(height: 12),
            // Other Apps Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
              ),
              title: const Text(
                'Share to Other Apps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Instagram, Messages, Email, etc.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _shareToGeneral(context);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B5CE7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Your style is on point!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFFFFC857),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Score Cards Grid
            Padding(
              padding: const EdgeInsets.all(20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _ScoreCard(
                    score: results['coherence'] ?? 0,
                    label: 'Coherence',
                  ),
                  _ScoreCard(
                    score: results['colorMatch'] ?? 0,
                    label: 'Color match',
                  ),
                  _ScoreCard(
                    score: results['trendiness'] ?? 0,
                    label: 'Trendiness',
                  ),
                  _ScoreCard(
                    score: results['flattering'] ?? 0,
                    label: 'Flattering',
                  ),
                  _ScoreCard(
                    score: results['proportion'] ?? 0,
                    label: 'Proportion',
                  ),
                  _ScoreCard(
                    score: results['versatility'] ?? 0,
                    label: 'Versatility',
                  ),
                ],
              ),
            ),
            // Image with Fit Grade
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                // Fit Grade Badge
                Positioned(
                  bottom: 20,
                  right: 40,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC857),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          results['fitGrade'] ?? 'B',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'FIT GRADE',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Summary Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF627CFF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      results['summary'] ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Detail Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _DetailCard(
                    icon: Icons.palette,
                    iconColor: Colors.orange,
                    title: 'Fit Color Season',
                    content: results['colorSeason'] ?? 'Soft Autumn',
                    hasIcons: true,
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.color_lens,
                    iconColor: Colors.pink,
                    title: 'Color Match',
                    content: results['colorMatchText'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.push_pin,
                    iconColor: Colors.red,
                    title: 'Occasion',
                    content: results['occasion'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.check_circle,
                    iconColor: Colors.green,
                    title: 'Done well',
                    content: results['doneWell'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  _DetailCard(
                    icon: Icons.rocket_launch,
                    iconColor: Colors.red,
                    title: 'Recommendation',
                    content: results['recommendation'] ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FitCheckCameraScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('New Scan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showShareOptions(context),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final int score;
  final String label;

  const _ScoreCard({
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String content;
  final bool hasIcons;

  const _DetailCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.content,
    this.hasIcons = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (hasIcons) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('🍂', style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      Text('🍁', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

