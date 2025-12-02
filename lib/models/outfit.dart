// lib/models/outfit.dart
import 'wardrobe_item.dart';

class Outfit {
  final String id;
  final String? name;
  final String? icon;
  final List<WardrobeItem> items;
  final String reason;
  final String type;
  final String? date;
  final String? savedDate;

  Outfit({
    required this.id,
    this.name,
    this.icon,
    required this.items,
    required this.reason,
    required this.type,
    this.date,
    this.savedDate,
  });

  factory Outfit.fromJson(Map<String, dynamic> json, List<WardrobeItem> allItems) {
    final itemsList = <WardrobeItem>[];
    
    for (var itemJson in (json['items'] as List? ?? [])) {
      if (itemJson is Map<String, dynamic>) {
        // Try to find in allItems by id first
        final itemId = itemJson['id']?.toString() ?? '';
        if (itemId.isNotEmpty) {
          try {
            final foundItem = allItems.firstWhere((item) => item.id == itemId);
            itemsList.add(foundItem);
            continue;
          } catch (e) {
            // Not found in allItems, use the json data directly
          }
        }
        // Create from json directly
        itemsList.add(WardrobeItem.fromJson(itemJson));
      }
    }

    return Outfit(
      id: json['id'] ?? '',
      name: json['name'],
      icon: json['icon'],
      items: itemsList,
      reason: json['reason'] ?? 'Great combination from your wardrobe!',
      type: json['type'] ?? 'separates',
      date: json['date'],
      savedDate: json['saved_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'items': items.map((item) => item.toJson()).toList(),
      'reason': reason,
      'type': type,
      'date': date,
      'saved_date': savedDate,
    };
  }
}

class WardrobeStats {
  final int totalItems;
  final double totalValue;
  final WardrobeItem? mostWorn;
  final List<WardrobeItem> neverWorn;
  final Map<String, int> categoryBreakdown;
  final Map<String, int> colorBreakdown;

  WardrobeStats({
    required this.totalItems,
    required this.totalValue,
    this.mostWorn,
    required this.neverWorn,
    required this.categoryBreakdown,
    required this.colorBreakdown,
  });

  factory WardrobeStats.fromJson(Map<String, dynamic> json, List<WardrobeItem> allItems) {
    return WardrobeStats(
      totalItems: json['total_items'] ?? 0,
      totalValue: (json['total_value'] ?? 0).toDouble(),
      mostWorn: json['most_worn'] != null
          ? WardrobeItem.fromJson(json['most_worn'] as Map<String, dynamic>)
          : null,
      neverWorn: (json['least_worn'] as List? ?? [])
          .map((itemJson) => WardrobeItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      categoryBreakdown: Map<String, int>.from(json['category_breakdown'] ?? {}),
      colorBreakdown: Map<String, int>.from(json['color_breakdown'] ?? {}),
    );
  }
}

