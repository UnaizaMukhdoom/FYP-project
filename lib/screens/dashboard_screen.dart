import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/skin_analysis_service.dart';
import 'ai_stylist_screen.dart';
import 'result_screen.dart';
import 'face_shape_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = '';
  String _colorType = '';
  bool _loading = true;
  AnalysisResult? _savedAnalysis;
  String? _savedImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _userName = 'Stylist';
        _colorType = '';
        _loading = false;
      });
      return;
    }

    try {
      // Fetch user's name from onboarding
      final onboardingQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('onboarding')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      String name = 'Stylist';
      if (onboardingQuery.docs.isNotEmpty) {
        final data = onboardingQuery.docs.first.data();
        name = data['name'] as String? ?? 'Stylist';
      }

      // Fetch color analysis to get color type and save for Color Analysis feature
      String colorType = '';
      AnalysisResult? savedAnalysis;
      String? savedImagePath;
      try {
        final analysisDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('analysis')
            .doc('latest')
            .get();

        if (analysisDoc.exists && analysisDoc.data() != null) {
          final analysisData = analysisDoc.data()!;
          final analysisJson = analysisData['analysis'] as Map<String, dynamic>;
          final analysis = AnalysisResult.fromJson(analysisJson);
          
          // Map skin tone to seasonal color type
          colorType = _getSeasonalColorType(analysis.skinTone.category, analysis.skinTone.undertone);
          
          // Save analysis for Color Analysis feature
          savedAnalysis = analysis;
          savedImagePath = analysisData['imagePath'] as String?;
        }
      } catch (e) {
        // If analysis fetch fails (including permission errors), just use empty string
        // Don't show error - silently fail
      }

      setState(() {
        _userName = name;
        _colorType = colorType;
        _savedAnalysis = savedAnalysis;
        _savedImagePath = savedImagePath;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _userName = 'Stylist';
        _colorType = '';
        _loading = false;
      });
    }
  }

  Future<void> _openColorAnalysis(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to view your color analysis')),
      );
      return;
    }

    // First, check if we have saved analysis in state (already loaded)
    if (_savedAnalysis != null && _savedImagePath != null) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              results: {
                'path': _savedImagePath!,
                'analysis': _savedAnalysis!,
              },
            ),
          ),
        );
      }
      return;
    }

    // If not in state, try to fetch from Firebase
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('analysis')
          .doc('latest')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final analysisJson = data['analysis'] as Map<String, dynamic>;
        final imagePath = data['imagePath'] as String? ?? '';

        // Convert back to AnalysisResult
        final analysis = AnalysisResult.fromJson(analysisJson);

        // Update state for future use
        setState(() {
          _savedAnalysis = analysis;
          _savedImagePath = imagePath;
        });

        // Navigate to result screen with saved data (shows all 4 result screens)
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultScreen(
                results: {
                  'path': imagePath,
                  'analysis': analysis,
                },
              ),
            ),
          );
        }
      } else {
        // No saved analysis - show message
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No color analysis found. Please complete skin tone analysis first.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Handle permission errors and other errors gracefully
      // Don't show error message for permission issues - just show no analysis message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No color analysis found. Please complete skin tone analysis first.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF000000),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B5CE7),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Greeting
            _buildHeader(_userName, _colorType),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Color Analysis Card (Large)
                    _ColorAnalysisCard(
                      onTap: () => _openColorAnalysis(context),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Face Shape Analysis Card
                    _FaceShapeCard(
                      onTap: () {
                        Navigator.pushNamed(context, FaceShapeScreen.route);
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // AI Stylist and Fit Check Cards (Side by Side)
                    Row(
                      children: [
                        Expanded(
                          child: _AIStylistCard(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AIStylistScreen.route,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _FitCheckCard(
                            onTap: () {
                              Navigator.pushNamed(context, '/fitcheck-intro');
                            },
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20), // Reduced spacing for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Map skin tone category and undertone to seasonal color type
  String _getSeasonalColorType(String category, String undertone) {
    // Map based on skin tone category and undertone
    final categoryLower = category.toLowerCase();
    final undertoneLower = undertone.toLowerCase();
    
    if (categoryLower.contains('very fair') || categoryLower.contains('fair')) {
      if (undertoneLower.contains('warm')) {
        return 'Light Spring 🌸';
      } else if (undertoneLower.contains('cool')) {
        return 'Light Summer 🌊';
      } else {
        return 'Light Spring 🌸';
      }
    } else if (categoryLower.contains('medium')) {
      if (undertoneLower.contains('warm')) {
        return 'Deep Autumn 🍁';
      } else if (undertoneLower.contains('cool')) {
        return 'Deep Winter ❄️';
      } else {
        return 'Deep Autumn 🍁';
      }
    } else if (categoryLower.contains('tan') || categoryLower.contains('olive')) {
      if (undertoneLower.contains('warm')) {
        return 'Warm Autumn 🍂';
      } else {
        return 'Deep Autumn 🍁';
      }
    } else if (categoryLower.contains('deep') || categoryLower.contains('dark')) {
      if (undertoneLower.contains('warm')) {
        return 'Deep Autumn 🍁';
      } else {
        return 'Deep Winter ❄️';
      }
    } else {
      // Default based on undertone
      if (undertoneLower.contains('warm')) {
        return 'Deep Autumn 🍁';
      } else if (undertoneLower.contains('cool')) {
        return 'Deep Winter ❄️';
      } else {
        return 'Deep Autumn 🍁';
      }
    }
  }

  Widget _buildHeader(String userName, String colorType) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Logo - Pink square with face
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB6C1), // Pink
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Text(
                '😊',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello $userName!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (colorType.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    colorType,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.home, label: 'Home', isActive: true, onTap: () {}),
              _NavItem(icon: Icons.checkroom, label: 'My Closet', onTap: () { Navigator.pushNamed(context, '/closet'); }),
              _NavItem(icon: Icons.camera_alt, label: 'Scan', isCenter: true, onTap: () { Navigator.pushNamed(context, '/camera-options'); }),
              _NavItem(icon: Icons.explore, label: 'Discover', onTap: () { Navigator.pushNamed(context, '/discover'); }),
              _NavItem(icon: Icons.person, label: 'Profile', onTap: () { 
                Navigator.pushNamed(context, '/profile');
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Color Analysis Card - Large Purple Card with Color Wheel
class _ColorAnalysisCard extends StatelessWidget {
  final VoidCallback onTap;

  const _ColorAnalysisCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B5CE7), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Color Analysis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find what color to wear\nbase off your skin tone',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: const Text(
                    "Let's find out!",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Color Wheel with Face
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                  Colors.pink,
                  Colors.red,
                ],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFF000000),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '👩',
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                ),
                // Checkmarks
                const Positioned(
                  top: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
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

// Face Shape Card - Purple Gradient Card
class _FaceShapeCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FaceShapeCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B7EDE), Color(0xFFB8A5E8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Face Shape',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover jewelry that\ncomplements your face',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  child: const Text(
                    'Analyze Now',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Face icon with jewelry
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.face,
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// AI Stylist Card - Purple with Clothing Items
class _AIStylistCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AIStylistCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF6B5CE7),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 140,
          alignment: Alignment.center,
          child: const Text(
            'AI Stylist',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Fit Check Card - Yellow with Photo
class _FitCheckCard extends StatelessWidget {
  final VoidCallback onTap;

  const _FitCheckCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFC857),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: 140,
          alignment: Alignment.center,
          child: const Text(
            'Fit Check',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Bottom Navigation Item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.isCenter = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFFC857),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.black,
                size: 24,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? Colors.white : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white70,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
