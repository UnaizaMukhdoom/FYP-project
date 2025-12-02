// lib/screens/style_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StyleProfileScreen extends StatefulWidget {
  const StyleProfileScreen({super.key});

  @override
  State<StyleProfileScreen> createState() => _StyleProfileScreenState();
}

class _StyleProfileScreenState extends State<StyleProfileScreen> {
  Map<String, dynamic>? _profileData;
  String? _colorType;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStyleProfile();
  }

  Future<void> _loadStyleProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _error = 'Please sign in to view your style profile';
        _loading = false;
      });
      return;
    }

    try {
      // Fetch latest onboarding data (questionnaire answers)
      final onboardingQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('onboarding')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      Map<String, dynamic>? profileData;
      if (onboardingQuery.docs.isNotEmpty) {
        profileData = onboardingQuery.docs.first.data();
      }

      // Fetch color type from analysis
      String? colorType;
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
          final skinTone = analysisJson['skin_tone'] as Map<String, dynamic>?;
          if (skinTone != null) {
            final category = skinTone['category'] as String? ?? '';
            final undertone = skinTone['undertone'] as String? ?? '';
            colorType = _getSeasonalColorType(category, undertone);
          }
        }
      } catch (e) {
        // Color type fetch failed, continue without it
      }

      setState(() {
        _profileData = profileData;
        _colorType = colorType;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load style profile: $e';
        _loading = false;
      });
    }
  }

  String _getSeasonalColorType(String category, String undertone) {
    final categoryLower = category.toLowerCase();
    final undertoneLower = undertone.toLowerCase();

    if (categoryLower.contains('very fair') || categoryLower.contains('fair')) {
      if (undertoneLower.contains('warm')) {
        return 'Light Spring';
      } else if (undertoneLower.contains('cool')) {
        return 'Light Summer';
      } else {
        return 'Light Spring';
      }
    } else if (categoryLower.contains('medium')) {
      if (undertoneLower.contains('warm')) {
        return 'Deep Autumn';
      } else if (undertoneLower.contains('cool')) {
        return 'Deep Winter';
      } else {
        return 'Deep Autumn';
      }
    } else if (categoryLower.contains('tan') || categoryLower.contains('olive')) {
      if (undertoneLower.contains('warm')) {
        return 'Warm Autumn';
      } else {
        return 'Deep Autumn';
      }
    } else if (categoryLower.contains('deep') || categoryLower.contains('dark')) {
      if (undertoneLower.contains('warm')) {
        return 'Deep Autumn';
      } else {
        return 'Deep Winter';
      }
    } else {
      if (undertoneLower.contains('warm')) {
        return 'Deep Autumn';
      } else if (undertoneLower.contains('cool')) {
        return 'Deep Winter';
      } else {
        return 'Deep Autumn';
      }
    }
  }

  String _formatHeight(double heightCm, bool useFt) {
    if (useFt) {
      final totalInches = heightCm / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return '$feet.${inches.toString().padLeft(1, '0')} ft';
    } else {
      return '${heightCm.toStringAsFixed(0)} cm';
    }
  }

  String _formatWeight(double weightKg, bool useLb) {
    if (useLb) {
      final pounds = (weightKg * 2.20462).toStringAsFixed(0);
      return '$pounds lbs';
    } else {
      return '${weightKg.toStringAsFixed(0)} kg';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Style Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6B5CE7),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Style Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white70,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/questionnaire');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Complete Questionnaire'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_profileData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Style Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  color: Colors.white70,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No style profile found',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Complete the questionnaire to create your style profile',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/questionnaire');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Complete Questionnaire'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final useFt = _profileData!['useFt'] as bool? ?? false;
    final heightCm = (_profileData!['heightCm'] as num?)?.toDouble() ?? 0.0;
    final useLb = _profileData!['useLb'] as bool? ?? false;
    final weightKg = (_profileData!['weightKg'] as num?)?.toDouble() ?? 0.0;
    final bodyType = _profileData!['bodyType'] as String? ?? 'Not set';
    final sizeRange = _profileData!['sizeRange'] as String? ?? 'Not set';
    final fitPrefs = _profileData!['fitPrefs'] as List<dynamic>? ?? [];
    final styleGoal = _profileData!['styleGoal'] as String? ?? 'Not set';

    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Style Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color Type Section
              if (_colorType != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1E),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2C31),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.palette,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Color Type',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _colorType!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to color type details
                        },
                        child: const Text('View'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Preferences Section
              const Text(
                'Preferences',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Body Shape
              _buildPreferenceItem(
                label: 'Body Shape',
                value: bodyType,
                icon: Icons.accessibility_new,
              ),

              // Height
              _buildPreferenceItem(
                label: 'Height',
                value: _formatHeight(heightCm, useFt),
                icon: Icons.height,
              ),

              // Weight
              _buildPreferenceItem(
                label: 'Weight',
                value: _formatWeight(weightKg, useLb),
                icon: Icons.monitor_weight,
              ),

              // Size
              _buildPreferenceItem(
                label: 'Size',
                value: sizeRange,
                icon: Icons.straighten,
              ),

              // Prefer Clothes
              _buildPreferenceItem(
                label: 'Prefer Clothes',
                value: fitPrefs.isNotEmpty ? fitPrefs.join(', ') : 'Not set',
                icon: Icons.checkroom,
              ),

              // Goal
              _buildPreferenceItem(
                label: 'Goal',
                value: styleGoal,
                icon: Icons.flag,
              ),

              const SizedBox(height: 32),

              // Edit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/questionnaire');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5CE7),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white70,
          size: 24,
        ),
        title: Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.white70,
              size: 20,
            ),
          ],
        ),
        onTap: () {
          // TODO: Allow editing individual preferences
        },
      ),
    );
  }
}

