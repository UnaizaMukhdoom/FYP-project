// lib/utils/offline_detector.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Utility class for detecting network connectivity
class OfflineDetector {
  static final Connectivity _connectivity = Connectivity();
  
  /// Check if device is currently online
  static Future<bool> isOnline() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
  
  /// Stream of connectivity changes
  static Stream<ConnectivityResult> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }
  
  /// Show offline banner if not connected
  static Widget buildOfflineBanner(BuildContext context, bool isOnline) {
    if (isOnline) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.red[700],
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No internet connection',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

