// lib/screens/face_shape_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/face_shape_service.dart';
import '../utils/image_compressor.dart';

class FaceShapeScreen extends StatefulWidget {
  static const route = '/face-shape';
  
  const FaceShapeScreen({super.key});

  @override
  State<FaceShapeScreen> createState() => _FaceShapeScreenState();
}

class _FaceShapeScreenState extends State<FaceShapeScreen> {
  final _picker = ImagePicker();
  XFile? _picked;
  bool _analyzing = false;
  FaceShapeResult? _result;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all'; // 'all', 'earrings', 'necklaces'

  Future<void> _pickImage(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 92,
    );
    
    if (x != null) {
      setState(() {
        _picked = x;
        _result = null;
      });
    }
  }

  Future<void> _analyzeFaceShape() async {
    if (_picked == null) return;

    setState(() => _analyzing = true);

    try {
      // Compress image
      final compressedPath = await ImageCompressor.compressImage(_picked!.path);
      final imagePath = compressedPath ?? _picked!.path;
      
      // Analyze
      final result = await FaceShapeService.analyzeFaceShape(imagePath);

      if (!mounted) return;

      setState(() {
        _result = result;
        _analyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() => _analyzing = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE5DCD8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFA1BC98)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFA1BC98)),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _removeDuplicates(List<dynamic> items) {
    if (items.isEmpty) return [];
    if (items[0] is! Map) return [];
    
    final seen = <String>{};
    final unique = <Map<String, dynamic>>[];
    
    for (var item in items) {
      final map = item as Map<String, dynamic>;
      final image = map['image']?.toString() ?? '';
      final name = map['name']?.toString() ?? '';
      
      // Create unique key from name (case-insensitive) to avoid duplicates
      // This ensures no repetitive items with same name
      final key = name.toLowerCase().trim();
      
      // Only add if:
      // 1. We haven't seen this name before
      // 2. Image is not empty
      // 3. Name is not empty
      if (!seen.contains(key) && image.isNotEmpty && name.isNotEmpty) {
        seen.add(key);
        unique.add(map);
      }
    }
    
    return unique;
  }

  List<Map<String, dynamic>> _filterItems(List<Map<String, dynamic>> items, String category) {
    if (_searchQuery.isEmpty && category == 'all') return items;
    
    return items.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || name.contains(_searchQuery.toLowerCase());
      
      if (category == 'all') return matchesSearch;
      
      // Category filtering is handled by separate sections
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DCD8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE5DCD8),
        elevation: 0,
        title: const Text(
          'Face Shape Analysis',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image picker section
            if (_picked == null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.face, size: 80, color: Color(0xFFA1BC98)),
                    const SizedBox(height: 16),
                    const Text(
                      'Take a clear face photo',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _showImageSourceDialog,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA1BC98),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(_picked!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_analyzing && _result == null)
                    ElevatedButton(
                      onPressed: _analyzeFaceShape,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA1BC98),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Analyze Face Shape',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (!_analyzing && _result == null)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _picked = null;
                          _result = null;
                        });
                      },
                      child: const Text('Choose Different Photo'),
                    ),
                ],
              ),

            // Loading indicator
            if (_analyzing)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),

            // Results section
            if (_result != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFA1BC98).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.face,
                            color: Color(0xFFA1BC98),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Face Shape',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                _result!.faceShape,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5DCD8).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _result!.jewelryRecommendations['description'] ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Suggested for your face shape section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA1BC98).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFA1BC98).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFFA1BC98),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Suggested for your face shape',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFA1BC98),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'These accessories are personalized for ${_result!.faceShape} faces',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search necklaces or earrings...',
                          prefixIcon: const Icon(Icons.search, color: Color(0xFFA1BC98)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            // Auto-detect category from search
                            if (value.toLowerCase().contains('necklace')) {
                              _selectedCategory = 'necklaces';
                            } else if (value.toLowerCase().contains('earring')) {
                              _selectedCategory = 'earrings';
                            } else if (value.isEmpty) {
                              _selectedCategory = 'all';
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Category tabs
                    Row(
                      children: [
                        _buildCategoryTab('All', 'all'),
                        const SizedBox(width: 8),
                        _buildCategoryTab('Earrings', 'earrings'),
                        const SizedBox(width: 8),
                        _buildCategoryTab('Necklaces', 'necklaces'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Display sections based on selected category
                    if (_selectedCategory == 'all' || _selectedCategory == 'earrings')
                      _buildAccessoriesSection(
                        'Earrings',
                        _result!.jewelryRecommendations['earrings'] ?? [],
                        Icons.earbuds,
                        _selectedCategory == 'all' || _selectedCategory == 'earrings',
                      ),
                    if (_selectedCategory == 'all' && _searchQuery.isEmpty) const SizedBox(height: 24),
                    if (_selectedCategory == 'all' || _selectedCategory == 'necklaces')
                      _buildAccessoriesSection(
                        'Necklaces',
                        _result!.jewelryRecommendations['necklaces'] ?? [],
                        Icons.diamond,
                        _selectedCategory == 'all' || _selectedCategory == 'necklaces',
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String label, String category) {
    final isSelected = _selectedCategory == category;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFA1BC98) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessoriesSection(String title, List<dynamic> items, IconData icon, bool shouldShow) {
    if (!shouldShow) return const SizedBox.shrink();
    
    final uniqueItems = _removeDuplicates(items);
    final filteredItems = _filterItems(uniqueItems, title.toLowerCase());
    
    if (filteredItems.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFA1BC98), size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No items found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFA1BC98), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFA1BC98).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${filteredItems.length}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFA1BC98),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemCount: filteredItems.length,
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final name = item['name'] ?? '';
            final image = item['image'] ?? '';
            final link = item['link'] ?? '';
            
            return GestureDetector(
              onTap: link.isNotEmpty ? () async {
                final uri = Uri.parse(link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } : null,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: image.isNotEmpty
                            ? Image.network(
                                image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (link.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    size: 12,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
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

