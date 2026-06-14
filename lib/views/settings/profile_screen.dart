import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  final bool isFromBottomNav;
  const ProfileScreen({super.key, this.isFromBottomNav = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 220.0,
      floating: false,
      pinned: true,
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Obx(() {
              final user = AuthController.instance.user.value;
              final rawName = user?.displayName;
              final name = (rawName != null && rawName.trim().isNotEmpty) ? rawName : 'Guest';
              final email = user?.email ?? 'guest@resify.com';
              
              String initials = 'G';
              if (name != 'Guest' && name.isNotEmpty) {
                final parts = name.trim().split(' ');
                if (parts.length > 1 && parts[1].isNotEmpty) {
                  initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                } else {
                  initials = name[0].toUpperCase();
                }
              }

              return Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primarySoft,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildSettingsSection(
            'ACCOUNT',
            [
              _buildListTile(Icons.person_outline, 'Edit Profile', onTap: () {
                Get.toNamed('/edit_profile');
              }),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'RESUME',
            [
              _buildListTile(Icons.description_outlined, 'My Resumes', onTap: () {
                Get.offAllNamed('/dashboard');
              }),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'SUPPORT',
            [
              _buildListTile(Icons.help_outline, 'Help & FAQ', onTap: () {
                Get.toNamed('/faq');
              }),
              _buildListTile(Icons.privacy_tip_outlined, 'Privacy Policy', onTap: () {
                Get.toNamed('/privacy_policy');
              }),
            ],
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Sign Out',
            variant: ButtonVariant.outline,
            onPressed: () {
              AuthController.instance.logout();
              Get.offAllNamed('/login');
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.label),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, {Widget? trailing, String? trailingText, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      trailing: trailing ??
          (trailingText != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(trailingText, style: AppTextStyles.bodySmall),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
                  ],
                )
              : const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20)),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildToggle() {
    return Switch(
      value: true,
      onChanged: (val) {},
      activeThumbColor: AppColors.primary,
      activeTrackColor: AppColors.primarySoft,
      inactiveThumbColor: AppColors.textMuted,
      inactiveTrackColor: AppColors.surfaceHigh,
    );
  }
}
