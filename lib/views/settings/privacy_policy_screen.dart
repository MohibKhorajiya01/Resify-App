import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Privacy Policy', style: AppTextStyles.title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Privacy Policy for Resify',
              style: AppTextStyles.headline,
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: June 2026',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'Welcome to Resify. We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice, or our practices with regards to your personal information, please contact us.',
            ),
            _buildSection(
              '2. Information We Collect',
              'We collect personal information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our products and Services, when you participate in activities on the App, or otherwise when you contact us.\n\nThe personal information that we collect depends on the context of your interactions with us and the App, the choices you make and the products and features you use.',
            ),
            _buildSection(
              '3. How We Use Your Information',
              'We use personal information collected via our App for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations.',
            ),
            _buildSection(
              '4. Will Your Information Be Shared?',
              'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations. Your resume data is kept private and is never sold to third-party advertisers.',
            ),
            _buildSection(
              '5. How Long Do We Keep Your Information?',
              'We will only keep your personal information for as long as it is necessary for the purposes set out in this privacy notice, unless a longer retention period is required or permitted by law.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                '© 2026 Resify. All rights reserved.',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
