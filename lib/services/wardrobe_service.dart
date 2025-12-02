// lib/services/wardrobe_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../models/wardrobe_item.dart';
import '../models/outfit.dart';

/// Service for Wardrobe and Outfit API calls
class WardrobeService {
  // Local testing - use your computer's IP for physical device
  // For Android emulator: use 'http://10.0.2.2:5000'
  // For physical device: use your computer's IP (e.g., 'http://172.20.2.27:5000')
  // For web/Chrome: use 'http://localhost:5000'
  // For production: use 'https://amiable-encouragement-production.up.railway.app'
  static const String baseUrl = 'http://172.20.2.61:5000'; // Physical device - USE THIS FOR TESTING
  // static const String baseUrl = 'http://localhost:5000'; // Web/Chrome only
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  // static const String baseUrl = 'https://amiable-encouragement-production.up.railway.app'; // Production

  /// Get all wardrobe items
  static Future<List<WardrobeItem>> getWardrobe() async {
    try {
      final uri = Uri.parse('$baseUrl/api/wardrobe');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = (data['items'] as List? ?? [])
            .map((item) => WardrobeItem.fromJson(item as Map<String, dynamic>))
            .toList();
        return items;
      } else {
        throw Exception('Failed to load wardrobe: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading wardrobe: $e');
    }
  }

  /// Upload a new wardrobe item
  static Future<WardrobeItem> uploadItem({
    required File imageFile,
    required String category,
    required String color,
    String season = 'all-season',
    String occasion = 'casual',
    String? brand,
    String? purchaseDate,
    int price = 0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload-item');
      final request = http.MultipartRequest('POST', uri);

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      // Add form fields
      request.fields['category'] = category;
      request.fields['color'] = color;
      request.fields['season'] = season;
      request.fields['occasion'] = occasion;
      if (brand != null && brand.isNotEmpty) {
        request.fields['brand'] = brand;
      }
      if (purchaseDate != null) {
        request.fields['purchase_date'] = purchaseDate;
      }
      request.fields['price'] = price.toString();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return WardrobeItem.fromJson(data['item'] as Map<String, dynamic>);
        } else {
          throw Exception(data['error'] ?? 'Upload failed');
        }
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading item: $e');
    }
  }

  /// Delete a wardrobe item
  static Future<void> deleteItem(String itemId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/wardrobe/$itemId');
      final response = await http.delete(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Delete failed');
      }
    } catch (e) {
      throw Exception('Error deleting item: $e');
    }
  }

  /// Mark item as worn
  static Future<void> markAsWorn(String itemId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/wardrobe/$itemId/worn');
      final response = await http.post(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Failed to mark as worn');
      }
    } catch (e) {
      throw Exception('Error marking item as worn: $e');
    }
  }

  /// Get wardrobe statistics
  static Future<WardrobeStats> getStats() async {
    try {
      final uri = Uri.parse('$baseUrl/api/wardrobe-stats');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final items = await getWardrobe();
        return WardrobeStats.fromJson(data, items);
      } else {
        throw Exception('Failed to load stats');
      }
    } catch (e) {
      throw Exception('Error loading stats: $e');
    }
  }

  /// Get outfit of the day
  static Future<Outfit> getOutfitOfTheDay({
    String occasion = 'any',
    String weather = 'mild',
    String colorPreference = 'any',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/outfit-of-the-day');
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['outfit'] != null) {
          final items = await getWardrobe();
          return Outfit.fromJson(
            data['outfit'] as Map<String, dynamic>,
            items,
          );
        } else {
          throw Exception(data['error'] ?? 'Failed to generate outfit');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to get outfit');
      }
    } catch (e) {
      throw Exception('Error getting outfit: $e');
    }
  }

  /// Generate multiple outfit suggestions
  static Future<List<Outfit>> generateOutfits() async {
    try {
      final uri = Uri.parse('$baseUrl/api/generate-outfits');
      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['outfits'] != null) {
          final items = await getWardrobe();
          return (data['outfits'] as List)
              .map((outfitJson) => Outfit.fromJson(
                    outfitJson as Map<String, dynamic>,
                    items,
                  ))
              .toList();
        } else {
          throw Exception(data['error'] ?? 'Failed to generate outfits');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(data['error'] ?? 'Failed to generate outfits');
      }
    } catch (e) {
      throw Exception('Error generating outfits: $e');
    }
  }
}

