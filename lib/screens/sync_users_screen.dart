// lib/screens/sync_users_screen.dart
// Helper screen to manually sync users to admin panel
import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncUsersScreen extends StatefulWidget {
  const SyncUsersScreen({super.key});

  @override
  State<SyncUsersScreen> createState() => _SyncUsersScreenState();
}

class _SyncUsersScreenState extends State<SyncUsersScreen> {
  bool _syncing = false;
  String _status = '';

  Future<void> _syncCurrentUser() async {
    setState(() {
      _syncing = true;
      _status = 'Syncing current user...';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _status = '❌ No user logged in. Please sign in first.';
          _syncing = false;
        });
        return;
      }

      await UserService.syncUserProfile();
      await UserService.updateLastLogin();

      setState(() {
        _status = '✅ User synced successfully!\n'
            'Email: ${user.email}\n'
            'UID: ${user.uid}\n\n'
            'Check Firebase Console → Firestore → users collection';
        _syncing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ User synced to admin panel!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _syncing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync User to Admin Panel'),
        backgroundColor: const Color(0xFF6B5CE7),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Sync Current User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This will sync your current user profile to the admin panel.\n'
              'After syncing, refresh the admin panel dashboard to see the update.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            if (user != null) ...[
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
            ] else ...[
              const Card(
                color: Colors.orange,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '⚠️ No user logged in. Please sign in first.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: user == null || _syncing ? null : _syncCurrentUser,
              icon: _syncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(_syncing ? 'Syncing...' : 'Sync User to Admin Panel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                color: _status.contains('✅')
                    ? Colors.green.shade50
                    : _status.contains('❌')
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _status,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Troubleshooting:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. After syncing, go to admin panel\n'
              '2. Click the "Refresh" button on dashboard\n'
              '3. Check Firebase Console → Firestore → users collection\n'
              '4. If still not showing, check browser console (F12) for errors',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

