// lib/screens/camera_options_screen.dart
import 'package:flutter/material.dart';
import 'check_item_camera_screen.dart';
import 'create_outfit_screen.dart';

/// Camera Options Screen - Professional UI/UX with modern design
class CameraOptionsScreen extends StatelessWidget {
  const CameraOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _CustomAppBar(),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    // Title Section
                    _TitleSection(),
                    const SizedBox(height: 48),
                    // Options Cards
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _ProfessionalOptionCard(
                              title: 'Check item',
                              description: 'Check if an item suit you, style it or find similar.',
                              icon: Icons.checkroom_outlined,
                              primaryColor: const Color(0xFF6366F1),
                              secondaryColor: const Color(0xFF8B5CF6),
                              imageWidget: _CheckItemImage(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckItemCameraScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _ProfessionalOptionCard(
                              title: 'Plan your outfit',
                              description: 'Mix, match, and style your perfect look.',
                              icon: Icons.style_outlined,
                              primaryColor: const Color(0xFFEC4899),
                              secondaryColor: const Color(0xFFF472B6),
                              imageWidget: _PlanOutfitImage(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateOutfitScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom App Bar
class _CustomAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Title Section
class _TitleSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to do?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose an option to get started',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

// Professional Option Card
class _ProfessionalOptionCard extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final Widget imageWidget;
  final VoidCallback onTap;

  const _ProfessionalOptionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.imageWidget,
    required this.onTap,
  });

  @override
  State<_ProfessionalOptionCard> createState() => _ProfessionalOptionCardState();
}

class _ProfessionalOptionCardState extends State<_ProfessionalOptionCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A1A1A),
                const Color(0xFF1F1F1F),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: widget.primaryColor.withOpacity(0.1),
                blurRadius: 30,
                offset: const Offset(0, 0),
                spreadRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.primaryColor.withOpacity(0.15),
                          widget.secondaryColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        widget.imageWidget,
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  const Color(0xFF1A1A1A).withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Content Section
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                widget.icon,
                                color: widget.primaryColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13,
                            height: 1.5,
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Check Item Image with scanning line effect
class _CheckItemImage extends StatefulWidget {
  @override
  State<_CheckItemImage> createState() => _CheckItemImageState();
}

class _CheckItemImageState extends State<_CheckItemImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // T-shirt representation
        Center(
          child: Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[800]!,
                  Colors.grey[700]!,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.checkroom,
              size: 60,
              color: Colors.white70,
            ),
          ),
        ),
        // Scanning line animation
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Positioned(
              top: 20 + (_animation.value * 80),
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF4FC3F7),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4FC3F7).withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Plan Outfit Image with clothing items collage
class _PlanOutfitImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Clothing items positioned around
        Positioned(
          top: 25,
          left: 20,
          child: _ClothingItemWidget(
            color: Colors.blue[700]!,
            size: 32,
            icon: Icons.checkroom,
          ),
        ),
        Positioned(
          top: 35,
          right: 18,
          child: _ClothingItemWidget(
            color: Colors.lightBlue[300]!,
            size: 38,
            icon: Icons.checkroom,
          ),
        ),
        Positioned(
          bottom: 30,
          left: 25,
          child: _ClothingItemWidget(
            color: Colors.red[400]!,
            size: 35,
            icon: Icons.checkroom,
          ),
        ),
        Positioned(
          bottom: 25,
          right: 25,
          child: _ClothingItemWidget(
            color: Colors.brown[300]!,
            size: 28,
            icon: Icons.checkroom,
          ),
        ),
        // Plus icon overlay
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.black,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _ClothingItemWidget extends StatelessWidget {
  final Color color;
  final double size;
  final IconData icon;

  const _ClothingItemWidget({
    required this.color,
    required this.size,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}
