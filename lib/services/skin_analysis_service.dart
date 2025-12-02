// lib/services/skin_analysis_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for calling the Skin Tone Analysis API
class SkinAnalysisService {
  // Production API - Deployed on Railway
  // Production URL: https://amiable-encouragement-production.up.railway.app
  // For local development, use: 'http://localhost:5000' or your computer's IP
  // static const String baseUrl = 'https://amiable-encouragement-production.up.railway.app';
  static const String baseUrl = 'http://172.20.2.61:5000'; // Local development
  
  /// Analyze an image and get skin tone, hair, eye color analysis
  static Future<AnalysisResult> analyzeImage(String imagePath) async {
    try {
      final uri = Uri.parse('$baseUrl/analyze');
      final request = http.MultipartRequest('POST', uri);
      
      // Add image file
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        if (jsonData['success'] == true) {
          return AnalysisResult.fromJson(jsonData);
        } else {
          throw Exception(jsonData['error'] ?? 'Analysis failed');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to analyze image: $e');
    }
  }
  
  /// Check if API is reachable
  static Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Scrape clothes based on skin tone analysis
  /// Returns a list of clothing items from various brands
  static Future<Map<String, dynamic>> scrapeClothes({
    required String skinTone,
    required List<String> bestColors,
    required String undertone,
    int maxItems = 20,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/scrape-clothes');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'skin_tone': skinTone,
          'best_colors': bestColors,
          'undertone': undertone,
          'max_items': maxItems,
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to scrape clothes: $e');
    }
  }
}

/// Model for analysis results
class AnalysisResult {
  final bool success;
  final SkinTone skinTone;
  final String hairColor;
  final String eyeColor;
  final ColorRecommendations colorRecommendations;
  
  AnalysisResult({
    required this.success,
    required this.skinTone,
    required this.hairColor,
    required this.eyeColor,
    required this.colorRecommendations,
  });
  
  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      success: json['success'] ?? false,
      skinTone: SkinTone.fromJson(json['skin_tone'] ?? {}),
      hairColor: json['hair_color'] ?? 'Not detected',
      eyeColor: json['eye_color'] ?? 'Not detected',
      colorRecommendations: ColorRecommendations.fromJson(json['color_recommendations'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'skin_tone': {
        'category': skinTone.category,
        'fitzpatrick_type': skinTone.fitzpatrickType,
        'rgb': skinTone.rgb,
        'hex': skinTone.hex,
        'brightness': skinTone.brightness,
        'undertone': skinTone.undertone,
      },
      'hair_color': hairColor,
      'eye_color': eyeColor,
      'color_recommendations': {
        'best_colors': colorRecommendations.bestColors,
        'avoid_colors': colorRecommendations.avoidColors,
        'neutrals': colorRecommendations.neutrals,
        'description': colorRecommendations.description,
      },
    };
  }
}

/// Skin tone details
class SkinTone {
  final String category;
  final String fitzpatrickType;
  final Map<String, int> rgb;
  final String hex;
  final double brightness;
  final String undertone;
  
  SkinTone({
    required this.category,
    required this.fitzpatrickType,
    required this.rgb,
    required this.hex,
    required this.brightness,
    required this.undertone,
  });
  
  factory SkinTone.fromJson(Map<String, dynamic> json) {
    final rgbData = json['rgb'] as Map<String, dynamic>? ?? {};
    return SkinTone(
      category: json['category'] ?? 'Medium',
      fitzpatrickType: json['fitzpatrick_type'] ?? 'Type IV',
      rgb: {
        'r': rgbData['r'] ?? 120,
        'g': rgbData['g'] ?? 120,
        'b': rgbData['b'] ?? 120,
      },
      hex: json['hex'] ?? '#787878',
      brightness: (json['brightness'] ?? 120.0).toDouble(),
      undertone: json['undertone'] ?? 'Neutral',
    );
  }
}

/// Color recommendations
class ColorRecommendations {
  final List<String> bestColors;
  final List<String> avoidColors;
  final List<String> neutrals;
  final String description;
  
  ColorRecommendations({
    required this.bestColors,
    required this.avoidColors,
    required this.neutrals,
    required this.description,
  });
  
  factory ColorRecommendations.fromJson(Map<String, dynamic> json) {
    return ColorRecommendations(
      bestColors: (json['best_colors'] as List?)?.cast<String>() ?? [],
      avoidColors: (json['avoid_colors'] as List?)?.cast<String>() ?? [],
      neutrals: (json['neutrals'] as List?)?.cast<String>() ?? [],
      description: json['description'] ?? '',
    );
  }
}

