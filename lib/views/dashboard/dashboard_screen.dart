import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/resume_card.dart';
import '../create_resume/ai_input_screen.dart';
import '../settings/profile_screen.dart';
import '../../controllers/resume_controller.dart';
import '../../models/chat_message.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;

  final ResumeController resumeController = Get.find<ResumeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          _buildHomeTab(),
          _buildResumesTab(),
          const SizedBox(), // Index 2 is handled by routing to /templates
          const ProfileScreen(isFromBottomNav: true),
        ],
      ),
      floatingActionButton: _bottomNavIndex == 0 || _bottomNavIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                // Reset AI session for a fresh resume
                final resumeCtrl = Get.find<ResumeController>();
                resumeCtrl.startNewResume();
                resumeCtrl.chatMessages.clear();
                resumeCtrl.chatMessages.add(ChatMessage(
                  text: "Hi there! I'm your AI Resume Builder. 👋\n\nTell me about your experience, skills, and the role you're targeting. You can write in any language!",
                  isUser: false,
                ));
                resumeCtrl.selectedTemplate.value = '';
                
                Get.toNamed('/templates');
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: AppColors.background),
            )
          : null,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildSliverHeader(),
        SliverToBoxAdapter(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildResumesTab() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Text('All Resumes', style: AppTextStyles.title),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 240.0,
      floating: false,
      pinned: false,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  final user = AuthController.instance.user.value;
                  final rawName = user?.displayName;
                  final name = (rawName != null && rawName.trim().isNotEmpty) ? rawName : 'Guest';
                  
                  String initials = 'G';
                  if (name != 'Guest' && name.isNotEmpty) {
                    final parts = name.trim().split(' ');
                    if (parts.length > 1 && parts[1].isNotEmpty) {
                      initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                    } else {
                      initials = name[0].toUpperCase();
                    }
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Good morning,',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: AppTextStyles.title,
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primarySoft,
                        child: Text(
                          initials,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 12),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${resumeController.userResumes.length} Resumes',
                        style: AppTextStyles.label,
                      ),
                    ],
                  ),
                )),
                const Spacer(),
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => resumeController.searchQuery.value = val,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search resumes...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (resumeController.userResumes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.note_add_outlined, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text('No resumes yet', style: AppTextStyles.headline),
              const SizedBox(height: 8),
              Text(
                'Create your first AI-powered resume',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        );
      }

      final resumes = resumeController.filteredResumes;

      if (resumes.isEmpty) {
        return Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            children: [
              const Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text('No results found', style: AppTextStyles.headline.copyWith(color: AppColors.textMuted)),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Resumes',
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
                Text(
                  'See all',
                  style: AppTextStyles.label,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: resumes.length,
              itemBuilder: (context, index) {
                final resume = resumes[index];
                final formattedDate = DateFormat('MMM dd, yyyy').format(resume.updatedAt);
                
                return ResumeCard(
                  title: resume.title.isEmpty ? 'Untitled Resume' : resume.title,
                  field: resume.field.isEmpty ? 'General' : resume.field,
                  lastEdited: formattedDate,
                  atsScore: resume.atsScore > 0 ? resume.atsScore : 85, // Fallback if 0
                  onTap: () {
                    resumeController.currentResume.value = resume;
                    if (resume.chatHistory.isNotEmpty) {
                      resumeController.chatMessages.assignAll(resume.chatHistory);
                    } else {
                      resumeController.chatMessages.clear();
                      resumeController.chatMessages.add(ChatMessage(
                        text: "Hi there! I'm your AI Resume Builder. 👋\n\nTell me about your experience, skills, and the role you're targeting. You can write in any language!",
                        isUser: false,
                      ));
                    }
                    Get.toNamed('/preview');
                  },
                  onMenuTap: () {
                    Get.bottomSheet(
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Resume Options',
                              style: AppTextStyles.title,
                            ),
                            const SizedBox(height: 24),
                            ListTile(
                              leading: const Icon(Icons.delete_outline, color: AppColors.error),
                              title: Text(
                                'Delete Resume',
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                              ),
                              onTap: () {
                                Get.back(); // close bottom sheet
                                Get.defaultDialog(
                                  backgroundColor: AppColors.surface,
                                  title: 'Delete Resume',
                                  titleStyle: AppTextStyles.title,
                                  middleText: 'Are you sure you want to delete this resume? This action cannot be undone.',
                                  middleTextStyle: AppTextStyles.bodyMedium,
                                  textConfirm: 'Delete',
                                  confirmTextColor: AppColors.textDark,
                                  buttonColor: AppColors.error,
                                  textCancel: 'Cancel',
                                  cancelTextColor: AppColors.textWhite,
                                  onConfirm: () {
                                    resumeController.deleteResume(resume.id);
                                    Get.back(); // close dialog
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      );
    });
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderGlass, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: AppColors.surface,
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          if (index == 2) {
            final resumeCtrl = Get.find<ResumeController>();
            resumeCtrl.startNewResume();
            resumeCtrl.chatMessages.clear();
            resumeCtrl.chatMessages.add(ChatMessage(
              text: "Hi there! I'm your AI Resume Builder. 👋\n\nTell me about your experience, skills, and the role you're targeting. You can write in any language!",
              isUser: false,
            ));
            resumeCtrl.selectedTemplate.value = '';
            Get.toNamed('/templates');
            return;
          }
          setState(() {
            _bottomNavIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.label.copyWith(fontSize: 10, letterSpacing: 0),
        unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(fontSize: 10),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Resumes',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI Builder',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
