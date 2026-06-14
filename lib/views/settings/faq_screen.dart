import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> faqs = [
      {
        'question': 'How do I create a resume?',
        'answer': 'Go to the Dashboard, tap on the "+" button or the chat input at the bottom, and simply tell the AI about your experience. It will automatically structure and format a resume for you.'
      },
      {
        'question': 'Can I edit the generated resume?',
        'answer': 'Yes! Once the AI generates your resume, you can tap on it to preview, edit sections manually, and tweak it until it looks perfect.'
      },
      {
        'question': 'Is my data secure?',
        'answer': 'Absolutely. Your resume data is securely stored and linked only to your verified email account. We do not share your personal information with third parties.'
      },
      {
        'question': 'How does the ATS Score work?',
        'answer': 'Our AI evaluates your resume against industry standards, looking for keywords, formatting issues, and overall readability. It gives you a score and actionable tips to improve it.'
      },
      {
        'question': 'Can I download the resume as a PDF?',
        'answer': 'Yes, from the Resume Preview screen, you can export your resume as a professional PDF ready to be sent to recruiters.'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Help & FAQ', style: AppTextStyles.title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24.0),
        itemCount: faqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              collapsedBackgroundColor: AppColors.surface,
              backgroundColor: AppColors.surface,
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(
                faq['question']!,
                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                  child: Text(
                    faq['answer']!,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
