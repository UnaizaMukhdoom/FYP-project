// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8D5FF), Color(0xFFFFB6C1)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Firebase Test Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, '/firebase-test'),
                      icon: const Icon(Icons.cloud_done),
                      tooltip: 'Test Firebase Connection',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        foregroundColor: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          'https://t4.ftcdn.net/jpg/04/06/91/91/240_F_406919161_J0pGxe1sewqnk5dnvyRS77MKmEd6SVac.jpg',
                          width: 250,
                          height: 150,
                          fit: BoxFit.contain, // Changed from cover to contain to show full logo
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback to icon if image fails to load
                            return Center(
                              child: Icon(
                                Icons.analytics,
                                size: 150,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Personal Fashion Stylist',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Discover your perfect colors, get AI-powered\n'
                            'style recommendations, and build a wardrobe\n'
                            'that truly reflects your unique style.',
                        style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ProgressBarDot(active: true, width: 30),
                          SizedBox(width: 8),
                          _ProgressBarDot(),
                          SizedBox(width: 8),
                          _ProgressBarDot(),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/signin'),
                      child: const Text('Skip', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signin'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Next', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressBarDot extends StatelessWidget {
  final bool active;
  final double width;
  const _ProgressBarDot({this.active = false, this.width = 8});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: active ? Colors.black : Colors.black26,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}