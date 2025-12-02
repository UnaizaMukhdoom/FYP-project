// lib/screens/outfit_planner_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/outfit.dart';
import '../services/wardrobe_service.dart';
import 'add_wardrobe_item_screen.dart';

class OutfitPlannerScreen extends StatefulWidget {
  const OutfitPlannerScreen({super.key});

  @override
  State<OutfitPlannerScreen> createState() => _OutfitPlannerScreenState();
}

class _OutfitPlannerScreenState extends State<OutfitPlannerScreen> {
  Outfit? _quickOutfit;
  List<Outfit> _generatedOutfits = [];
  List<Outfit> _savedOutfits = [];
  bool _isLoadingQuick = false;
  bool _isLoadingGenerated = false;
  bool _showGenerated = false;

  @override
  void initState() {
    super.initState();
    _loadSavedOutfits();
  }

  void _loadSavedOutfits() {
    // Load saved outfits from shared preferences or local storage
    // For now, we'll keep them in memory
  }

  Future<void> _getQuickOutfit() async {
    setState(() {
      _isLoadingQuick = true;
      _showGenerated = false;
    });

    try {
      final outfit = await WardrobeService.getOutfitOfTheDay();
      setState(() {
        _quickOutfit = outfit;
        _isLoadingQuick = false;
      });
    } catch (e) {
      setState(() => _isLoadingQuick = false);
      if (mounted) {
        if (e.toString().contains('No items')) {
          _showAddItemsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _generateOutfits() async {
    setState(() {
      _isLoadingGenerated = true;
      _showGenerated = true;
    });

    try {
      final outfits = await WardrobeService.generateOutfits();
      setState(() {
        _generatedOutfits = outfits;
        _isLoadingGenerated = false;
      });
    } catch (e) {
      setState(() => _isLoadingGenerated = false);
      if (mounted) {
        if (e.toString().contains('No items') || e.toString().contains('empty')) {
          _showAddItemsDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showAddItemsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Items First'),
        content: const Text(
          'Your wardrobe is empty. Please add some items to your wardrobe first!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWardrobeItemScreen()),
              );
            },
            child: const Text('Add Items'),
          ),
        ],
      ),
    );
  }

  void _saveOutfit(Outfit outfit) {
    if (!_savedOutfits.any((o) => o.id == outfit.id)) {
      setState(() {
        _savedOutfits.add(outfit);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Quick Outfit Section
          _buildQuickOutfitSection(),
          const SizedBox(height: 24),

          // Generate Multiple Outfits Button
          ElevatedButton.icon(
            onPressed: _isLoadingGenerated ? null : _generateOutfits,
            icon: _isLoadingGenerated
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isLoadingGenerated ? 'Generating...' : 'Generate Outfit Ideas'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Generated Outfits
          if (_showGenerated) _buildGeneratedOutfitsSection(),

          // Saved Outfits Section
          if (_savedOutfits.isNotEmpty) _buildSavedOutfitsSection(),
        ],
      ),
    );
  }

  Widget _buildQuickOutfitSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text(
            '⚡ Outfit of the Day',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get a quick outfit suggestion right now!',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (_isLoadingQuick)
            const CircularProgressIndicator(color: Colors.white)
          else if (_quickOutfit != null)
            _buildQuickOutfitContent(_quickOutfit!)
          else
            ElevatedButton(
              onPressed: _getQuickOutfit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFEC4899),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Get Quick Outfit'),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickOutfitContent(Outfit outfit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                outfit.type == 'dress' ? '👗 Dress Outfit' : '👔 Separates Outfit',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: outfit.items.map((item) {
                  return Column(
                    children: [
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _buildItemImage(item.filepath),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.category,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        item.color,
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 ${outfit.reason}',
                style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _saveOutfit(outfit),
          icon: const Icon(Icons.bookmark),
          label: const Text('Save Outfit'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFEC4899),
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratedOutfitsSection() {
    if (_isLoadingGenerated) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(color: Color(0xFFEC4899)),
        ),
      );
    }

    if (_generatedOutfits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Generated Outfits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._generatedOutfits.map((outfit) => _buildOutfitCard(outfit, isSaved: false)),
      ],
    );
  }

  Widget _buildSavedOutfitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Saved Outfits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ..._savedOutfits.map((outfit) => _buildOutfitCard(outfit, isSaved: true)),
      ],
    );
  }

  Widget _buildOutfitCard(Outfit outfit, {required bool isSaved}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${outfit.icon ?? '👔'} ${outfit.name ?? "Outfit"}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? const Color(0xFFEC4899) : Colors.grey,
                ),
                onPressed: () {
                  if (!isSaved) {
                    _saveOutfit(outfit);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: outfit.items.map((item) {
              return SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildItemImage(item.filepath),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: const TextStyle(fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            '💡 ${outfit.reason}',
            style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildItemImage(String filepath) {
    // Build the full URL for the image
    String imageUrl;
    if (filepath.contains('http')) {
      // Already a full URL (for production)
      imageUrl = filepath;
    } else if (filepath.startsWith('/')) {
      // Relative path - add base URL
      imageUrl = '${WardrobeService.baseUrl}$filepath';
    } else {
      // No valid path - show placeholder
      return const Icon(Icons.checkroom, size: 40, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: const Color(0xFFEC4899),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.checkroom, size: 40, color: Colors.grey);
        },
      ),
    );
  }
}

