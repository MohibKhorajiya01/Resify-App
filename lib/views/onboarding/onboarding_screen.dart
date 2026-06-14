import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Create in Minutes',
      'description': 'Tell AI about yourself and get a professional resume instantly.',
      'icon': Icons.description_outlined,
    },
    {
      'title': 'AI Writes For You',
      'description': 'Gemini AI generates professional summaries, skills and experience points.',
      'icon': Icons.auto_awesome,
    },
    {
      'title': 'Download & Share',
      'description': 'Export beautiful PDF resumes and share directly to WhatsApp or email.',
      'icon': Icons.picture_as_pdf_outlined,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextTap() {
    if (_currentPage == _pages.length - 1) {
      Get.offNamed('/login');
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onSkipTap() {
    Get.offNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.surfaceHigh,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _currentPage == _pages.length - 1 ? 'Get Started \u2192' : 'Next',
                    onPressed: _onNextTap,
                  ),
                  const SizedBox(height: 16),
                  if (_currentPage != _pages.length - 1)
                    CustomButton(
                      text: 'Skip',
                      variant: ButtonVariant.text,
                      onPressed: _onSkipTap,
                    )
                  else
                    const SizedBox(height: 52), // Keep spacing consistent
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.borderGlass),
            ),
            child: Center(
              child: Icon(
                page['icon'],
                size: 80,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page['title'],
            style: AppTextStyles.headline,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page['description'],
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textWhite.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
