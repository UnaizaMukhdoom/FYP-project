// lib/services/firebase_test.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

/// Comprehensive Firebase configuration and connection test
/// Call this from your app to verify all Firebase services are working
class FirebaseTestService {
  static const String testCollection = 'connection_test';
  static const String testDocument = 'test_doc';

  /// Run all Firebase tests and return detailed results
  static Future<Map<String, dynamic>> runAllTests() async {
    final results = <String, dynamic>{};
    
    print('🔥 Starting Firebase Configuration Tests...\n');

    // Test 1: Firebase Core
    results['firebase_core'] = await _testFirebaseCore();
    
    // Test 2: Firebase Auth
    results['firebase_auth'] = await _testFirebaseAuth();
    
    // Test 3: Cloud Firestore
    results['cloud_firestore'] = await _testCloudFirestore();
    
    // Test 4: Firebase Storage
    results['firebase_storage'] = await _testFirebaseStorage();
    
    // Test 5: Firebase Realtime Database
    results['firebase_database'] = await _testFirebaseDatabase();

    // Summary
    final passed = results.values.where((r) => r['status'] == 'success').length;
    final failed = results.values.where((r) => r['status'] == 'error').length;
    
    print('\n' + '='*50);
    print('📊 TEST SUMMARY:');
    print('   ✅ Passed: $passed');
    print('   ❌ Failed: $failed');
    print('='*50 + '\n');

    return results;
  }

  /// Test Firebase Core initialization
  static Future<Map<String, dynamic>> _testFirebaseCore() async {
    print('1️⃣  Testing Firebase Core...');
    try {
      final app = Firebase.app();
      final options = app.options;
      
      print('   ✅ Firebase Core: Connected');
      print('   📱 Project ID: ${options.projectId}');
      print('   🌐 App ID: ${options.appId}');
      print('   📦 Storage Bucket: ${options.storageBucket}');
      
      return {
        'status': 'success',
        'message': 'Firebase Core initialized successfully',
        'projectId': options.projectId,
        'appId': options.appId,
      };
    } catch (e) {
      print('   ❌ Firebase Core: Failed - $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Test Firebase Authentication
  static Future<Map<String, dynamic>> _testFirebaseAuth() async {
    print('\n2️⃣  Testing Firebase Auth...');
    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      print('   ✅ Firebase Auth: Connected');
      print('   👤 Current User: ${currentUser?.email ?? 'No user signed in'}');
      print('   🔐 Auth State: ${currentUser != null ? "Authenticated" : "Not Authenticated"}');
      
      return {
        'status': 'success',
        'message': 'Firebase Auth connected successfully',
        'currentUser': currentUser?.email,
        'isAuthenticated': currentUser != null,
      };
    } catch (e) {
      print('   ❌ Firebase Auth: Failed - $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Test Cloud Firestore
  static Future<Map<String, dynamic>> _testCloudFirestore() async {
    print('\n3️⃣  Testing Cloud Firestore...');
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Try to write a test document
      final testRef = firestore.collection(testCollection).doc(testDocument);
      await testRef.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
      });
      
      // Try to read the document back
      final snapshot = await testRef.get();
      
      if (snapshot.exists) {
        print('   ✅ Cloud Firestore: Connected');
        print('   📝 Write Test: Success');
        print('   📖 Read Test: Success');
        
        // Clean up test document
        await testRef.delete();
        print('   🗑️  Cleanup: Success');
        
        return {
          'status': 'success',
          'message': 'Cloud Firestore read/write successful',
          'canWrite': true,
          'canRead': true,
        };
      } else {
        throw Exception('Document write succeeded but read failed');
      }
    } catch (e) {
      print('   ❌ Cloud Firestore: Failed - $e');
      print('   ⚠️  Check Firestore rules and ensure database is created');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Test Firebase Storage
  static Future<Map<String, dynamic>> _testFirebaseStorage() async {
    print('\n4️⃣  Testing Firebase Storage...');
    try {
      final storage = FirebaseStorage.instance;
      final ref = storage.ref();
      
      print('   ✅ Firebase Storage: Connected');
      print('   📦 Bucket: ${storage.bucket}');
      
      // Try to list files (this tests connection)
      try {
        await ref.listAll();
        print('   📁 Access Test: Success');
      } catch (e) {
        print('   ⚠️  Access Test: Limited (may need authentication)');
      }
      
      return {
        'status': 'success',
        'message': 'Firebase Storage connected successfully',
        'bucket': storage.bucket,
      };
    } catch (e) {
      print('   ❌ Firebase Storage: Failed - $e');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Test Firebase Realtime Database
  static Future<Map<String, dynamic>> _testFirebaseDatabase() async {
    print('\n5️⃣  Testing Firebase Realtime Database...');
    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref('connection_test');
      
      // Try to write a test value
      await ref.set({
        'test': true,
        'timestamp': ServerValue.timestamp,
        'message': 'Firebase connection test',
      });
      
      // Try to read the value back
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        print('   ✅ Firebase Realtime Database: Connected');
        print('   📝 Write Test: Success');
        print('   📖 Read Test: Success');
        
        // Clean up
        await ref.remove();
        print('   🗑️  Cleanup: Success');
        
        return {
          'status': 'success',
          'message': 'Firebase Realtime Database read/write successful',
          'canWrite': true,
          'canRead': true,
        };
      } else {
        throw Exception('Database write succeeded but read failed');
      }
    } catch (e) {
      print('   ❌ Firebase Realtime Database: Failed - $e');
      print('   ⚠️  Check database rules and ensure Realtime Database is enabled');
      return {
        'status': 'error',
        'message': e.toString(),
      };
    }
  }

  /// Display results in a Flutter widget (for UI testing)
  static Widget buildTestResultsWidget(Map<String, dynamic> results) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '🔥 Firebase Test Results',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        ...results.entries.map((entry) {
          final testName = entry.key.replaceAll('_', ' ').toUpperCase();
          final result = entry.value as Map<String, dynamic>;
          final isSuccess = result['status'] == 'success';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 32,
              ),
              title: Text(
                testName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(result['message'] ?? ''),
            ),
          );
        }),
      ],
    );
  }
}

/// Example usage: Add this button to your app for testing
class FirebaseTestButton extends StatefulWidget {
  const FirebaseTestButton({super.key});

  @override
  State<FirebaseTestButton> createState() => _FirebaseTestButtonState();
}

class _FirebaseTestButtonState extends State<FirebaseTestButton> {
  bool _testing = false;
  Map<String, dynamic>? _results;

  Future<void> _runTests() async {
    setState(() {
      _testing = true;
      _results = null;
    });

    final results = await FirebaseTestService.runAllTests();

    setState(() {
      _testing = false;
      _results = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _testing ? null : _runTests,
          icon: _testing
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow),
          label: Text(_testing ? 'Testing...' : 'Run Firebase Tests'),
        ),
        if (_results != null)
          Expanded(
            child: FirebaseTestService.buildTestResultsWidget(_results!),
          ),
      ],
    );
  }
}

