import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/step_progress_indicator.dart';
import '../../widgets/skill_chip.dart';
import '../../controllers/resume_controller.dart' as import_controllers;
import '../../controllers/auth_controller.dart';
import '../../models/resume_model.dart';

class CreateResumeScreen extends StatefulWidget {
  const CreateResumeScreen({super.key});

  @override
  State<CreateResumeScreen> createState() => _CreateResumeScreenState();
}

class _CreateResumeScreenState extends State<CreateResumeScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 7;

  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _summaryController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  final List<Map<String, TextEditingController>> _education = [];
  final List<Map<String, TextEditingController>> _experience = [];
  final List<TextEditingController> _skills = [];
  final List<TextEditingController> _languages = [];
  final List<Map<String, TextEditingController>> _projects = [];

  File? _selectedImage;
  bool _removeImage = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _removeImage = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _removeImage = true;
    });
  }

  @override
  void initState() {
    super.initState();
    final resume = Get.find<import_controllers.ResumeController>().currentResume.value;
    final authUser = AuthController.instance.user.value;
    
    final rawName = authUser?.displayName;
    final defaultName = (rawName != null && rawName.trim().isNotEmpty) ? rawName : '';

    _nameController = TextEditingController(
      text: resume?.personalInfo.fullName ?? defaultName
    );
    _titleController = TextEditingController(text: resume?.title ?? '');
    _emailController = TextEditingController(
      text: resume?.personalInfo.email ?? authUser?.email ?? ''
    );
    _summaryController = TextEditingController(text: resume?.summary ?? '');
    _phoneController = TextEditingController(text: resume?.personalInfo.phone ?? '');
    _locationController = TextEditingController(text: resume?.personalInfo.location ?? '');

    if (resume != null) {
      for (var edu in resume.education) {
        _education.add({
          'institution': TextEditingController(text: edu.school),
          'degree': TextEditingController(text: edu.degree),
          'startDate': TextEditingController(text: edu.startDate),
          'endDate': TextEditingController(text: edu.endDate),
        });
      }
      for (var exp in resume.experience) {
        _experience.add({
          'company': TextEditingController(text: exp.company),
          'role': TextEditingController(text: exp.role),
          'startDate': TextEditingController(text: exp.startDate),
          'endDate': TextEditingController(text: exp.endDate),
          'description': TextEditingController(text: exp.responsibilities.join('\n')),
        });
      }
      for (var skill in resume.skills) {
        _skills.add(TextEditingController(text: skill));
      }
      for (var lang in resume.languages) {
        _languages.add(TextEditingController(text: lang));
      }
      for (var proj in resume.projects) {
        _projects.add({
          'name': TextEditingController(text: proj.name),
          'description': TextEditingController(text: proj.description),
        });
      }
    }
  }

  final List<String> _stepLabels = [
    'Personal',
    'Education',
    'Experience',
    'Skills',
    'Languages',
    'Projects',
    'Summary'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _summaryController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    
    for (var edu in _education) {
      edu.values.forEach((c) => c.dispose());
    }
    for (var exp in _experience) {
      exp.values.forEach((c) => c.dispose());
    }
    for (var s in _skills) {
      s.dispose();
    }
    for (var l in _languages) {
      l.dispose();
    }
    for (var proj in _projects) {
      proj.values.forEach((c) => c.dispose());
    }
    
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveResume();
    }
  }

  void _saveResume() {
    final rc = Get.find<import_controllers.ResumeController>();
    final current = rc.currentResume.value;
    if (current == null) return;

    final updatedEdu = _education.map((e) => Education(
      school: e['institution']?.text ?? '',
      degree: e['degree']?.text ?? '',
      startDate: e['startDate']?.text ?? '',
      endDate: e['endDate']?.text ?? '',
      description: '',
    )).toList();

    final updatedExp = _experience.map((e) => Experience(
      company: e['company']?.text ?? '',
      role: e['role']?.text ?? '',
      startDate: e['startDate']?.text ?? '',
      endDate: e['endDate']?.text ?? '',
      responsibilities: e['description']?.text.split('\n').where((s) => s.trim().isNotEmpty).toList() ?? [],
    )).toList();

    final updatedSkills = _skills.map((s) => s.text.trim()).where((s) => s.isNotEmpty).toList();
    final updatedLanguages = _languages.map((s) => s.text.trim()).where((s) => s.isNotEmpty).toList();

    final updatedProj = _projects.map((p) => Project(
      name: p['name']?.text ?? '',
      description: p['description']?.text ?? '',
      technologies: '',
      link: '',
    )).toList();

    String finalPhotoBase64 = current.personalInfo.photoBase64;
    if (_removeImage) {
      finalPhotoBase64 = '';
    } else if (_selectedImage != null) {
      final bytes = _selectedImage!.readAsBytesSync();
      finalPhotoBase64 = base64Encode(bytes);
    }

    final updatedResume = current.copyWith(
      title: _titleController.text,
      summary: _summaryController.text,
      personalInfo: current.personalInfo.copyWith(
        fullName: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        photoBase64: finalPhotoBase64,
      ),
      education: updatedEdu,
      experience: updatedExp,
      skills: updatedSkills,
      languages: updatedLanguages,
      projects: updatedProj,
    );

    rc.currentResume.value = updatedResume;
    rc.saveResume();
    Get.back();
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: _prevStep,
        ),
        title: Text(
          'Edit Resume',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: StepProgressIndicator(
              totalSteps: _totalSteps,
              currentStep: _currentStep,
              stepLabels: _stepLabels,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe to force validation
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildPersonalInfoStep(),
                _buildEducationStep(),
                _buildExperienceStep(),
                _buildSkillsStep(),
                _buildLanguagesStep(),
                _buildProjectsStep(),
                _buildSummaryStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: Personal Info ---
  Widget _buildPersonalInfoStep() {
    final resume = Get.find<import_controllers.ResumeController>().currentResume.value;
    final isExecutive = resume?.template == 'Executive';
    final existingPhotoBase64 = resume?.personalInfo.photoBase64 ?? '';

    return _buildStepContainer(
      title: 'Personal Info',
      children: [
        if (isExecutive)
          Center(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surfaceHigh,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!) as ImageProvider
                        : (!_removeImage && existingPhotoBase64.isNotEmpty)
                            ? MemoryImage(base64Decode(existingPhotoBase64))
                            : null,
                    child: (_selectedImage == null && (_removeImage || existingPhotoBase64.isEmpty))
                        ? const Icon(Icons.person, size: 48, color: AppColors.textMuted)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, size: 16, color: AppColors.background),
                    ),
                  ),
                ),
                if (_selectedImage != null || (!_removeImage && existingPhotoBase64.isNotEmpty))
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _removePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: AppColors.background),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (isExecutive) const SizedBox(height: 32),
        CustomTextField(label: 'Full Name', hintText: 'e.g. John Doe', controller: _nameController),
        const SizedBox(height: 16),
        CustomTextField(label: 'Professional Title', hintText: 'e.g. Flutter Developer', controller: _titleController),
        const SizedBox(height: 16),
        CustomTextField(label: 'Email Address', hintText: 'e.g. john.doe@example.com', controller: _emailController),
        const SizedBox(height: 16),
        CustomTextField(label: 'Phone Number', hintText: '+91 9876543210', controller: _phoneController),
        const SizedBox(height: 16),
        CustomTextField(label: 'City, State', hintText: 'Mumbai, Maharashtra', controller: _locationController),
      ],
    );
  }

  // --- STEP 2: Education ---
  Widget _buildEducationStep() {
    return _buildStepContainer(
      title: 'Education',
      children: [
        ..._education.asMap().entries.map((entry) {
          int idx = entry.key;
          var edu = entry.value;
          return Container(
            key: ValueKey(edu),
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Degree ${idx + 1}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _education[idx].values.forEach((c) => c.dispose());
                          _education.removeAt(idx);
                        });
                      },
                      child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(label: 'Institution Name', hintText: 'University of Technology', controller: edu['institution']),
                const SizedBox(height: 16),
                CustomTextField(label: 'Degree / Course', hintText: 'B.Tech in Computer Science', controller: edu['degree']),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'Start Year', hintText: '2019', controller: edu['startDate'])),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(label: 'End Year', hintText: '2023', controller: edu['endDate'])),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
        CustomButton(
          text: 'Add Education',
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _education.add({
                'institution': TextEditingController(),
                'degree': TextEditingController(),
                'startDate': TextEditingController(),
                'endDate': TextEditingController(),
              });
            });
          },
        ),
      ],
    );
  }

  // --- STEP 3: Experience ---
  Widget _buildExperienceStep() {
    return _buildStepContainer(
      title: 'Experience',
      children: [
        ..._experience.asMap().entries.map((entry) {
          int idx = entry.key;
          var exp = entry.value;
          return Container(
            key: ValueKey(exp),
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Job ${idx + 1}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _experience[idx].values.forEach((c) => c.dispose());
                          _experience.removeAt(idx);
                        });
                      },
                      child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(label: 'Company Name', hintText: 'Tech Solutions Inc.', controller: exp['company']),
                const SizedBox(height: 16),
                CustomTextField(label: 'Job Title', hintText: 'Software Engineer', controller: exp['role']),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'Start Date', hintText: 'Jan 2020', controller: exp['startDate'])),
                    const SizedBox(width: 16),
                    Expanded(child: CustomTextField(label: 'End Date', hintText: 'Present', controller: exp['endDate'])),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Job Description',
                  hintText: 'Describe your responsibilities...',
                  maxLines: 4,
                  controller: exp['description'],
                ),
              ],
            ),
          );
        }).toList(),
        CustomButton(
          text: 'Add Experience',
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _experience.add({
                'company': TextEditingController(),
                'role': TextEditingController(),
                'startDate': TextEditingController(),
                'endDate': TextEditingController(),
                'description': TextEditingController(),
              });
            });
          },
        ),
      ],
    );
  }

  // --- STEP 4: Skills ---
  Widget _buildSkillsStep() {
    return _buildStepContainer(
      title: 'Skills',
      children: [
        CustomButton(
          text: 'Add Skill',
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _skills.add(TextEditingController());
            });
          },
        ),
        const SizedBox(height: 24),
        ..._skills.asMap().entries.map((entry) {
          int idx = entry.key;
          var controller = entry.value;
          return Padding(
            key: ValueKey(controller),
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Skill ${idx + 1}',
                    hintText: 'e.g. Flutter',
                    controller: controller,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _skills[idx].dispose();
                      _skills.removeAt(idx);
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Icon(Icons.delete_outline, color: AppColors.error, size: 24),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // --- STEP 4.5: Languages ---
  Widget _buildLanguagesStep() {
    return _buildStepContainer(
      title: 'Languages',
      children: [
        CustomButton(
          text: 'Add Language',
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _languages.add(TextEditingController());
            });
          },
        ),
        const SizedBox(height: 24),
        ..._languages.asMap().entries.map((entry) {
          int idx = entry.key;
          var controller = entry.value;
          return Padding(
            key: ValueKey(controller),
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    label: 'Language ${idx + 1}',
                    hintText: 'e.g. English',
                    controller: controller,
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _languages[idx].dispose();
                      _languages.removeAt(idx);
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.only(top: 24.0),
                    child: Icon(Icons.delete_outline, color: AppColors.error, size: 24),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  // --- STEP 5: Projects ---
  Widget _buildProjectsStep() {
    return _buildStepContainer(
      title: 'Projects',
      children: [
        ..._projects.asMap().entries.map((entry) {
          int idx = entry.key;
          var proj = entry.value;
          return Container(
            key: ValueKey(proj),
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Project ${idx + 1}', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _projects[idx].values.forEach((c) => c.dispose());
                          _projects.removeAt(idx);
                        });
                      },
                      child: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextField(label: 'Project Name', hintText: 'E-commerce App', controller: proj['name']),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Description',
                  hintText: 'What did you build?',
                  maxLines: 4,
                  controller: proj['description'],
                ),
              ],
            ),
          );
        }).toList(),
        CustomButton(
          text: 'Add Project',
          variant: ButtonVariant.outline,
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              _projects.add({
                'name': TextEditingController(),
                'description': TextEditingController(),
              });
            });
          },
        ),
      ],
    );
  }

  // --- STEP 6: Summary ---
  Widget _buildSummaryStep() {
    return _buildStepContainer(
      title: 'Professional Summary',
      children: [
        CustomTextField(
          label: 'Summary',
          hintText: 'Passionate software engineer with 2 years of experience...',
          controller: _summaryController,
          maxLines: 8,
        ),
      ],
    );
  }

  // --- Common Container ---
  Widget _buildStepContainer({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headline),
                  const SizedBox(height: 8),
                  Container(height: 3, width: 40, color: AppColors.primary),
                  const SizedBox(height: 32),
                  ...children,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderGlass)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: CustomButton(
                      text: 'Back',
                      variant: ButtonVariant.outline,
                      onPressed: _prevStep,
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    text: _currentStep == _totalSteps - 1 ? 'Save & Preview' : 'Next',
                    onPressed: _nextStep,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
