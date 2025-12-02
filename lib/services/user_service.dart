// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for syncing user data with admin panel
class UserService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create or update user profile in top-level users collection
  /// This allows admin panel to see all users
  static Future<void> syncUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('⚠️ No user logged in, cannot sync profile');
        return;
      }

      print('🔄 Syncing user profile to admin panel...');
      print('   User ID: ${user.uid}');
      print('   Email: ${user.email}');

      // Prepare user data
      final userData = {
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'platform': 'mobile',
        'provider': user.providerData.isNotEmpty 
            ? user.providerData.first.providerId 
            : 'email',
      };

      print('   Writing data: $userData');

      // Use set() without merge first to ensure document is created with fields
      // If document already exists (from subcollection), this will add the fields
      final docRef = _db.collection('users').doc(user.uid);
      
      // Try to get existing document first
      final existingDoc = await docRef.get();
      
      if (existingDoc.exists && existingDoc.data() != null && existingDoc.data()!.isNotEmpty) {
        // Document exists with data, use merge to update
        print('   Document exists, updating with merge...');
        await docRef.set(userData, SetOptions(merge: true));
      } else {
        // Document doesn't exist or is empty, create it
        print('   Document empty or missing, creating new...');
        await docRef.set(userData);
      }

      // Verify the write worked
      final verifyDoc = await docRef.get();
      if (verifyDoc.exists && verifyDoc.data() != null && verifyDoc.data()!.isNotEmpty) {
        print('✅ User profile synced to admin panel successfully!');
        print('   Document verified with ${verifyDoc.data()!.length} fields');
        print('   Fields: ${verifyDoc.data()!.keys.join(", ")}');
      } else {
        print('⚠️ Warning: Document write completed but verification failed');
        print('   Document exists: ${verifyDoc.exists}');
        print('   Has data: ${verifyDoc.data() != null}');
      }
      
      print('   Check Firebase Console → Firestore → users collection');
    } catch (e, stackTrace) {
      print('❌ Error syncing user profile: $e');
      print('   Stack trace: $stackTrace');
      // Re-throw so calling code can handle it
      rethrow;
    }
  }

  /// Update last login timestamp
  static Future<void> updateLastLogin() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _db.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Error updating last login: $e');
    }
  }

  /// Get user profile from top-level collection
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('❌ Error getting user profile: $e');
      return null;
    }
  }
}

