// lib/screens/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _agree = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _loading = false;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
  String? _confirmValidator(String? v) {
    if (v == null || v.isEmpty) return 'Confirm your password';
    if (v != _password.text) return 'Passwords do not match';
    return null;
  }
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to Terms and Conditions')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      // Sync user profile to admin panel
      await UserService.syncUserProfile();
      await UserService.updateLastLogin();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created successfully!')));
      Navigator.pushReplacementNamed(context, '/questionnaire');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign up failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
  Future<void> _signUpWithGoogle() async {
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
      // Sync user profile to admin panel
      await UserService.syncUserProfile();
      await UserService.updateLastLogin();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google sign up successful!')));
      Navigator.pushReplacementNamed(context, '/questionnaire');
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Google sign up failed: $e')));
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sign Up',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        const Text('Just a few quick things to get started', style: TextStyle(fontSize: 14, color: Colors.black54)),
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
                        const Text('New Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            hintText: 'Enter New Password',
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
                        const SizedBox(height: 20),
                        const Text('Confirm Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirm,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            hintText: 'Enter Confirm Password',
                            filled: true,
                            fillColor: const Color(0xFFFAFAFA),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: _confirmValidator,
                          enabled: !_loading,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Checkbox(
                              value: _agree,
                              onChanged: _loading ? null : (v) => setState(() => _agree = v ?? false),
                              activeColor: Colors.purple,
                            ),
                            const Expanded(
                              child: Text('I Agree With The Terms And Conditions', style: TextStyle(fontSize: 14, color: Colors.black87)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _loading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                                : const Text('Sign Up', style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(child: Text('Or with', style: TextStyle(fontSize: 14, color: Colors.black54))),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _signUpWithGoogle,
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
                              text: 'Already have an account? ',
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: _loading ? null : () => Navigator.pop(context),
                                    child: const Text(
                                      'Sign In',
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