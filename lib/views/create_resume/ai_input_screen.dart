import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../controllers/resume_controller.dart';
import '../../models/chat_message.dart';

// Theme Colors mapped from AppColors
const Color _waBgColor = AppColors.background;
const Color _waAppBarColor = AppColors.surface;
const Color _waUserBubbleColor = AppColors.surfaceHigh;
const Color _waAIBubbleColor = AppColors.softBg;
const Color _waInputBgColor = AppColors.surfaceHigh;
const Color _waSendBtnColor = AppColors.primary;
const Color _waTextColor = AppColors.textWhite;
const Color _waSecondaryTextColor = AppColors.textMuted;
const Color _waVerifiedColor = AppColors.primary;

class AIInputScreen extends StatefulWidget {
  final bool isFromBottomNav;
  const AIInputScreen({super.key, this.isFromBottomNav = false});

  @override
  State<AIInputScreen> createState() => _AIInputScreenState();
}

class _AIInputScreenState extends State<AIInputScreen> {
  final _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedField = '';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _fields = [
    'IT/Developer',
    'Designer',
    'MBA/Finance',
    'Medical',
    'Teacher',
    'Engineering',
    'Fresher',
    'Other'
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
      });
    }
  }

  void _clearChat() {
    Get.defaultDialog(
      backgroundColor: AppColors.surface,
      title: 'Clear Chat',
      titleStyle: AppTextStyles.title,
      middleText: 'Are you sure you want to clear the chat history?',
      middleTextStyle: AppTextStyles.bodyMedium,
      textConfirm: 'Clear',
      textCancel: 'Cancel',
      confirmTextColor: AppColors.background,
      cancelTextColor: AppColors.primary,
      buttonColor: AppColors.error,
      onConfirm: () {
        ResumeController.instance.chatMessages.clear();
        ResumeController.instance.chatMessages.add(ChatMessage(
          text: "Hi there! I'm your AI Resume Builder. 👋\n\nTell me about your experience, skills, and the role you're targeting. You can write in any language!",
          isUser: false,
        ));
        if (ResumeController.instance.currentResume.value?.id.isNotEmpty == true) {
          ResumeController.instance.saveResume();
        }
        Get.back();
      },
    );
  }

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty && _selectedField.isEmpty) {
      return;
    }

    String prompt = text;
    if (_selectedField.isNotEmpty) {
      prompt += '\n\nTarget Field/Industry: $_selectedField';
    }

    final selectedTemplate = ResumeController.instance.selectedTemplate.value;
    if (selectedTemplate == 'Executive' && _selectedImage == null) {
      Get.snackbar(
        'Photo Required',
        'Please attach a professional photo for the Executive template.',
        backgroundColor: AppColors.error.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }

    final chatMessages = ResumeController.instance.chatMessages;

    setState(() {
      String userMessageText = text;
      if (text.isEmpty) {
        userMessageText = 'Target Field: $_selectedField';
      }
      
      chatMessages.add(ChatMessage(text: userMessageText, isUser: true));
      _inputController.clear();
      _selectedField = '';
    });
    
    _scrollToBottom();

    // Capture image and clear state so it disappears from UI
    final imageToSend = _selectedImage;
    setState(() {
      _selectedImage = null;
    });

    // Generate resume via AI
    final String? errorMessage = await ResumeController.instance.generateFromPrompt(
      prompt,
      profileImage: imageToSend,
    );
    
    if (mounted) {
      if (errorMessage == null) {
        chatMessages.add(ChatMessage(
          text: 'I have successfully generated your resume!', 
          isUser: false, 
          isResumeCard: true,
        ));
      } else if (errorMessage != "Input required") {
        chatMessages.add(ChatMessage(
          text: errorMessage, 
          isUser: false,
        ));
      }
      
      chatMessages.refresh();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isFromBottomNav ? null : _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                final chatMessages = ResumeController.instance.chatMessages;
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: chatMessages.length + (ResumeController.instance.isGeneratingAI.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatMessages.length) {
                       return _buildChatBubble(ChatMessage(text: '', isUser: false, isLoading: true));
                    }
                    
                    final msg = chatMessages[index];
                    
                    // If it's the first actual message, show fields below it
                    if (index == 0) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildChatBubble(msg),
                          const SizedBox(height: 12),
                          _buildQuickSelectChips(),
                          const SizedBox(height: 16),
                        ],
                      );
                    }
                    return _buildChatBubble(msg);
                  },
                );
              }),
            ),
            _buildBottomInputArea(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: _waAppBarColor,
      elevation: 0,
      leadingWidth: 40,
      leading: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back, color: _waTextColor),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: Colors.white12, width: 1),
              image: const DecorationImage(
                image: AssetImage('assets/icon/resify_icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Resify AI', style: AppTextStyles.title.copyWith(fontSize: 18, color: _waTextColor)),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: _waTextColor),
          color: AppColors.surfaceHigh,
          onSelected: (value) {
            if (value == 'clear_chat') {
              _clearChat();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'clear_chat',
              child: Text('Clear Chat', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final bool isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              margin: isUser ? const EdgeInsets.only(left: 40) : const EdgeInsets.only(right: 40),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? _waUserBubbleColor : _waAIBubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
                  topRight: const Radius.circular(12),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
                ),
              ),
              child: message.isLoading
                  ? const PulseLoadingSkeleton()
                  : message.isResumeCard 
                      ? _buildResumeCard()
                      : SelectableText(
                          message.text,
                          style: const TextStyle(
                            color: _waTextColor,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumeCard() {
    return GestureDetector(
      onTap: () => Get.toNamed('/preview'),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(top: 4, bottom: 4),
        decoration: BoxDecoration(
          color: _waInputBgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF1E2B33),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Center(
                child: Icon(Icons.picture_as_pdf, color: _waVerifiedColor, size: 40),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resume Ready!', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: _waTextColor)),
                  const SizedBox(height: 4),
                  Text('Tap to view and edit', style: AppTextStyles.bodySmall.copyWith(color: _waSecondaryTextColor)),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _waSendBtnColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: Text('Open', style: AppTextStyles.label.copyWith(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSelectChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Quick Select Field:',
            style: AppTextStyles.label.copyWith(color: _waSecondaryTextColor),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _fields.map((field) {
            final isSelected = _selectedField == field;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedField = isSelected ? '' : field;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _waSendBtnColor.withValues(alpha: 0.1) : _waAIBubbleColor,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: isSelected ? _waSendBtnColor : Colors.transparent,
                  ),
                ),
                child: Text(
                  field,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? _waSendBtnColor : _waSecondaryTextColor,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomInputArea() {
    final hasText = _inputController.text.isNotEmpty || _selectedField.isNotEmpty;

    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12, top: 8),
      color: AppColors.background,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template Preview Attachment & Photo Preview
          Obx(() {
            final template = ResumeController.instance.selectedTemplate.value;
            if (template.isNotEmpty || _selectedImage != null) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8, left: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (template.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.primarySoft.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.description, color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$template Template',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  ResumeController.instance.selectedTemplate.value = '';
                                  Get.toNamed('/templates');
                                },
                                child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedImage != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.file(_selectedImage!, width: 24, height: 24, fit: BoxFit.cover),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Photo Attached',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                                child: const Icon(Icons.close, color: AppColors.textMuted, size: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _waInputBgColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: _waSecondaryTextColor),
                        onPressed: () => Get.toNamed('/templates'),
                      ),
                      Obx(() {
                        if (ResumeController.instance.selectedTemplate.value == 'Executive') {
                          return IconButton(
                            icon: const Icon(Icons.photo_library_outlined, color: _waSecondaryTextColor),
                            onPressed: _pickImage,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLines: 6,
                          minLines: 1,
                          style: const TextStyle(color: _waTextColor, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'Message',
                            hintStyle: TextStyle(color: _waSecondaryTextColor, fontSize: 16),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: hasText ? _sendMessage : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasText ? _waSendBtnColor : _waSendBtnColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.send,
                    color: hasText ? _waBgColor : _waBgColor.withValues(alpha: 0.5),
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Skeleton Loading Animation for AI Bubble
// ---------------------------------------------------------
class PulseLoadingSkeleton extends StatefulWidget {
  const PulseLoadingSkeleton({super.key});

  @override
  State<PulseLoadingSkeleton> createState() => _PulseLoadingSkeletonState();
}

class _PulseLoadingSkeletonState extends State<PulseLoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _colorAnimation = ColorTween(begin: _waInputBgColor, end: const Color(0xFF3B4A54)).animate(_controller);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        Widget buildLine(double width, double height) {
           return Container(
             height: height,
             width: width,
             decoration: BoxDecoration(
               color: _colorAnimation.value, 
               borderRadius: BorderRadius.circular(4)
             ),
           );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.document_scanner_outlined, color: _waSecondaryTextColor.withValues(alpha: 0.5), size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crafting your resume...',
                    style: TextStyle(color: _waTextColor, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  buildLine(double.infinity, 8),
                  const SizedBox(height: 8),
                  buildLine(180, 8),
                  const SizedBox(height: 8),
                  buildLine(120, 8),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
