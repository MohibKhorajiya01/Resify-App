import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class DownloadedPDFsScreen extends StatelessWidget {
  const DownloadedPDFsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Downloaded PDFs', style: AppTextStyles.title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.folder_open_outlined,
                  size: 48,
                  color: AppColors.primarySoft,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No PDFs Downloaded Yet',
                style: AppTextStyles.headline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'When you export your resume to PDF, it will appear here for easy access.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
