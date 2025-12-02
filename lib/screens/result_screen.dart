// lib/screens/result_screen.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/skin_analysis_service.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic>? results;

  const ResultScreen({super.key, this.results});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  int _currentPage = 0;
  final PageController _pageController = PageController();
  Color? _selectedColor;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.results ?? (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?);

    if (args == null) {
      return const Scaffold(
        body: Center(child: Text('No results available')),
      );
    }

    final String path = (args['path'] ?? '') as String;
    final analysis = args['analysis'] as AnalysisResult?;

    if (analysis != null) {
      return _buildMultiPageResult(context, path, analysis);
    } else {
      return _buildLoadingScreen(path);
    }
  }

  Widget _buildMultiPageResult(BuildContext context, String path, AnalysisResult analysis) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Column(
        children: [
          // Purple Gradient Header
          _buildGradientHeader(context),
          
          // Progress Indicator (4 segments)
          _buildProgressIndicator(),
          
          // PageView for 4 screens
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                // Screen 1: Personal Color Type
                _buildScreen1(path, analysis),
                
                // Screen 2: Your Best Color
                _buildScreen2(path, analysis),
                
                // Screen 3: Color to Avoid
                _buildScreen3(path, analysis),
                
                // Screen 4: Foundation, Lipstick & Blush
                _buildScreen4(path, analysis),
              ],
            ),
          ),
          
          // Bottom Navigation
          _buildBottomNav(context),
        ],
      ),
    );
  }

  // Purple Gradient Header
  Widget _buildGradientHeader(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B5CE7), Color(0xFF5B4CD7)],
        ),
        ),
        child: SafeArea(
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Expanded(
                child: Text(
                  'Personal color result',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4-Segment Progress Indicator
  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: index <= _currentPage ? 60 : 30,
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentPage ? const Color(0xFF6B5CE7) : const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  // SCREEN 1: Personal Color Type
  Widget _buildScreen1(String path, AnalysisResult analysis) {
    final skinTone = analysis.skinTone;
    
    // Determine color type for ring arc (based on skin tone category)
    final ringColor = _getColorTypeForRing(skinTone.category);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
          const SizedBox(height: 24),
          
          // Face Photo with Ring
          _buildFacePhotoWithRing(path, ringColor, 220),
          
          const SizedBox(height: 24),
          
          // Your Color Type Label
          const Text(
            'Your Color Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            skinTone.category,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Attribute Cards (2×2 grid, 160×120px each)
          Row(
            children: [
              Expanded(
                child: _buildAttributeCard(
                  icon: '👁️',
                  label: 'Eye color',
                  value: analysis.eyeColor,
                  color: _getEyeColor(analysis.eyeColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttributeCard(
                  icon: '💇',
                  label: 'Hair color',
                  value: analysis.hairColor,
                  color: _getHairColor(analysis.hairColor),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildAttributeCard(
                  icon: '🎨',
                  label: 'Undertone',
                  value: skinTone.undertone,
                  color: _getUndertoneColor(skinTone.undertone),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttributeCard(
                  icon: '✨',
                  label: 'Skin tone',
                  value: skinTone.category,
                  color: _getSkinToneColor(skinTone.category),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // SCREEN 2: Your Best Color
  Widget _buildScreen2(String path, AnalysisResult analysis) {
    final bestColors = _getBestColorPalette(analysis.colorRecommendations.bestColors);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Face Photo with Green Ring Arc
          _buildFacePhotoWithRing(path, const Color(0xFF4ADE80), 220),
          
          const SizedBox(height: 32),
          
          // Instruction Text (Gold)
          const Text(
            'Tap a color to try on',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // 🌈 Your best color section
          _buildColorSection(
            title: '🌈 Your best color',
            colors: bestColors,
            firstColor: const Color(0xFF4ADE80),
          ),
          
          const SizedBox(height: 24),
          
          // Bottom Toolbar (Light grey bar with 5 icons)
          _buildBottomToolbar(),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // SCREEN 3: Color to Avoid
  Widget _buildScreen3(String path, AnalysisResult analysis) {
    final avoidColors = _getAvoidColorPalette(analysis.colorRecommendations.avoidColors);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Face Photo with Pink Ring Arc
          _buildFacePhotoWithRing(path, const Color(0xFFFFB4C8), 220),
          
          const SizedBox(height: 32),
          
          // Instruction Text (Gold)
          const Text(
            'Tap a color to try on',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // ❌ Color to avoid section
          _buildColorSection(
            title: '❌ Color to avoid',
            colors: avoidColors,
            firstColor: const Color(0xFFFFB4C8),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // SCREEN 4: Foundation, Lipstick & Blush
  Widget _buildScreen4(String path, AnalysisResult analysis) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // Face Photo with Cream Ring Arc
          _buildFacePhotoWithRing(path, const Color(0xFFFFF8DC), 220),
          
          const SizedBox(height: 32),
          
          // Instruction Text (Gold)
          const Text(
            'Tap a color to try on',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          // 💧 Foundation color
          _buildMakeupSection(
            emoji: '💧',
            title: 'Foundation color',
            unlockedColor: const Color(0xFFFFF8DC),
            totalSwatches: 2,
          ),
          
          const SizedBox(height: 24),
          
          // 💄 Lipstick color
          _buildMakeupSection(
            emoji: '💄',
            title: 'Lipstick color',
            unlockedColor: null,
            totalSwatches: 2,
          ),
          
                const SizedBox(height: 24),
          
          // 😊 Blush color
          _buildMakeupSection(
            emoji: '😊',
            title: 'Blush color',
            unlockedColor: null,
            totalSwatches: 2,
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Face Photo with Colored Ring Arc
  Widget _buildFacePhotoWithRing(String path, Color arcColor, double size) {
    return SizedBox(
      height: size,
      width: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dark grey base ring
          CustomPaint(
            size: Size(size, size),
            painter: _ColoredRingPainter(
              baseColor: const Color(0xFF3D3D3D),
              arcColor: arcColor,
              strokeWidth: 12,
            ),
          ),
          // Profile Image
          Container(
            height: size - 40,
            width: size - 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: path.isNotEmpty
                  ? DecorationImage(
                      image: FileImage(File(path)),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: path.isEmpty ? const Color(0xFF2C2C2E) : null,
            ),
          ),
        ],
      ),
    );
  }

  // Attribute Card (160×120px)
  Widget _buildAttributeCard({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 160,
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
                const Spacer(),
                Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 60,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Color Section (Best Colors / Avoid Colors)
  Widget _buildColorSection({
    required String title,
    required List<Color> colors,
    required Color firstColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: colors.length > 6 ? 6 : colors.length,
              itemBuilder: (context, index) {
                final isLocked = index > 0;
                final displayColor = index == 0 ? firstColor : colors[index];
                
                return GestureDetector(
                  onTap: isLocked
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Unlock premium to try all colors!')),
                          );
                        }
                      : () {
                          setState(() => _selectedColor = displayColor);
                        },
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: EdgeInsets.only(right: index < (colors.length > 6 ? 5 : colors.length - 1) ? 12 : 0),
                    decoration: BoxDecoration(
                      color: isLocked ? const Color(0xFF2C2C2E) : displayColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedColor == displayColor ? Colors.white : Colors.white.withOpacity(0.3),
                        width: _selectedColor == displayColor ? 2 : 1,
                      ),
                    ),
                    child: isLocked
                        ? const Icon(Icons.lock, color: Colors.white70, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Makeup Section (Foundation, Lipstick, Blush)
  Widget _buildMakeupSection({
    required String emoji,
    required String title,
    required Color? unlockedColor,
    required int totalSwatches,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$emoji $title',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              totalSwatches,
              (index) {
                final isLocked = unlockedColor == null || index > 0;
                final displayColor = unlockedColor ?? const Color(0xFF2C2C2E);
                
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: index < totalSwatches - 1 ? 12 : 0),
                    child: GestureDetector(
                      onTap: isLocked
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Unlock premium to try all colors!')),
                              );
                            }
                          : () {
                              setState(() => _selectedColor = displayColor);
                            },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: isLocked ? const Color(0xFF2C2C2E) : displayColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedColor == displayColor ? Colors.white : Colors.white.withOpacity(0.3),
                            width: _selectedColor == displayColor ? 2 : 1,
                          ),
                        ),
                        child: isLocked
                            ? const Icon(Icons.lock, color: Colors.white70, size: 20)
                            : null,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Bottom Toolbar (Light grey bar with 5 icons)
  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildToolbarIcon(Icons.grid_view),
          _buildToolbarIcon(Icons.face),
          _buildToolbarIcon(Icons.share),
          _buildToolbarIcon(Icons.brush),
          _buildToolbarIcon(Icons.history),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${icon.toString()} feature coming soon!')),
        );
      },
    );
  }

  // Bottom Navigation
  Widget _buildBottomNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
    child: Row(
      children: [
          const Spacer(),
          
          // Share icon
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share feature coming soon!')),
              );
            },
            icon: const Icon(Icons.share, color: Colors.white70),
          ),
          
          const SizedBox(width: 12),
          
          // Back arrow
          if (_currentPage > 0)
            IconButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
            ),
          
          const SizedBox(width: 12),
          
          // Next arrow / Done
          IconButton(
            onPressed: () {
              if (_currentPage < 3) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
              }
            },
            icon: Icon(
              _currentPage < 3 ? Icons.arrow_forward : Icons.check,
              color: _currentPage < 3 ? Colors.white70 : const Color(0xFFFFD700),
            ),
          ),
      ],
    ),
  );
}

  // Color mapping functions
  Color _getColorTypeForRing(String category) {
    // Map skin tone category to ring color
    final colorMap = {
      'Very Fair': const Color(0xFFE6E6FA), // Lavender
      'Fair': const Color(0xFF89CFF0), // Baby Blue
      'Medium': const Color(0xFF4ADE80), // Green
      'Tan/Olive': const Color(0xFFFFB4C8), // Pink
      'Deep/Dark': const Color(0xFF9B59B6), // Purple
      'Black': const Color(0xFF2C2C2E), // Dark Grey
    };
    return colorMap[category] ?? const Color(0xFF4ADE80);
  }

  Color _getEyeColor(String eyeColor) {
    final colorMap = {
      'Brown': const Color(0xFF6B4423), // Actual brown, NOT blue
      'Dark Brown': const Color(0xFF654321),
      'Blue': const Color(0xFF4169E1),
      'Green': const Color(0xFF228B22),
      'Hazel': const Color(0xFF8E7618),
      'Gray': const Color(0xFF808080),
    };
    return colorMap[eyeColor] ?? const Color(0xFF6B4423);
  }

  Color _getHairColor(String hairColor) {
    final colorMap = {
      'Black': const Color(0xFF000000), // Pure black
      'Dark Brown': const Color(0xFF3E2723),
      'Brown': const Color(0xFF6D4C41),
      'Light Brown': const Color(0xFF8D6E63),
      'Blonde': const Color(0xFFFFE082),
      'Auburn': const Color(0xFFA52A2A),
      'Gray': const Color(0xFF9E9E9E),
    };
    return colorMap[hairColor] ?? const Color(0xFF000000);
  }

  Color _getUndertoneColor(String undertone) {
    // Map to olive as specified
    if (undertone.contains('Warm') || undertone.contains('Olive')) {
      return const Color(0xFF9B8B6F); // Olive
    } else if (undertone.contains('Cool')) {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFF9B8B6F); // Default to olive
    }
  }

  Color _getSkinToneColor(String category) {
    final colorMap = {
      'Very Fair': const Color(0xFFFFF8E1),
      'Fair': const Color(0xFFFFE0B2),
      'Medium': const Color(0xFFCBB39B), // Beige as specified
      'Tan/Olive': const Color(0xFFD4A574),
      'Deep/Dark': const Color(0xFF8D6E63),
      'Black': const Color(0xFF5D4037),
    };
    return colorMap[category] ?? const Color(0xFFCBB39B);
  }

  List<Color> _getBestColorPalette(List<String> colorNames) {
    final colorMap = {
      'Jewel Tones': const Color(0xFF9B59B6),
      'Teal': const Color(0xFF1ABC9C),
      'Purple': const Color(0xFF8E44AD),
      'Ruby Red': const Color(0xFFE74C3C),
      'Golden Yellow': const Color(0xFFF39C12),
      'Olive Green': const Color(0xFF6B8E23),
      'Magenta': const Color(0xFFE91E63),
      'Cobalt Blue': const Color(0xFF2980B9),
      'Soft Pink': const Color(0xFFFFB6C1),
      'Lavender': const Color(0xFFE6E6FA),
      'Mint Green': const Color(0xFF98FF98),
      'Baby Blue': const Color(0xFF89CFF0),
      'Coral': const Color(0xFFFF7F50),
      'Turquoise': const Color(0xFF40E0D0),
      'Emerald Green': const Color(0xFF50C878),
      'Earth Tones': const Color(0xFF8B7355),
      'Burgundy': const Color(0xFF800020),
      'Forest Green': const Color(0xFF228B22),
      'Mustard Yellow': const Color(0xFFFFDB58),
      'Burnt Orange': const Color(0xFFCC5500),
      'Deep Purple': const Color(0xFF673AB7),
      'Rust': const Color(0xFFB7410E),
      'Gold': const Color(0xFFFFD700),
    };
    return colorNames.map((name) => colorMap[name] ?? const Color(0xFF4ADE80)).take(6).toList();
  }

  List<Color> _getAvoidColorPalette(List<String> colorNames) {
    final colorMap = {
      'Pale Pastels': const Color(0xFFFFF0F5),
      'Washed Out Colors': const Color(0xFFD3D3D3),
      'Nude Beige': const Color(0xFFE5C9A6),
      'Bright Orange': const Color(0xFFFF8C00),
      'Bright Yellow': const Color(0xFFFFFF00),
      'Brown': const Color(0xFF8B4513),
      'Pale Pink': const Color(0xFFFADADD),
    };
    return colorNames.map((name) => colorMap[name] ?? const Color(0xFFFFB4C8)).take(6).toList();
  }

  Widget _buildLoadingScreen(String path) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: path.isNotEmpty ? FileImage(File(path)) : null,
              backgroundColor: const Color(0xFF2C2C2E),
            ),
            const SizedBox(height: 32),
            const Text(
              'Analyzing your photo...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(color: Color(0xFF6B5CE7)),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Colored Ring with Arc Segment
class _ColoredRingPainter extends CustomPainter {
  final Color baseColor;
  final Color arcColor;
  final double strokeWidth;

  _ColoredRingPainter({
    required this.baseColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    
    // Base dark grey ring (full circle)
    final basePaint = Paint()
      ..color = baseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, basePaint);
    
    // Colored arc segment (~90°, top-right)
    final arcPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw arc from top-right (315° to 45° in radians)
    const startAngle = -math.pi / 4; // -45 degrees
    const sweepAngle = math.pi / 2; // 90 degrees
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
