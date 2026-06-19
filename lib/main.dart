import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'core/constants/app_colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/auth_controller.dart';
import 'controllers/resume_controller.dart';

import 'views/splash/splash_screen.dart';
import 'views/onboarding/onboarding_screen.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/auth/verify_email_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'views/create_resume/ai_input_screen.dart';
import 'views/create_resume/create_resume_screen.dart';
import 'views/templates/template_screen.dart';
import 'views/preview/resume_preview_screen.dart';
import 'views/settings/profile_screen.dart';
import 'views/settings/edit_profile_screen.dart';
import 'views/settings/faq_screen.dart';
import 'views/settings/privacy_policy_screen.dart';
import 'views/settings/downloaded_pdfs_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  Get.put(AuthController());
  Get.put(ResumeController());
  
  runApp(const ResifyApp());
}

class ResifyApp extends StatelessWidget {
  const ResifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Resify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/verify_email', page: () => const VerifyEmailScreen()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/ai_input', page: () => const AIInputScreen()),
        GetPage(name: '/create_resume', page: () => const CreateResumeScreen()),
        GetPage(name: '/templates', page: () => const TemplateScreen()),
        GetPage(name: '/preview', page: () => ResumePreviewScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(name: '/edit_profile', page: () => const EditProfileScreen()),
        GetPage(name: '/faq', page: () => const FAQScreen()),
        GetPage(name: '/privacy_policy', page: () => const PrivacyPolicyScreen()),
        GetPage(name: '/downloaded_pdfs', page: () => const DownloadedPDFsScreen()),
      ],
    );
  }
}
