// lib/screens/create_outfit_screen.dart
import 'package:flutter/material.dart';
import 'wardrobe_screen.dart';

/// Plan Your Outfit Screen - Navigates to native Flutter wardrobe planner
class CreateOutfitScreen extends StatelessWidget {
  const CreateOutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate directly to the native Flutter wardrobe screen
    return const WardrobeScreen();
  }
}
