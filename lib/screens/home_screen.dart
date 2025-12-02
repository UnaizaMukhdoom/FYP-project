import 'dart:io';
import 'package:flutter/material.dart';
import 'ai_stylist_screen.dart';
import 'closet_screen.dart';
import '../services/closet_service.dart';


class HomeScreen extends StatelessWidget {
  static const route = '/';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121316),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2C31),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text('🩷', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Stay lit, babe",
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                  SizedBox(height: 2),
                  Text("Deep Autumn 🍁",
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Color Analysis card   (→ Step 6 flow)
          _BigCard(
            gradient: const [Color(0xFF627CFF), Color(0xFF8AA5FF)],
            title: "Color Analysis",
            subtitle: "Find what color to wear\nbase off your skin tone",
            ctaText: "Let's find out!",
            onTap: () => Navigator.pushNamed(context, '/questionnaire'),
          ),
          const SizedBox(height: 12),

          // Face Shape Analysis card
          _BigCard(
            gradient: const [Color(0xFF9B7EDE), Color(0xFFB8A5E8)],
            title: "Face Shape",
            subtitle: "Discover jewelry that\ncomplements your face",
            ctaText: "Analyze Now",
            onTap: () => Navigator.pushNamed(context, '/face-shape'),
          ),
          const SizedBox(height: 12),

          // AI Stylist + Fit Check (→ Step 7, 8)
          Row(
            children: [
              Expanded(
                child: _SmallCard(
                  bg: const Color(0xFF2A2C31),
                  title: "AI\nStylist",
                  icon: Icons.auto_awesome_outlined,
                  onTap: () => Navigator.pushNamed(context, AIStylistScreen.route),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallCard(
                  bg: const Color(0xFFFFC857),
                  title: "Fit\nCheck",
                  icon: Icons.check_circle_outline,
                  onTap: () => Navigator.pushNamed(context, '/fitcheck-intro'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text("Checked items",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          // Closet / Checked Items (→ Step 9) - Now shows actual items
          StreamBuilder<List<ClosetItem>>(
            stream: ClosetService.getRecentCheckedItems(limit: 3),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _CheckedItemCard(
                  title: "Check if item suit you,\nstyle it and find similar.",
                  badge: "Loading...",
                  onScan: null,
                );
              }

              final items = snapshot.data ?? [];
              
              if (items.isEmpty) {
                return _CheckedItemCard(
                  title: "Check if item suit you,\nstyle it and find similar.",
                  badge: "No items yet",
                  onScan: () => Navigator.pushNamed(context, ClosetScreen.route),
                );
              }

              // Show recent checked items
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show items in a horizontal scrollable list
                  SizedBox(
                    height: 140,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Container(
                          width: 120,
                          margin: EdgeInsets.only(
                            right: index < items.length - 1 ? 12 : 0,
                          ),
                          child: _CheckedItemMiniCard(
                            item: item,
                            onTap: () => Navigator.pushNamed(context, ClosetScreen.route),
                          ),
                        );
                      },
                    ),
                  ),
                  // Show "View All" button if there are items
                  if (items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, ClosetScreen.route),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${items.length} checked item${items.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'View all',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Text("Personal stylist",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),

          // Personal Stylist / Tips (→ Step 10)
          _PersonalRow(
            onTips: () => Navigator.pushNamed(context, '/tips'),
            onPremium: () => Navigator.pushNamed(context, '/premium'),
          ),

          const SizedBox(height: 100),
        ],
      ),

      // Bottom bar like screenshot (center camera tab highlighted)
      bottomNavigationBar: _BottomBar(
        onHome: () {},
        onCloset: () => Navigator.pushNamed(context, '/closet'),
        onSnap: () => Navigator.pushNamed(context, '/camera-options'),
        onAI: () => Navigator.pushNamed(context, '/ai'),
        onProfile: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile coming soon")),
          );
        },
      ),
    );
  }
}

/* ----- Reusable cards (same style as your screenshot) ----- */

class _BigCard extends StatelessWidget {
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onTap;

  const _BigCard({
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      height: 150,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 6),
                Text(subtitle, style: const TextStyle(color: Colors.white, height: 1.2)),
                const Spacer(),
                ElevatedButton(onPressed: onTap, child: Text(ctaText)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 86, height: 86,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(38), // Changed from withOpacity(.15)
              borderRadius: BorderRadius.circular(43),
            ),
            child: const Center(
                child: Icon(Icons.face_retouching_natural_outlined, size: 40)),
          ),
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final Color bg;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _SmallCard({
    required this.bg,
    required this.title,
    required this.icon,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          height: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 32),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckedItemCard extends StatelessWidget {
  final String title;
  final String badge;
  final VoidCallback? onScan;
  final String? imagePath;

  const _CheckedItemCard({
    required this.title,
    required this.badge,
    this.onScan,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2C31),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(30),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: Colors.green[400],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              height: 1.3,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          if (imagePath != null && imagePath!.isNotEmpty && File(imagePath!).existsSync())
            Container(
              height: 120,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF1E1F22),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Items'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withAlpha(30)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini card for displaying checked items in horizontal list
class _CheckedItemMiniCard extends StatelessWidget {
  final ClosetItem item;
  final VoidCallback onTap;

  const _CheckedItemMiniCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    if (item.suitability >= 90) {
      badgeColor = Colors.green.shade400;
    } else if (item.suitability >= 70) {
      badgeColor = Colors.green.shade300;
    } else if (item.suitability >= 50) {
      badgeColor = Colors.orange.shade300;
    } else {
      badgeColor = Colors.redAccent.shade100;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2C31),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E1F22),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                      ? Image.file(
                          File(item.imagePath),
                          fit: BoxFit.cover,
                        )
                      : item.imageUrl.isNotEmpty
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.checkroom_outlined,
                                    color: Colors.white54,
                                  ),
                                );
                              },
                            )
                          : const Center(
                              child: Icon(
                                Icons.checkroom_outlined,
                                color: Colors.white54,
                              ),
                            ),
                ),
              ),
            ),
            // Title and badge
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.suitabilityText,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalRow extends StatelessWidget {
  final VoidCallback onTips;
  final VoidCallback onPremium;

  const _PersonalRow({
    required this.onTips,
    required this.onPremium,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.lightbulb_outline,
            title: 'Style Tips',
            subtitle: 'Get personalized tips',
            onTap: onTips,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.workspace_premium,
            title: 'Premium',
            subtitle: 'Get more features',
            onTap: onPremium,
            isPremium: true,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isPremium;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isPremium = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF2A2C31),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: isPremium ? Colors.amber[400] : Colors.white,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPremium ? Colors.amber[400] : Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Bottom Nav matching screenshot */
class _BottomBar extends StatelessWidget {
  final VoidCallback onHome;
  final VoidCallback onCloset;
  final VoidCallback onSnap;
  final VoidCallback onAI;
  final VoidCallback onProfile;

  const _BottomBar({
    required this.onHome,
    required this.onCloset,
    required this.onSnap,
    required this.onAI,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BottomBarItem(
                icon: Icons.home_outlined,
                label: 'Home',
                onTap: onHome,
                isSelected: true,
              ),
              _BottomBarItem(
                icon: Icons.checkroom_outlined,
                label: 'Closet',
                onTap: onCloset,
              ),
              _SnapButton(onTap: onSnap),
              _BottomBarItem(
                icon: Icons.auto_awesome_outlined,
                label: 'AI',
                onTap: onAI,
              ),
              _BottomBarItem(
                icon: Icons.person_outline,
                label: 'Profile',
                onTap: onProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.white : Colors.white.withAlpha(102),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.white : Colors.white.withAlpha(102),
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SnapButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF627CFF), Color(0xFF8AA5FF)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF627CFF).withAlpha(50),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
