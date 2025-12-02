// tips_screen.dart
import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  static const route = '/tips';
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(title: const Text("Tips & Inspiration")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _Tip("Do", "Earthy tones, warm neutrals, gold accessories."),
          _Tip("Don't", "Icy pastels and cool grey near face."),
          _Tip("Inspiration", "Olive utility jacket + cream knit + rust scarf."),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String label, text;
  const _Tip(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xFF1E1F22), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }
}
