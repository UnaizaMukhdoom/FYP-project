// lib/screens/item_result_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'check_item_camera_screen.dart';
import '../services/closet_service.dart';

/// Item Result Screen - Shows analysis result with rating and scores
class ItemResultScreen extends StatefulWidget {
  final String imagePath;
  final Map<String, dynamic> result;

  const ItemResultScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

  @override
  State<ItemResultScreen> createState() => _ItemResultScreenState();
}

class _ItemResultScreenState extends State<ItemResultScreen> {
  String _selectedFilter = 'Overall';

  @override
  Widget build(BuildContext context) {
    final suitability = widget.result['suitability'] ?? 0;
    final colorScore = widget.result['color'] ?? 0;
    final shapeScore = widget.result['shape'] ?? 0;
    final fitScore = widget.result['fit'] ?? 0;
    final title = widget.result['title'] ?? 'Item';
    final type = widget.result['type'] ?? 'Item';

    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121316),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and rating
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
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
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 40,
                  right: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF627CFF),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Text(
                      '$suitability% SUITS YOU',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Type badge
                Positioned(
                  bottom: 20,
                  left: 40,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Score cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ScoreCard(
                      icon: Icons.palette,
                      score: colorScore,
                      label: 'Color',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      icon: Icons.checkroom,
                      score: shapeScore,
                      label: 'Shape',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ScoreCard(
                      icon: Icons.compare_arrows,
                      score: fitScore,
                      label: 'Fit',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Filter buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _FilterButton(
                    label: 'Color',
                    isSelected: _selectedFilter == 'Color',
                    onTap: () => setState(() => _selectedFilter = 'Color'),
                  ),
                  const SizedBox(width: 12),
                  _FilterButton(
                    label: 'Shape',
                    isSelected: _selectedFilter == 'Shape',
                    onTap: () => setState(() => _selectedFilter = 'Shape'),
                  ),
                  const SizedBox(width: 12),
                  _FilterButton(
                    label: 'Fit',
                    isSelected: _selectedFilter == 'Fit',
                    onTap: () => setState(() => _selectedFilter = 'Fit'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // See how it works link
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  // Show explanation
                },
                child: Row(
                  children: [
                    Text(
                      'See how it work?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.help_outline,
                      color: Colors.white.withOpacity(0.7),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Recommendation panels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RecommendationPanel(
                    icon: Icons.star,
                    iconColor: Colors.green,
                    title: 'Overall',
                    description:
                        'The embroidered kurti set is a generally flattering choice. The color complements your features, and the shape offers a decent silhouette for your body type. The fit is reasonable, providing comfort and style.',
                  ),
                  const SizedBox(height: 16),
                  _RecommendationPanel(
                    icon: Icons.palette,
                    iconColor: Colors.orange,
                    title: 'Color Match',
                    description:
                        'The dark color is flattering for your features, and the embroidery adds a touch of vibrancy.',
                    hasColors: true,
                  ),
                  const SizedBox(height: 16),
                  _RecommendationPanel(
                    icon: Icons.style,
                    iconColor: Colors.blue,
                    title: 'Mix & match suggest',
                    description:
                        'Pair this kurti set with statement jewelry and comfortable footwear for a complete, eye-catching look. Consider adding a bright-colored scarf to enhance the outfit.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Action buttons
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
                            builder: (_) => const CheckItemCameraScreen(),
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
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          // Show loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Saving to closet...'),
                              duration: Duration(seconds: 1),
                            ),
                          );

                          // Save to closet
                          await ClosetService.saveItemToCloset(
                            imagePath: widget.imagePath,
                            title: title,
                            type: type,
                            suitability: suitability,
                            colorScore: colorScore,
                            shapeScore: shapeScore,
                            fitScore: fitScore,
                            additionalData: widget.result,
                          );

                          // Show success
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Saved to closet!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Navigate back after a short delay
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error saving: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save to Closet'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final IconData icon;
  final int score;
  final String label;

  const _ScoreCard({
    required this.icon,
    required this.score,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF1E1F22),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _RecommendationPanel extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final bool hasColors;

  const _RecommendationPanel({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.hasColors = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          if (hasColors) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  '2 personal colors matches!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B0000),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

