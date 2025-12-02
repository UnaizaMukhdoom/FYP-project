import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
// import 'package:pull_to_refresh/pull_to_refresh.dart'; // TODO: Uncomment after running flutter pub get
import 'dart:convert';
import '../services/skin_analysis_service.dart';
import '../widgets/empty_state.dart';
import '../utils/error_handler.dart';

class DiscoverScreen extends StatefulWidget {
  static const route = '/discover';
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // final RefreshController _refreshController = RefreshController(initialRefresh: false); // TODO: Uncomment after running flutter pub get
  bool _loading = false;
  List<ClothingItem> _clothingItems = [];
  String? _skinTone;
  String _selectedBrand = 'All Brands';
  List<String> _availableBrands = ['All Brands'];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSkinToneAndScrape();
  }

  Future<void> _loadSkinToneAndScrape() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _showError('Please sign in to discover clothes');
        return;
      }

      // Get skin tone analysis from Firebase
      final analysisDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('analysis')
          .doc('latest')
          .get();

      if (!analysisDoc.exists) {
        _showError('Please complete skin tone analysis first');
        return;
      }

      final analysisData = analysisDoc.data()!;
      final analysisJson = analysisData['analysis'] as Map<String, dynamic>;
      final analysis = AnalysisResult.fromJson(analysisJson);

      _skinTone = analysis.skinTone.category;
      // _recommendedColors = analysis.colorRecommendations.bestColors; // Not used currently

      // Check cache first (to avoid repeated scraping)
      final cached = await _getCachedClothes(uid, _skinTone!);
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _clothingItems = cached;
          _loading = false;
        });
        return;
      }

      // Scrape clothes from API
      await _scrapeClothes(analysis);

    } catch (e) {
      _showError('Error loading: $e');
      setState(() => _loading = false);
    }
  }

  Future<List<ClothingItem>?> _getCachedClothes(String uid, String skinTone) async {
    try {
      final cacheDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('discover_cache')
          .doc(skinTone)
          .get();

      if (cacheDoc.exists) {
        final data = cacheDoc.data()!;
        final itemsJson = data['items'] as List?;
        if (itemsJson != null) {
          return itemsJson.map((item) => ClothingItem.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('Error reading cache: $e');
    }
    return null;
  }

  Future<void> _saveToCache(String uid, String skinTone, List<ClothingItem> items) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('discover_cache')
          .doc(skinTone)
          .set({
        'items': items.map((item) => item.toJson()).toList(),
        'timestamp': FieldValue.serverTimestamp(),
        'skin_tone': skinTone,
      });
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  Future<void> _scrapeClothes(AnalysisResult analysis) async {
    try {
      final response = await http.post(
        Uri.parse('${SkinAnalysisService.baseUrl}/scrape-clothes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'skin_tone': analysis.skinTone.category,
          'best_colors': analysis.colorRecommendations.bestColors,
          'undertone': analysis.skinTone.undertone,
          'max_items': 10,  // Reduced for faster response
        }),
      ).timeout(const Duration(seconds: 30));  // Reduced timeout

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final itemsJson = data['clothing_items'] as List;
          final items = itemsJson.map((item) => ClothingItem.fromJson(item)).toList();
          
          // Extract unique brands
          final brands = items.map((item) => item.brand).toSet().toList();
          brands.sort();
          
          // Save to cache
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            await _saveToCache(uid, _skinTone!, items);
          }

          setState(() {
            _clothingItems = items;
            _availableBrands = ['All Brands', ...brands];
            _loading = false;
          });
          
          // Show message if no items found
          if (items.isEmpty) {
            final message = data['message'] ?? 'No items found. The scraping might have timed out or websites blocked the request.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.orange[700],
                duration: const Duration(seconds: 5),
              ),
            );
          }
        } else {
          _showError(data['error'] ?? 'Failed to scrape clothes');
        }
      } else {
        _showError('Server error: ${response.statusCode}. Please check if the API server is running.');
      }
    } catch (e) {
      _showError(ErrorHandler.getErrorMessage(e));
      setState(() => _loading = false);
      // _refreshController.refreshFailed(); // TODO: Uncomment after running flutter pub get
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _loading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await _loadSkinToneAndScrape();
    // _refreshController.refreshCompleted(); // TODO: Uncomment after running flutter pub get
  }

  List<ClothingItem> get _filteredItems {
    if (_selectedBrand == 'All Brands') {
      return _clothingItems;
    }
    return _clothingItems.where((item) => item.brand == _selectedBrand).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121316),
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSkinToneAndScrape,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _loading && _clothingItems.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFC857),
              ),
            )
          : _errorMessage != null && _clothingItems.isEmpty
              ? EmptyState(
                  title: 'Error Loading Items',
                  message: _errorMessage,
                  icon: Icons.error_outline,
                  iconColor: Colors.red[300],
                  action: ElevatedButton(
                    onPressed: _loadSkinToneAndScrape,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC857),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Retry'),
                  ),
                )
              : _clothingItems.isEmpty
                  ? EmptyItemsState(
                      message: 'No clothing items found. Try refreshing or check back later.',
                      onRefresh: _loadSkinToneAndScrape,
                    )
                  : Column(
                      children: [
                        // Brand filter
                        if (_availableBrands.length > 1)
                          Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _availableBrands.length,
                              itemBuilder: (context, index) {
                                final brand = _availableBrands[index];
                                final isSelected = _selectedBrand == brand;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(brand),
                                    selected: isSelected,
                                    onSelected: (selected) {
                                      setState(() {
                                        _selectedBrand = brand;
                                      });
                                    },
                                    selectedColor: const Color(0xFFFFC857),
                                    labelStyle: TextStyle(
                                      color: isSelected ? Colors.black : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    backgroundColor: const Color(0xFF1E1F22),
                                  ),
                                );
                              },
                            ),
                          ),
                        // Items grid (pull-to-refresh disabled until package is installed)
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                return _ClothingItemCard(item: item);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class ClothingItem {
  final String id;
  final String brand;
  final String title;
  final String color;
  final String price;
  final String url;
  final String imageUrl;

  ClothingItem({
    required this.id,
    required this.brand,
    required this.title,
    required this.color,
    required this.price,
    required this.url,
    required this.imageUrl,
  });

  factory ClothingItem.fromJson(Map<String, dynamic> json) {
    return ClothingItem(
      id: json['id'] ?? '',
      brand: json['brand'] ?? 'Unknown',
      title: json['title'] ?? 'Untitled',
      color: json['color'] ?? 'Unknown',
      price: json['price']?.toString() ?? 'N/A',
      url: json['url'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'brand': brand,
      'title': title,
      'color': color,
      'price': price,
      'url': url,
      'image_url': imageUrl,
    };
  }
}

class _ClothingItemCard extends StatelessWidget {
  final ClothingItem item;

  const _ClothingItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1F22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF2A2C31),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: item.imageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFC857),
                              strokeWidth: 2,
                            ),
                          );
                        },
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
            ),
          ),
          // Details
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.brand,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (item.color.isNotEmpty && item.color != 'Unknown')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC857).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.color,
                            style: const TextStyle(
                              color: Color(0xFFFFC857),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Text(
                        item.price,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

