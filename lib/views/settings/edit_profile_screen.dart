import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = AuthController.instance.user.value;
    _nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) {
      Get.snackbar(
        'Error',
        'Name cannot be empty',
        backgroundColor: AppColors.error,
        colorText: AppColors.textDark,
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final error = await AuthController.instance.updateProfileName(newName);
    
    setState(() => _isLoading = false);

    if (error == null) {
      Get.back();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: AppColors.success,
        colorText: AppColors.background,
      );
    } else {
      Get.snackbar(
        'Error',
        error,
        backgroundColor: AppColors.error,
        colorText: AppColors.textDark,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Edit Profile', style: AppTextStyles.title),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              label: 'Full Name',
              hintText: 'Enter your full name',
              controller: _nameController,
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Save Changes',
                isLoading: _isLoading,
                onPressed: _saveProfile,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
