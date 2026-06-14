import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    
    // Check if user is already verified
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();
      
      // Check periodically if email is verified
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) setState(() => canResendEmail = true);
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to send verification email. Please try again.';
      if (e.code == 'too-many-requests') {
        message = 'Too many requests. Please wait a moment before trying again.';
      }
      Get.snackbar(
        'Email Sending Failed',
        message,
        backgroundColor: AppColors.error,
        colorText: AppColors.textDark,
      );
    } catch (e) {
      Get.snackbar(
        'Email Sending Failed',
        'Something went wrong. Please try again.',
        backgroundColor: AppColors.error,
        colorText: AppColors.textDark,
      );
    }
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // Wait a moment so user can see the success tick
      await Future.delayed(const Duration(seconds: 2));
      
      // Save user to Firestore only after they are verified
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await AuthController.instance.ensureFirestoreData(user);
      }
      
      Get.offAllNamed('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () {
            FirebaseAuth.instance.signOut();
            Get.offAllNamed('/login');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: isEmailVerified
                    ? Container(
                        key: const ValueKey('verified'),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 64,
                        ),
                      )
                    : Container(
                        key: const ValueKey('pending'),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
              ),
              const SizedBox(height: 32),
              Text(
                isEmailVerified ? 'Email Verified!' : 'Verify your email',
                textAlign: TextAlign.center,
                style: AppTextStyles.displayMedium.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),
              Text(
                isEmailVerified 
                  ? 'Your account has been verified successfully. Redirecting to your dashboard...'
                  : 'We have sent a verification email to ${FirebaseAuth.instance.currentUser?.email ?? "your email"}.\n\nPlease check your inbox and click the link to verify your account.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              if (!isEmailVerified) ...[
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Waiting for verification...',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 48),
                CustomButton(
                  text: 'Resend Email',
                  variant: ButtonVariant.outline,
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    Get.offAllNamed('/login');
                  },
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.label.copyWith(color: AppColors.error, letterSpacing: 0),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
