// lib/utils/image_compressor.dart
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Utility class for compressing images before upload
class ImageCompressor {
  /// Compress image to reduce file size
  /// Returns path to compressed image
  static Future<String?> compressImage(String imagePath, {int quality = 85}) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }
      
      // Get file size
      final originalSize = await file.length();
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basename(imagePath);
      final targetPath = path.join(tempDir.path, 'compressed_$fileName');
      
      // Compress image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: quality,
        minWidth: 1024,
        minHeight: 1024,
      );
      
      if (compressedFile == null) {
        return imagePath; // Return original if compression fails
      }
      
      final compressedSize = await compressedFile.length();
      print('Image compressed: ${(originalSize / 1024).toStringAsFixed(2)}KB -> ${(compressedSize / 1024).toStringAsFixed(2)}KB');
      
      return compressedFile.path;
    } catch (e) {
      print('Error compressing image: $e');
      return imagePath; // Return original if compression fails
    }
  }
  
  /// Compress image with custom quality (0-100)
  static Future<String?> compressImageWithQuality(String imagePath, int quality) async {
    return compressImage(imagePath, quality: quality);
  }
}

