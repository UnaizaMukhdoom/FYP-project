import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/closet_service.dart';
import 'check_item_camera_screen.dart';
import 'dart:io';

class ClosetScreen extends StatelessWidget {
  static const route = '/closet';
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        title: const Text("Closet"),
        backgroundColor: const Color(0xFF121316),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/check-item-camera');
        },
        label: const Text("Scan / Upload"),
        icon: const Icon(Icons.camera_alt_outlined),
        backgroundColor: const Color(0xFFFFD54F),
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<List<ClosetItem>>(
        stream: ClosetService.getClosetItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final items = snapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No items in closet yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan items to add them to your closet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((item) => _ClosetItemWidget(item: item)).toList(),
          );
        },
      ),
    );
  }
}

class _ClosetItemWidget extends StatelessWidget {
  final ClosetItem item;

  const _ClosetItemWidget({required this.item});

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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Image or placeholder
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2C31),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.imagePath),
                      fit: BoxFit.cover,
                    ),
                  )
                : item.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.emoji_people_outlined);
                          },
                        ),
                      )
                    : const Icon(Icons.emoji_people_outlined),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.type,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.suitabilityText,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
