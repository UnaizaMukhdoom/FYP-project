// lib/screens/selfie_screen.dart



import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/skin_analysis_service.dart';
import '../utils/image_compressor.dart';
import '../utils/error_handler.dart';

class SelfieScreen extends StatefulWidget {

  const SelfieScreen({super.key});

  @override

  State<SelfieScreen> createState() => _SelfieScreenState();

}

class _SelfieScreenState extends State<SelfieScreen> with SingleTickerProviderStateMixin {

  final _picker = ImagePicker();

  XFile? _picked;

  bool _analyzing = false;

  late AnimationController _pulseController;

  late Animation<double> _pulseAnimation;

  @override

  void initState() {

    super.initState();

    _pulseController = AnimationController(

      duration: const Duration(milliseconds: 2000),

      vsync: this,

    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(

      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),

    );

  }

  @override

  void dispose() {

    _pulseController.dispose();

    super.dispose();

  }

  

  Future<void> _pick(ImageSource src) async {

    final x = await _picker.pickImage(source: src, maxWidth: 1200, maxHeight: 1200, imageQuality: 92);

    if (x != null) {

      setState(() => _picked = x);

    }

  }

  

  Future<void> _analyzeAndNavigate() async {

    if (_picked == null) return;

    

    setState(() => _analyzing = true);

    

    try {

      // Compress image before uploading
      final compressedPath = await ImageCompressor.compressImage(_picked!.path);
      final imagePath = compressedPath ?? _picked!.path;
      
      // Call the analysis API
      final result = await SkinAnalysisService.analyzeImage(imagePath);

      

      if (!mounted) return;

      
      // Save analysis results to Firestore
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('analysis')
              .doc('latest')
              .set({
            'analysis': result.toJson(),
            'imagePath': _picked!.path,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        // If saving fails, continue anyway
        print('Failed to save analysis: $e');
      }

      // Navigate to ResultScreen with analysis results

      Navigator.pushNamed(

        context,

        '/result',

        arguments: {

          'path': _picked!.path,

          'analysis': result,

        },

      );

    } catch (e) {

      if (!mounted) return;

      

      // Show user-friendly error message
      final errorMessage = ErrorHandler.getErrorMessage(e);

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(

          content: Text('$errorMessage. Using defaults.'),

          backgroundColor: Colors.red[700],
          duration: const Duration(seconds: 5),

        ),

      );

      

      // Create a default AnalysisResult for fallback
      final defaultResult = AnalysisResult(
        success: false,
        skinTone: SkinTone(
          category: 'Medium',
          fitzpatrickType: 'Type IV',
          rgb: {'r': 180, 'g': 150, 'b': 120},
          hex: '#B49678',
          brightness: 152.0,
          undertone: 'Neutral',
        ),
        hairColor: 'Brown',
        eyeColor: 'Brown',
        colorRecommendations: ColorRecommendations(
          bestColors: ['Teal', 'Purple', 'Emerald Green', 'Burgundy', 'Gold', 'Forest Green'],
          avoidColors: ['Pale Pastels', 'Washed Out Colors', 'Bright Yellow'],
          neutrals: ['Charcoal', 'Camel', 'Navy'],
          description: 'Default recommendations. Please start the API server for accurate analysis.',
        ),
      );

      // Navigate with default analysis result
      Navigator.pushNamed(

        context,

        '/result',

        arguments: {

          'path': _picked!.path,

          'analysis': defaultResult,

        },

      );

    } finally {

      if (mounted) setState(() => _analyzing = false);

    }

  }

  @override

  Widget build(BuildContext context) {

    final has = _picked != null;

    return Scaffold(

      backgroundColor: const Color(0xFF0A0A0A),

      appBar: AppBar(

        backgroundColor: Colors.transparent,

        elevation: 0,

        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),

          onPressed: () => Navigator.pop(context),

        ),

        title: const Text(

          'Skin Tone Analysis',

          style: TextStyle(

            fontWeight: FontWeight.bold,

            fontSize: 20,

          ),

        ),

        centerTitle: true,

      ),

      body: SafeArea(

        child: Padding(

          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Column(

            children: [

              const SizedBox(height: 20),

              // Instructions Card

              Container(

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(

                  gradient: LinearGradient(

                    colors: [

                      const Color(0xFF6366F1).withOpacity(0.2),

                      const Color(0xFF8B5CF6).withOpacity(0.1),

                    ],

                  ),

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(

                    color: const Color(0xFF6366F1).withOpacity(0.3),

                    width: 1,

                  ),

                ),

                child: Row(

                  children: [

                    Container(

                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(

                        color: const Color(0xFF6366F1).withOpacity(0.2),

                        borderRadius: BorderRadius.circular(12),

                      ),

                      child: const Icon(

                        Icons.info_outline,

                        color: Color(0xFF6366F1),

                        size: 24,

                      ),

                    ),

                    const SizedBox(width: 16),

                    const Expanded(

                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(

                            'Tips for best results',

                            style: TextStyle(

                              color: Colors.white,

                              fontWeight: FontWeight.bold,

                              fontSize: 15,

                            ),

                          ),

                          SizedBox(height: 4),

                          Text(

                            'Use natural lighting and face the camera directly',

                            style: TextStyle(

                              color: Colors.white70,

                              fontSize: 13,

                            ),

                          ),

                        ],

                      ),

                    ),

                  ],

                ),

              ),

              const SizedBox(height: 40),

              // Photo Preview Area

              Expanded(

                child: Center(

                  child: has

                      ? _buildImagePreview()

                      : _buildPlaceholder(),

                ),

              ),

              const SizedBox(height: 30),

              // Action Buttons

              if (has) ...[

                _buildAnalyzeButton(),

                const SizedBox(height: 12),

                _buildSecondaryButton(

                  label: 'Retake Photo',

                  icon: Icons.refresh,

                  onPressed: () => _pick(ImageSource.gallery),

                ),

              ] else ...[

                _buildCameraButton(),

                const SizedBox(height: 12),

                _buildSecondaryButton(

                  label: 'Choose from Gallery',

                  icon: Icons.photo_library_outlined,

                  onPressed: () => _pick(ImageSource.gallery),

                ),

              ],

              const SizedBox(height: 30),

            ],

          ),

        ),

      ),

    );

  }

  Widget _buildImagePreview() {

    return Container(

      width: 300,

      height: 300,

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(30),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF6366F1).withOpacity(0.3),

            blurRadius: 30,

            offset: const Offset(0, 10),

          ),

        ],

      ),

      child: ClipRRect(

        borderRadius: BorderRadius.circular(30),

        child: Stack(

          fit: StackFit.expand,

          children: [

            Image.file(

              File(_picked!.path),

              fit: BoxFit.cover,

            ),

            // Gradient Overlay

            Container(

              decoration: BoxDecoration(

                gradient: LinearGradient(

                  begin: Alignment.topCenter,

                  end: Alignment.bottomCenter,

                  colors: [

                    Colors.transparent,

                    Colors.black.withOpacity(0.3),

                  ],

                ),

              ),

            ),

            // Success Checkmark

            Positioned(

              top: 16,

              right: 16,

              child: Container(

                padding: const EdgeInsets.all(8),

                decoration: BoxDecoration(

                  color: const Color(0xFF4CAF50),

                  borderRadius: BorderRadius.circular(20),

                  boxShadow: [

                    BoxShadow(

                      color: const Color(0xFF4CAF50).withOpacity(0.5),

                      blurRadius: 10,

                    ),

                  ],

                ),

                child: const Icon(

                  Icons.check,

                  color: Colors.white,

                  size: 20,

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _buildPlaceholder() {

    return ScaleTransition(

      scale: _pulseAnimation,

      child: Container(

        width: 300,

        height: 300,

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(30),

          border: Border.all(

            color: const Color(0xFF6366F1).withOpacity(0.3),

            width: 2,

          ),

          gradient: const LinearGradient(

            begin: Alignment.topLeft,

            end: Alignment.bottomRight,

            colors: [

              Color(0xFF1E1E1E),

              Color(0xFF2A2A2A),

            ],

          ),

        ),

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Container(

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(

                color: const Color(0xFF6366F1).withOpacity(0.1),

                shape: BoxShape.circle,

              ),

              child: const Icon(

                Icons.camera_alt_outlined,

                size: 60,

                color: Color(0xFF6366F1),

              ),

            ),

            const SizedBox(height: 20),

            const Text(

              'No photo selected',

              style: TextStyle(

                color: Colors.white70,

                fontSize: 16,

                fontWeight: FontWeight.w500,

              ),

            ),

            const SizedBox(height: 8),

            const Text(

              'Tap below to get started',

              style: TextStyle(

                color: Colors.white38,

                fontSize: 14,

              ),

            ),

          ],

        ),

      ),

    );

  }

  Widget _buildAnalyzeButton() {

    return Container(

      width: double.infinity,

      height: 56,

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],

        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF6366F1).withOpacity(0.5),

            blurRadius: 20,

            offset: const Offset(0, 10),

          ),

        ],

      ),

      child: ElevatedButton(

        onPressed: _analyzing ? null : _analyzeAndNavigate,

        style: ElevatedButton.styleFrom(

          backgroundColor: Colors.transparent,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(28),

          ),

        ),

        child: _analyzing

            ? const Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  SizedBox(

                    width: 20,

                    height: 20,

                    child: CircularProgressIndicator(

                      strokeWidth: 2,

                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),

                    ),

                  ),

                  SizedBox(width: 12),

                  Text(

                    'Analyzing...',

                    style: TextStyle(

                      fontSize: 16,

                      fontWeight: FontWeight.bold,

                      color: Colors.white,

                    ),

                  ),

                ],

              )

            : const Row(

                mainAxisAlignment: MainAxisAlignment.center,

                children: [

                  Icon(Icons.auto_awesome, color: Colors.white),

                  SizedBox(width: 12),

                  Text(

                    'Analyze Skin Tone',

                    style: TextStyle(

                      fontSize: 16,

                      fontWeight: FontWeight.bold,

                      color: Colors.white,

                    ),

                  ),

                ],

              ),

      ),

    );

  }

  Widget _buildCameraButton() {

    return Container(

      width: double.infinity,

      height: 56,

      decoration: BoxDecoration(

        gradient: const LinearGradient(

          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],

        ),

        borderRadius: BorderRadius.circular(28),

        boxShadow: [

          BoxShadow(

            color: const Color(0xFF6366F1).withOpacity(0.5),

            blurRadius: 20,

            offset: const Offset(0, 10),

          ),

        ],

      ),

      child: ElevatedButton.icon(

        onPressed: () => _pick(ImageSource.camera),

        style: ElevatedButton.styleFrom(

          backgroundColor: Colors.transparent,

          shadowColor: Colors.transparent,

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(28),

          ),

        ),

        icon: const Icon(Icons.camera_alt, color: Colors.white),

        label: const Text(

          'Take a Selfie',

          style: TextStyle(

            fontSize: 16,

            fontWeight: FontWeight.bold,

            color: Colors.white,

          ),

        ),

      ),

    );

  }

  Widget _buildSecondaryButton({

    required String label,

    required IconData icon,

    required VoidCallback onPressed,

  }) {

    return SizedBox(

      width: double.infinity,

      height: 56,

      child: OutlinedButton.icon(

        onPressed: onPressed,

        style: OutlinedButton.styleFrom(

          foregroundColor: Colors.white,

          side: BorderSide(

            color: Colors.white.withOpacity(0.2),

            width: 1.5,

          ),

          shape: RoundedRectangleBorder(

            borderRadius: BorderRadius.circular(28),

          ),

        ),

        icon: Icon(icon, size: 20),

        label: Text(

          label,

          style: const TextStyle(

            fontSize: 16,

            fontWeight: FontWeight.w600,

          ),

        ),

      ),

    );

  }

}
