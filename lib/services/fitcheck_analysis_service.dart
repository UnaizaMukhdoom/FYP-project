// lib/services/fitcheck_analysis_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Service for FitCheck outfit analysis
class FitCheckAnalysisService {
  // API Configuration
  // For local development: Use your computer's IP address (e.g., 'http://172.20.2.61:5000')
  // For Android Emulator: Use 'http://10.0.2.2:5000'
  // For production: Use the deployed Railway URL
  // static const String baseUrl = 'https://amiable-encouragement-production.up.railway.app';
  
  // Local testing (using your computer's IP):
  static const String baseUrl = 'http://172.20.2.61:5000'; // Physical device
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android Emulator
  
  /// Analyze outfit image and get comprehensive feedback
  /// This analyzes the ACTUAL image uploaded by the user and provides
  /// personalized ratings and recommendations based on the image content
  static Future<FitCheckResult> analyzeOutfit(String imagePath) async {
    try {
      print('📸 Analyzing outfit image: $imagePath');
      
      final uri = Uri.parse('$baseUrl/analyze-outfit');
      final request = http.MultipartRequest('POST', uri);
      
      // Add image file - this is the actual photo the user uploaded
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      print('📤 Sending image to API for analysis...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        
        if (jsonData['success'] == true) {
          print('✅ Analysis complete! Fit Grade: ${jsonData['fit_grade']}');
          print('📊 Scores - Coherence: ${jsonData['coherence']}, Color Match: ${jsonData['color_match']}');
          return FitCheckResult.fromJson(jsonData);
        } else {
          throw Exception(jsonData['error'] ?? 'Analysis failed');
        }
      } else if (response.statusCode == 404) {
        print('❌ Endpoint not found (404). The /analyze-outfit endpoint may not be deployed yet.');
        print('💡 Solution: Run the API locally or deploy the updated API with /analyze-outfit endpoint.');
        throw Exception(
          'API endpoint not found. Please run the Flask API server locally:\n\n'
          '1. Open terminal in the "api" folder\n'
          '2. Run: python app.py\n'
          '3. Update baseUrl in this file to: http://10.0.2.2:5000 (for emulator)\n'
          '   or http://YOUR_IP:5000 (for physical device)'
        );
      } else {
        print('❌ Server error: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Server error ${response.statusCode}: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}');
      }
    } catch (e) {
      print('❌ Error analyzing outfit: $e');
      // Check if it's a network/connection error
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Failed host lookup') ||
          e.toString().contains('Network is unreachable')) {
        throw Exception(
          'Cannot connect to API server.\n\n'
          'Please make sure:\n'
          '1. The Flask API is running (python app.py in the "api" folder)\n'
          '2. You\'re using the correct API URL\n'
          '3. Your device and computer are on the same network'
        );
      }
      rethrow;
    }
  }
}

/// FitCheck Analysis Result Model
class FitCheckResult {
  final bool success;
  final int coherence;
  final int colorMatch;
  final int trendiness;
  final int flattering;
  final int proportion;
  final int versatility;
  final String fitGrade;
  final String colorSeason;
  final String summary;
  final String colorMatchText;
  final String occasion;
  final String doneWell;
  final String recommendation;
  final Map<String, dynamic>? detectedItems;

  FitCheckResult({
    required this.success,
    required this.coherence,
    required this.colorMatch,
    required this.trendiness,
    required this.flattering,
    required this.proportion,
    required this.versatility,
    required this.fitGrade,
    required this.colorSeason,
    required this.summary,
    required this.colorMatchText,
    required this.occasion,
    required this.doneWell,
    required this.recommendation,
    this.detectedItems,
  });

  factory FitCheckResult.fromJson(Map<String, dynamic> json) {
    return FitCheckResult(
      success: json['success'] ?? false,
      coherence: json['coherence'] ?? 0,
      colorMatch: json['color_match'] ?? 0,
      trendiness: json['trendiness'] ?? 0,
      flattering: json['flattering'] ?? 0,
      proportion: json['proportion'] ?? 0,
      versatility: json['versatility'] ?? 0,
      fitGrade: json['fit_grade'] ?? 'B',
      colorSeason: json['color_season'] ?? 'Soft Autumn',
      summary: json['summary'] ?? '',
      colorMatchText: json['color_match_text'] ?? json['colorMatchText'] ?? '',
      occasion: json['occasion'] ?? '',
      doneWell: json['done_well'] ?? json['doneWell'] ?? '',
      recommendation: json['recommendation'] ?? '',
      detectedItems: json['detected_items'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coherence': coherence,
      'color_match': colorMatch,
      'trendiness': trendiness,
      'flattering': flattering,
      'proportion': proportion,
      'versatility': versatility,
      'fit_grade': fitGrade,
      'color_season': colorSeason,
      'summary': summary,
      'color_match_text': colorMatchText,
      'occasion': occasion,
      'done_well': doneWell,
      'recommendation': recommendation,
    };
  }
}

