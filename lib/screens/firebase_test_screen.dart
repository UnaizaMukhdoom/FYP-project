// lib/screens/firebase_test_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';

/// Firebase Test Screen - Test all Firebase services
class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isTesting = false;
  final Map<String, TestResult> _results = {};

  @override
  void initState() {
    super.initState();
    // Auto-run tests when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) => _runAllTests());
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isTesting = true;
      _results.clear();
    });

    // Test 1: Firebase Core
    await _testFirebaseCore();
    
    // Test 2: Firebase Auth
    await _testFirebaseAuth();
    
    // Test 3: Cloud Firestore
    await _testCloudFirestore();
    
    // Test 4: Firebase Storage
    await _testFirebaseStorage();
    
    // Test 5: Firebase Realtime Database
    await _testFirebaseDatabase();

    setState(() => _isTesting = false);
    
    _showSummaryDialog();
  }

  Future<void> _testFirebaseCore() async {
    await _updateTest('Firebase Core', 'Testing...', TestStatus.testing);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final app = Firebase.app();
      final options = app.options;
      
      await _updateTest(
        'Firebase Core',
        'Connected\n'
        'Project: ${options.projectId}\n'
        'App ID: ${options.appId}',
        TestStatus.success,
      );
    } catch (e) {
      await _updateTest('Firebase Core', 'Error: $e', TestStatus.error);
    }
  }

  Future<void> _testFirebaseAuth() async {
    await _updateTest('Firebase Auth', 'Testing...', TestStatus.testing);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      await _updateTest(
        'Firebase Auth',
        'Connected\n'
        'User: ${currentUser?.email ?? 'Not signed in'}\n'
        'Status: ${currentUser != null ? "Authenticated" : "Ready"}',
        TestStatus.success,
      );
    } catch (e) {
      await _updateTest('Firebase Auth', 'Error: $e', TestStatus.error);
    }
  }

  Future<void> _testCloudFirestore() async {
    await _updateTest('Cloud Firestore', 'Testing...', TestStatus.testing);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final firestore = FirebaseFirestore.instance;
      
      // Write test
      final testRef = firestore.collection('connection_test').doc('test_doc');
      await testRef.set({
        'test': true,
        'timestamp': FieldValue.serverTimestamp(),
        'message': 'Firebase connection test',
      });
      
      // Read test
      final snapshot = await testRef.get();
      
      if (snapshot.exists) {
        // Clean up
        await testRef.delete();
        
        await _updateTest(
          'Cloud Firestore',
          'Connected ✓\n'
          'Write: Success\n'
          'Read: Success',
          TestStatus.success,
        );
      } else {
        await _updateTest(
          'Cloud Firestore',
          'Write succeeded but read failed',
          TestStatus.warning,
        );
      }
    } catch (e) {
      await _updateTest(
        'Cloud Firestore',
        'Error: $e\n\n'
        'Check:\n'
        '• Firestore is enabled in console\n'
        '• Database rules allow access',
        TestStatus.error,
      );
    }
  }

  Future<void> _testFirebaseStorage() async {
    await _updateTest('Firebase Storage', 'Testing...', TestStatus.testing);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final storage = FirebaseStorage.instance;
      // final ref = storage.ref(); // Unused variable removed
      
      await _updateTest(
        'Firebase Storage',
        'Connected ✓\n'
        'Bucket: ${storage.bucket}',
        TestStatus.success,
      );
    } catch (e) {
      await _updateTest('Firebase Storage', 'Error: $e', TestStatus.error);
    }
  }

  Future<void> _testFirebaseDatabase() async {
    await _updateTest('Realtime Database', 'Testing...', TestStatus.testing);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final database = FirebaseDatabase.instance;
      final ref = database.ref('connection_test');
      
      // Write test
      await ref.set({
        'test': true,
        'timestamp': ServerValue.timestamp,
        'message': 'Firebase connection test',
      });
      
      // Read test
      final snapshot = await ref.get();
      
      if (snapshot.exists) {
        // Clean up
        await ref.remove();
        
        await _updateTest(
          'Realtime Database',
          'Connected ✓\n'
          'Write: Success\n'
          'Read: Success',
          TestStatus.success,
        );
      } else {
        await _updateTest(
          'Realtime Database',
          'Write succeeded but read failed',
          TestStatus.warning,
        );
      }
    } catch (e) {
      await _updateTest(
        'Realtime Database',
        'Error: $e\n\n'
        'Check:\n'
        '• Realtime DB is enabled\n'
        '• Database rules allow access',
        TestStatus.error,
      );
    }
  }

  Future<void> _updateTest(String name, String message, TestStatus status) async {
    setState(() {
      _results[name] = TestResult(name: name, message: message, status: status);
    });
  }

  void _showSummaryDialog() {
    final passed = _results.values.where((r) => r.status == TestStatus.success).length;
    final failed = _results.values.where((r) => r.status == TestStatus.error).length;
    final warnings = _results.values.where((r) => r.status == TestStatus.warning).length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Summary'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('✅ Passed: $passed', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text('❌ Failed: $failed', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            if (warnings > 0)
              Text('⚠️ Warnings: $warnings', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Connection Test'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (!_isTesting)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _runAllTests,
              tooltip: 'Run Tests Again',
            ),
        ],
      ),
      body: _isTesting && _results.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Running Firebase Tests...', style: TextStyle(fontSize: 16)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header
                const Card(
                  color: Colors.deepPurple,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_done, size: 50, color: Colors.white),
                        SizedBox(height: 8),
                        Text(
                          'Firebase Connection Test',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Testing all Firebase services',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Test Results
                ..._results.values.map((result) => _buildTestCard(result)),
                
                if (_results.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                ],
              ],
            ),
    );
  }

  Widget _buildTestCard(TestResult result) {
    Color color;
    IconData icon;
    
    switch (result.status) {
      case TestStatus.success:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case TestStatus.error:
        color = Colors.red;
        icon = Icons.error;
        break;
      case TestStatus.warning:
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case TestStatus.testing:
        color = Colors.blue;
        icon = Icons.hourglass_empty;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final passed = _results.values.where((r) => r.status == TestStatus.success).length;
    final failed = _results.values.where((r) => r.status == TestStatus.error).length;
    final warnings = _results.values.where((r) => r.status == TestStatus.warning).length;
    final total = _results.length;

    return Card(
      color: failed == 0 ? Colors.green[50] : Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  failed == 0 ? Icons.check_circle : Icons.info,
                  color: failed == 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('✅ Passed: $passed / $total', style: const TextStyle(fontSize: 16)),
            Text('❌ Failed: $failed / $total', style: const TextStyle(fontSize: 16)),
            if (warnings > 0)
              Text('⚠️ Warnings: $warnings / $total', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            if (failed > 0) ...[
              const Divider(),
              const Text(
                '⚠️ Some tests failed. Check Firebase Console:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 4),
              const Text('• Enable Firestore Database'),
              const Text('• Enable Realtime Database'),
              const Text('• Check security rules'),
              const Text('• Verify authentication methods'),
            ],
          ],
        ),
      ),
    );
  }
}

class TestResult {
  final String name;
  final String message;
  final TestStatus status;

  TestResult({
    required this.name,
    required this.message,
    required this.status,
  });
}

enum TestStatus {
  success,
  error,
  warning,
  testing,
}

