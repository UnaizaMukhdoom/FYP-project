// premium_screen.dart
import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  static const route = '/premium';
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(title: const Text("Premium")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _plan("Weekly", "\$2.99 / week"),
            _plan("Monthly", "\$7.99 / month"),
            const Spacer(),
            ElevatedButton(onPressed: () {}, child: const Text("Continue")),
          ],
        ),
      ),
    );
  }

  Widget _plan(String title, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1F22), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_outlined),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(price, style: const TextStyle(color: Colors.white70)),
            ],
          )),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
