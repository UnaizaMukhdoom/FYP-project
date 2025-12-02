// lib/services/closet_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Service for managing closet items (checked items)
class ClosetService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Save a checked item to the closet
  static Future<void> saveItemToCloset({
    required String imagePath,
    required String title,
    required String type,
    required int suitability,
    required int colorScore,
    required int shapeScore,
    required int fitScore,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      // Upload image to Firebase Storage
      final imageUrl = await _uploadImage(imagePath, user.uid);

      // Save item data to Firestore
      await _db.collection('users').doc(user.uid).collection('closet_items').add({
        'title': title,
        'type': type,
        'suitability': suitability,
        'colorScore': colorScore,
        'shapeScore': shapeScore,
        'fitScore': fitScore,
        'imageUrl': imageUrl,
        'imagePath': imagePath, // Local path for quick access
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        if (additionalData != null) ...additionalData,
      });

      print('✅ Item saved to closet: $title');
    } catch (e) {
      print('❌ Error saving item to closet: $e');
      rethrow;
    }
  }

  /// Upload image to Firebase Storage
  static Future<String> _uploadImage(String imagePath, String userId) async {
    try {
      final file = File(imagePath);
      final fileName = 'closet_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('users/$userId/closet/$fileName');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading image: $e');
      // Return empty string if upload fails
      return '';
    }
  }

  /// Get all checked items from closet
  static Stream<List<ClosetItem>> getClosetItems() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('closet_items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ClosetItem(
          id: doc.id,
          title: data['title'] ?? 'Item',
          type: data['type'] ?? 'Item',
          suitability: data['suitability'] ?? 0,
          colorScore: data['colorScore'] ?? 0,
          shapeScore: data['shapeScore'] ?? 0,
          fitScore: data['fitScore'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          imagePath: data['imagePath'] ?? '',
          createdAt: data['createdAt']?.toDate(),
        );
      }).toList();
    });
  }

  /// Get recent checked items (for home screen)
  static Stream<List<ClosetItem>> getRecentCheckedItems({int limit = 3}) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('closet_items')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ClosetItem(
          id: doc.id,
          title: data['title'] ?? 'Item',
          type: data['type'] ?? 'Item',
          suitability: data['suitability'] ?? 0,
          colorScore: data['colorScore'] ?? 0,
          shapeScore: data['shapeScore'] ?? 0,
          fitScore: data['fitScore'] ?? 0,
          imageUrl: data['imageUrl'] ?? '',
          imagePath: data['imagePath'] ?? '',
          createdAt: data['createdAt']?.toDate(),
        );
      }).toList();
    });
  }

  /// Delete item from closet
  static Future<void> deleteItem(String itemId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _db
          .collection('users')
          .doc(user.uid)
          .collection('closet_items')
          .doc(itemId)
          .delete();

      print('✅ Item deleted from closet');
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    }
  }
}

/// Closet Item Model
class ClosetItem {
  final String id;
  final String title;
  final String type;
  final int suitability;
  final int colorScore;
  final int shapeScore;
  final int fitScore;
  final String imageUrl;
  final String imagePath;
  final DateTime? createdAt;

  ClosetItem({
    required this.id,
    required this.title,
    required this.type,
    required this.suitability,
    required this.colorScore,
    required this.shapeScore,
    required this.fitScore,
    required this.imageUrl,
    required this.imagePath,
    this.createdAt,
  });

  String get suitabilityText {
    if (suitability >= 90) return '100% suits you';
    if (suitability >= 70) return '${suitability}% suits you';
    if (suitability >= 50) return '${suitability}% match';
    return 'Low match';
  }
}

