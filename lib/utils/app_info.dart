// lib/utils/app_info.dart
import 'package:package_info_plus/package_info_plus.dart';

/// Utility class for getting app information
class AppInfo {
  static PackageInfo? _packageInfo;
  
  /// Initialize app info (call in main or app startup)
  static Future<void> initialize() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }
  
  /// Get app version (e.g., "1.0.0")
  static String get version => _packageInfo?.version ?? '1.0.0';
  
  /// Get build number (e.g., "1")
  static String get buildNumber => _packageInfo?.buildNumber ?? '1';
  
  /// Get full version string (e.g., "1.0.0 (1)")
  static String get fullVersion => '$version ($buildNumber)';
  
  /// Get app name
  static String get appName => _packageInfo?.appName ?? 'VOGUE AI';
  
  /// Get package name
  static String get packageName => _packageInfo?.packageName ?? 'com.example.fyp';
}

