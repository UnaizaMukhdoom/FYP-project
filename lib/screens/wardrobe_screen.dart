// lib/screens/wardrobe_screen.dart
import 'package:flutter/material.dart';
import '../models/wardrobe_item.dart';
import '../models/outfit.dart';
import '../services/wardrobe_service.dart';
import 'add_wardrobe_item_screen.dart';
import 'outfit_planner_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<WardrobeItem> _items = [];
  WardrobeStats? _stats;
  bool _isLoading = true;
  String _selectedCategory = 'all';
  String _selectedUsage = 'all';

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    setState(() => _isLoading = true);
    try {
      final items = await WardrobeService.getWardrobe();
      final stats = await WardrobeService.getStats();
      setState(() {
        _items = items;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wardrobe: $e')),
        );
      }
    }
  }

  List<WardrobeItem> get _filteredItems {
    var filtered = _items;

    if (_selectedCategory != 'all') {
      filtered = filtered.where((item) => item.category == _selectedCategory).toList();
    }

    if (_selectedUsage != 'all') {
      filtered = filtered.where((item) {
        switch (_selectedUsage) {
          case 'most-worn':
            return item.timesWorn >= 3;
          case 'worn':
            return item.timesWorn >= 1 && item.timesWorn <= 2;
          case 'never-worn':
            return item.timesWorn == 0;
          case 'recent':
            if (item.lastWorn == null) return false;
            final lastWornDate = DateTime.parse(item.lastWorn!);
            final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
            return lastWornDate.isAfter(thirtyDaysAgo);
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F0F0F),
          title: const Text(
            'Plan Your Outfit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFFEC4899),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'Wardrobe', icon: Icon(Icons.checkroom)),
              Tab(text: 'Outfits', icon: Icon(Icons.style)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildWardrobeTab(),
            const OutfitPlannerScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddWardrobeItemScreen()),
            );
            if (result == true) {
              _loadWardrobe();
            }
          },
          backgroundColor: const Color(0xFFEC4899),
          icon: const Icon(Icons.add),
          label: const Text('Add Item'),
        ),
      ),
    );
  }

  Widget _buildWardrobeTab() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFEC4899)),
      );
    }

    return Column(
      children: [
        // Stats Section
        if (_stats != null) _buildStatsSection(),
        
        // Filters
        _buildFilters(),
        
        // Items Grid
        Expanded(
          child: _filteredItems.isEmpty
              ? _buildEmptyState()
              : _buildItemsGrid(),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatCard(
            number: '${_stats!.totalItems}',
            label: 'Total Items',
          ),
          _StatCard(
            number: _stats!.mostWorn != null
                ? '${_stats!.mostWorn!.timesWorn}x'
                : '-',
            label: 'Most Worn',
          ),
          _StatCard(
            number: '${_stats!.neverWorn.length}',
            label: 'Never Worn',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Categories')),
                DropdownMenuItem(value: 'top', child: Text('Tops')),
                DropdownMenuItem(value: 'pants', child: Text('Bottoms')),
                DropdownMenuItem(value: 'dress', child: Text('Dresses')),
                DropdownMenuItem(value: 'shoes', child: Text('Shoes')),
                DropdownMenuItem(value: 'accessory', child: Text('Accessories')),
              ],
              onChanged: (value) {
                setState(() => _selectedCategory = value ?? 'all');
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: _selectedUsage,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Items')),
                DropdownMenuItem(value: 'most-worn', child: Text('Most Worn')),
                DropdownMenuItem(value: 'worn', child: Text('Worn')),
                DropdownMenuItem(value: 'never-worn', child: Text('Never Worn')),
                DropdownMenuItem(value: 'recent', child: Text('Recent')),
              ],
              onChanged: (value) {
                setState(() => _selectedUsage = value ?? 'all');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredItems.length,
      itemBuilder: (context, index) {
        final item = _filteredItems[index];
        return _WardrobeItemCard(
          item: item,
          onTap: () => _showItemDetails(item),
          onDelete: () => _deleteItem(item),
          onMarkWorn: () => _markAsWorn(item),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, size: 80, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            'Your wardrobe is empty',
            style: TextStyle(color: Colors.white70, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddWardrobeItemScreen()),
              );
              if (result == true) {
                _loadWardrobe();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEC4899),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(WardrobeItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await WardrobeService.deleteItem(item.id);
        _loadWardrobe();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting item: $e')),
          );
        }
      }
    }
  }

  Future<void> _markAsWorn(WardrobeItem item) async {
    try {
      await WardrobeService.markAsWorn(item.id);
      _loadWardrobe();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marked as worn!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showItemDetails(WardrobeItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ItemDetailsSheet(
        item: item,
        onMarkWorn: () {
          Navigator.pop(context);
          _markAsWorn(item);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteItem(item);
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _WardrobeItemCard extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkWorn;

  const _WardrobeItemCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.onMarkWorn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: _buildItemImage(item.filepath),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getColorFromName(item.color),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.color,
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      Text(
                        'Worn ${item.timesWorn}x',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorFromName(String colorName) {
    final colors = {
      'black': Colors.black,
      'white': Colors.white,
      'gray': Colors.grey,
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'purple': Colors.purple,
      'orange': Colors.orange,
    };
    return colors[colorName.toLowerCase()] ?? Colors.grey;
  }

  static Widget _buildItemImage(String filepath) {
    // Build the full URL for the image
    String imageUrl;
    if (filepath.contains('http')) {
      // Already a full URL (for production)
      imageUrl = filepath;
    } else if (filepath.startsWith('/')) {
      // Relative path - add base URL from WardrobeService
      imageUrl = '${WardrobeService.baseUrl}$filepath';
    } else {
      // No valid path - show placeholder
      return const Icon(Icons.checkroom, size: 60, color: Colors.grey);
    }

    return Image.network(
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
        return const Icon(Icons.checkroom, size: 60, color: Colors.grey);
      },
    );
  }
}

class _ItemDetailsSheet extends StatelessWidget {
  final WardrobeItem item;
  final VoidCallback onMarkWorn;
  final VoidCallback onDelete;

  const _ItemDetailsSheet({
    required this.item,
    required this.onMarkWorn,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _WardrobeItemCard._buildItemImage(item.filepath),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Details
                  _DetailRow(label: 'Category', value: item.category),
                  _DetailRow(label: 'Color', value: item.color),
                  _DetailRow(label: 'Season', value: item.season),
                  _DetailRow(label: 'Occasion', value: item.occasion),
                  if (item.brand != null) _DetailRow(label: 'Brand', value: item.brand!),
                  _DetailRow(label: 'Price', value: 'Rs. ${item.price}'),
                  _DetailRow(label: 'Times Worn', value: '${item.timesWorn}x'),
                  if (item.lastWorn != null)
                    _DetailRow(
                      label: 'Last Worn',
                      value: DateTime.parse(item.lastWorn!).toString().split(' ')[0],
                    ),
                  const SizedBox(height: 24),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onMarkWorn,
                          icon: const Icon(Icons.check),
                          label: const Text('Mark as Worn'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

