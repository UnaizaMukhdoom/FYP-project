// lib/screens/analyzing_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'item_result_screen.dart';
import '../services/item_analysis_service.dart';

/// Analyzing Item Screen - Shows scanning animation with green line
class AnalyzingItemScreen extends StatefulWidget {
  final String imagePath;

  const AnalyzingItemScreen({super.key, required this.imagePath});

  @override
  State<AnalyzingItemScreen> createState() => _AnalyzingItemScreenState();
}

class _AnalyzingItemScreenState extends State<AnalyzingItemScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _analysisComplete = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );

    _startAnalysis();
  }

  Future<void> _startAnalysis() async {
    // Start scanning animation
    _scanController.repeat();

    try {
      // Analyze the item using the API
      final result = await ItemAnalysisService.analyzeItem(widget.imagePath);
      
      // Stop animation
      _scanController.stop();
      _scanController.reset();

      if (!mounted) return;

      // Navigate to result screen with actual analysis result
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItemResultScreen(
            imagePath: widget.imagePath,
            result: result,
          ),
        ),
      );
    } catch (e) {
      // Stop animation
      _scanController.stop();
      _scanController.reset();

      if (!mounted) return;

      // Show error and use fallback result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis error: $e. Using estimated results.'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // Use fallback result with varied scores
      final fallbackResult = ItemAnalysisService.getFallbackResult();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ItemResultScreen(
            imagePath: widget.imagePath,
            result: fallbackResult,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Image
          Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          // Scanning line
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned(
                top: MediaQuery.of(context).size.height * 0.2 +
                    (_scanAnimation.value * MediaQuery.of(context).size.height * 0.6),
                left: 0,
                right: 0,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.green,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Bottom text
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Text(
                  'Analyzing...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Give us a few second, it won\'t take long!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

