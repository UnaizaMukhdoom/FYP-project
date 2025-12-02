// lib/screens/test_sync_screen.dart
// Test screen to verify Firebase sync is working
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/user_service.dart';

class TestSyncScreen extends StatefulWidget {
  const TestSyncScreen({super.key});

  @override
  State<TestSyncScreen> createState() => _TestSyncScreenState();
}

class _TestSyncScreenState extends State<TestSyncScreen> {
  String _status = 'Ready to test...';
  bool _testing = false;
  Map<String, dynamic>? _userData;

  Future<void> _testSync() async {
    setState(() {
      _testing = true;
      _status = 'Testing sync...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _status = '❌ No user logged in';
          _testing = false;
        });
        return;
      }

      _status += '\n\nUser Info:';
      _status += '\n- Email: ${user.email}';
      _status += '\n- UID: ${user.uid}';
      _status += '\n- Display Name: ${user.displayName ?? 'N/A'}';

      // Test 1: Try to sync
      _status += '\n\n🔄 Step 1: Attempting to sync...';
      setState(() {});
      
      await UserService.syncUserProfile();
      _status += '\n✅ Sync function completed';

      // Test 2: Verify data was written
      _status += '\n\n🔍 Step 2: Verifying data in Firestore...';
      setState(() {});

      await Future.delayed(const Duration(seconds: 1)); // Wait for write

      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        _userData = doc.data();
        _status += '\n✅ User document found in Firestore!';
        _status += '\n\nDocument Data:';
        _userData?.forEach((key, value) {
          _status += '\n- $key: $value';
        });
      } else {
        _status += '\n❌ User document NOT found in Firestore!';
        _status += '\n\nPossible causes:';
        _status += '\n1. Firebase Security Rules blocking writes';
        _status += '\n2. Network error';
        _status += '\n3. Firebase project misconfiguration';
      }

      // Test 3: Try to read from admin panel path
      _status += '\n\n🔍 Step 3: Testing read access...';
      setState(() {});

      final testRead = await FirebaseFirestore.instance
          .collection('users')
          .limit(1)
          .get();

      _status += '\n✅ Can read from users collection';
      _status += '\n   Found ${testRead.docs.length} user(s)';

    } catch (e, stackTrace) {
      _status += '\n\n❌ ERROR: $e';
      _status += '\n\nStack Trace:';
      _status += '\n$stackTrace';
      
      if (e.toString().contains('permission')) {
        _status += '\n\n⚠️ PERMISSION ERROR!';
        _status += '\nFirebase Security Rules are blocking access.';
        _status += '\n\nGo to Firebase Console → Firestore → Rules';
        _status += '\nAnd update the rules to allow writes.';
      }
    } finally {
      setState(() {
        _testing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Firebase Sync'),
        backgroundColor: const Color(0xFF6B5CE7),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Firebase Sync Test',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will test if user sync to admin panel is working correctly.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (user == null)
              const Card(
                color: Colors.red,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '❌ No user logged in. Please sign in first.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current User:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Email: ${user.email ?? 'N/A'}'),
                      Text('UID: ${user.uid}'),
                      Text('Name: ${user.displayName ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: user == null || _testing ? null : _testSync,
              icon: _testing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bug_report),
              label: Text(_testing ? 'Testing...' : 'Run Test'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Results:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_userData != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '✅ Success! Data is in Firestore',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Now go to admin panel and click Refresh button.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

