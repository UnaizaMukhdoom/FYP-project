// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildSection(
              '1. Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
              '• Personal information (name, email address)\n'
              '• Profile information (body measurements, style preferences)\n'
              '• Images you upload for analysis\n'
              '• Usage data and app interactions',
            ),
            _buildSection(
              '2. How We Use Your Information',
              'We use the information we collect to:\n\n'
              '• Provide personalized fashion recommendations\n'
              '• Analyze your skin tone and suggest colors\n'
              '• Improve our services and user experience\n'
              '• Send you updates and notifications (with your consent)',
            ),
            _buildSection(
              '3. Data Storage',
              'Your data is stored securely using Firebase services:\n\n'
              '• Authentication data is encrypted\n'
              '• Images are stored securely in Firebase Storage\n'
              '• Profile data is stored in Cloud Firestore\n'
              '• We implement industry-standard security measures',
            ),
            _buildSection(
              '4. Data Sharing',
              'We do not sell your personal information. We may share data only:\n\n'
              '• With your explicit consent\n'
              '• To comply with legal obligations\n'
              '• To protect our rights and safety',
            ),
            _buildSection(
              '5. Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Request deletion of your data\n'
              '• Update or correct your information\n'
              '• Opt-out of marketing communications',
            ),
            _buildSection(
              '6. Children\'s Privacy',
              'Our app is not intended for children under 13. We do not knowingly collect personal information from children.',
            ),
            _buildSection(
              '7. Changes to This Policy',
              'We may update this privacy policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have questions about this Privacy Policy, please contact us at:\n\n'
              'Email: privacy@vogueai.com\n'
              'Support: support@vogueai.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

