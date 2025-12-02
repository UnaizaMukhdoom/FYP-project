// lib/main.dart
// USER APP ENTRY POINT - For Android/Mobile builds
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/intro_start_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/questionnaire_flow_screen.dart';
import 'screens/selfie_screen.dart';
import 'screens/result_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/closet_screen.dart';
import 'screens/ai_stylist_screen.dart';
import 'screens/camera_options_screen.dart';
import 'screens/check_item_camera_screen.dart';
import 'screens/import_item_link_screen.dart';
import 'screens/create_outfit_screen.dart';
import 'screens/fitcheck_intro_screen.dart';
import 'screens/fitcheck_camera_screen.dart';
import 'screens/firebase_test_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/style_profile_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'screens/face_shape_screen.dart';
import 'screens/test_sync_screen.dart';
import 'utils/app_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize app info
  await AppInfo.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VOGUE AI',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const IntroStartScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/signin': (_) => const SignInScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/home': (_) => const DashboardScreen(),
        '/questionnaire': (_) => const QuestionnaireFlowScreen(),
        '/selfie': (_) => const SelfieScreen(),
        '/result': (_) => const ResultScreen(), // Removed const since it reads route args
        '/camera-options': (_) => const CameraOptionsScreen(),
        '/check-item-camera': (_) => const CheckItemCameraScreen(),
        '/import-item-link': (_) => const ImportItemLinkScreen(),
        '/create-outfit': (_) => const CreateOutfitScreen(),
        '/fitcheck-intro': (_) => const FitCheckIntroScreen(),
        '/fitcheck-camera': (_) => const FitCheckCameraScreen(),
        '/discover': (_) => const DiscoverScreen(),
        '/closet': (_) => const ClosetScreen(),
        AIStylistScreen.route: (_) => const AIStylistScreen(), // AI Stylist (Chatbot)
        '/firebase-test': (_) => const FirebaseTestScreen(), // Firebase connection test
        '/profile': (_) => const ProfileScreen(),
        '/style-profile': (_) => const StyleProfileScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/terms': (_) => const TermsOfServiceScreen(),
        FaceShapeScreen.route: (_) => const FaceShapeScreen(),
        '/test-sync': (_) => const TestSyncScreen(),
      },
    );
  }
}
