// lib/services/chatbot_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatbotService {
  // Local testing - use your computer's IP address for phone testing
  // For web/emulator: use 'http://localhost:5000'
  // For phone: use 'http://YOUR_IP:5000' (e.g., 'http://172.20.2.61:5000')
  static const String baseUrl = 'http://172.20.2.61:5000'; // Local development
  // Production: 'https://amiable-encouragement-production.up.railway.app';
  
  /// Get chatbot response
  Future<String> getResponse(String userMessage, {String? context}) async {
    try {
      // Match Chatbot_VogueAI Flask endpoint: POST /api/chat
      final uri = Uri.parse('$baseUrl/api/chat');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'message': userMessage,
          // The Flask app currently ignores extra fields, but we can pass context if needed
          'context': context ?? 'fashion_styling',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('[ChatbotService] Response data: $data'); // Debug log
        
        // Chatbot_VogueAI returns:
        // { success: true, response: { message: '...', ... } }
        if (data['success'] == true && data['response'] != null) {
          final resp = data['response'];
          if (resp is Map<String, dynamic> && resp['message'] != null) {
            final message = resp['message'] as String;
            print('[ChatbotService] Extracted message: $message'); // Debug log
            return message;
          }
          // Fallback: if response is a string directly
          if (data['response'] is String) {
            return data['response'] as String;
          }
          return data['response'].toString();
        } else {
          print('[ChatbotService] Error in response: ${data['error']}');
          throw Exception(data['error'] ?? 'Unknown error');
        }
      } else {
        print('[ChatbotService] HTTP error: ${response.statusCode}, body: ${response.body}');
        throw Exception('API error: ${response.statusCode}');
      }
    } catch (e) {
      print('[ChatbotService] Exception: $e');
      throw Exception('Failed to get chatbot response: $e');
    }
  }
  
  /// Check if chatbot service is available
  Future<bool> checkHealth() async {
    try {
      // Use system-info endpoint from Chatbot_VogueAI: GET /api/system-info
      final uri = Uri.parse('$baseUrl/api/system-info');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        // If the endpoint responds 200, consider the service healthy
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

