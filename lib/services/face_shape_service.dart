// lib/services/face_shape_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class FaceShapeResult {
  final String faceShape;
  final double confidence;
  final Map<String, dynamic> jewelryRecommendations;

  FaceShapeResult({
    required this.faceShape,
    required this.confidence,
    required this.jewelryRecommendations,
  });

  factory FaceShapeResult.fromJson(Map<String, dynamic> json) {
    return FaceShapeResult(
      faceShape: json['face_shape'] ?? 'Oval',
      confidence: (json['confidence'] ?? 0.85).toDouble(),
      jewelryRecommendations: json['jewelry_recommendations'] ?? {},
    );
  }
}

class FaceShapeService {
  // Production API - Deployed on Railway
  // For local testing, use: 'http://172.20.2.61:5000' or 'http://localhost:5000'
  static const String baseUrl = 'http://172.20.2.61:5000'; // Change to Railway URL for production
  
  /// Analyze face shape and get jewelry recommendations
  static Future<FaceShapeResult> analyzeFaceShape(String imagePath) async {
    try {
      final uri = Uri.parse('$baseUrl/analyze-face-shape');
      final request = http.MultipartRequest('POST', uri);
      
      // Add image file
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      // Check if response is JSON
      final contentType = response.headers['content-type'] ?? '';
      final isJson = contentType.contains('application/json') || 
                     (response.body.trim().startsWith('{') || response.body.trim().startsWith('['));
      
      if (response.statusCode == 200) {
        if (!isJson) {
          throw Exception('Server returned non-JSON response. Please check if MediaPipe is installed on the server.');
        }
        
        try {
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          
          if (jsonData['success'] == true) {
            return FaceShapeResult.fromJson(jsonData);
          } else {
            throw Exception(jsonData['error'] ?? 'Analysis failed');
          }
        } catch (e) {
          if (e is FormatException) {
            throw Exception('Invalid JSON response from server. Response: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
          }
          rethrow;
        }
      } else {
        // Handle error responses
        String errorMessage = 'Server error: ${response.statusCode}';
        
        if (isJson) {
          try {
            final errorData = json.decode(response.body) as Map<String, dynamic>;
            errorMessage = errorData['error'] ?? errorMessage;
          } catch (e) {
            // If JSON parsing fails, use the raw response (truncated)
            errorMessage = 'Server error ${response.statusCode}: ${response.body.substring(0, response.body.length > 100 ? 100 : response.body.length)}';
          }
        } else {
          // Non-JSON error response (likely HTML error page)
          errorMessage = 'Server error ${response.statusCode}. The face shape analysis endpoint may not be available. Please ensure MediaPipe is installed on the server.';
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is FormatException) {
        throw Exception('Failed to parse server response. The API may be returning an error page. Please check server configuration.');
      }
      throw Exception('Failed to analyze face shape: ${e.toString()}');
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
}

