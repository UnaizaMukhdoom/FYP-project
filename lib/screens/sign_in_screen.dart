// lib/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _rememberMe = false;
  bool _obscure = true;
  bool _loading = false;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final ok = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$').hasMatch(v.trim());
    if (!ok) return 'Enter a valid email';
    return null;
  }
  String? _passwordValidator(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Min 6 characters';
    return null;
  }
  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      
      // Wait a moment for auth to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Sync user profile to admin panel
      print('🔄 Starting user sync after sign in...');
      try {
        await UserService.syncUserProfile();
        print('✅ User sync completed successfully');
        await UserService.updateLastLogin();
        
        // Verify sync worked
        final profile = await UserService.getUserProfile();
        if (profile != null) {
          print('✅ Verified: User data exists in Firestore');
          print('   Email: ${profile['email']}');
        } else {
          print('⚠️ Warning: User data not found in Firestore after sync');
        }
      } catch (e, stackTrace) {
        print('❌ User sync failed: $e');
        print('   Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful, but sync failed: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign in successful!')));
      Navigator.pushReplacementNamed(context, '/questionnaire');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign in failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      final GoogleSignInAccount? user = await googleSignIn.signIn();
      if (user == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }
      final auth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      
      // Wait a moment for auth to complete
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Sync user profile to admin panel
      print('🔄 Starting user sync after Google sign in...');
      try {
        await UserService.syncUserProfile();
        print('✅ User sync completed successfully');
        await UserService.updateLastLogin();
        
        // Verify sync worked
        final profile = await UserService.getUserProfile();
        if (profile != null) {
          print('✅ Verified: User data exists in Firestore');
          print('   Email: ${profile['email']}');
        } else {
          print('⚠️ Warning: User data not found in Firestore after sync');
        }
      } catch (e, stackTrace) {
        print('❌ User sync failed: $e');
        print('   Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful, but sync failed: $e'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign in successful!')));
      Navigator.pushReplacementNamed(context, '/questionnaire');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign in failed: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8D5FF), Color(0xFFFFB6C1)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sign In', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 8),
                        const Text('Welcome back you\'ve been missed', style: TextStyle(fontSize: 14, color: Colors.black54)),
                        const SizedBox(height: 32),
                        const Text('Email ID', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            hintText: 'Enter Email ID',
                            filled: true,
                            fillColor: Color(0xFFFAFAFA),
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 20),
                        const Text('Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                              onPressed: () => setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: _passwordValidator,
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: _loading ? null : (v) => setState(() => _rememberMe = v ?? false),
                                activeColor: Colors.purple,
                              ),
                              const Text('Remember Me', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            ]),
                            TextButton(
                              onPressed: _loading ? null : () => Navigator.pushNamed(context, '/forgot'),
                              child: const Text('Forgot Password?', style: TextStyle(fontSize: 14, color: Colors.black54)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _loading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Sign In', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(child: Text('Or with', style: TextStyle(fontSize: 14, color: Colors.black54))),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _signInWithGoogle,
                                icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                                label: const Text('Google'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: 'Don\'t have an account? ',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _loading ? null : () => Navigator.pushNamed(context, '/signup'),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}