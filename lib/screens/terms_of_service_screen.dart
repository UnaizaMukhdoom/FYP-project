// lib/screens/terms_of_service_screen.dart
import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
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
              'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing and using VOGUE AI, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              '2. Use License',
              'Permission is granted to temporarily use VOGUE AI for personal, non-commercial use only. This license shall automatically terminate if you violate any of these restrictions.',
            ),
            _buildSection(
              '3. User Account',
              'You are responsible for:\n\n'
              '• Maintaining the confidentiality of your account\n'
              '• All activities that occur under your account\n'
              '• Providing accurate and complete information',
            ),
            _buildSection(
              '4. User Content',
              'You retain ownership of content you submit. By submitting content, you grant us a license to use, modify, and display such content for the purpose of providing our services.',
            ),
            _buildSection(
              '5. Prohibited Uses',
              'You may not use our service:\n\n'
              '• For any unlawful purpose\n'
              '• To transmit harmful or malicious code\n'
              '• To impersonate others\n'
              '• To interfere with the service\'s operation',
            ),
            _buildSection(
              '6. Service Availability',
              'We strive to provide continuous service but do not guarantee uninterrupted access. We reserve the right to modify or discontinue the service at any time.',
            ),
            _buildSection(
              '7. Intellectual Property',
              'All content, features, and functionality of VOGUE AI are owned by us and are protected by international copyright, trademark, and other intellectual property laws.',
            ),
            _buildSection(
              '8. Disclaimer',
              'The information and recommendations provided by VOGUE AI are for general informational purposes only. We do not guarantee the accuracy, completeness, or usefulness of any information.',
            ),
            _buildSection(
              '9. Limitation of Liability',
              'In no event shall VOGUE AI be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.',
            ),
            _buildSection(
              '10. Changes to Terms',
              'We reserve the right to modify these terms at any time. Your continued use of the service after changes constitutes acceptance of the new terms.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'If you have questions about these Terms of Service, please contact us at:\n\n'
              'Email: legal@vogueai.com\n'
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

