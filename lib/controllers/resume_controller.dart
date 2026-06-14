import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/resume_model.dart';
import '../models/chat_message.dart';
import '../core/services/gemini_service.dart';
import '../core/constants/app_colors.dart';

class ResumeController extends GetxController {
  static ResumeController instance = Get.find();
  
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Current working resume
  Rx<ResumeModel?> currentResume = Rx<ResumeModel?>(null);
  
  // Selected Template Style
  final selectedTemplate = 'Modern'.obs;
  
  // Loading states
  RxBool isGeneratingAI = false.obs;
  RxBool isSaving = false.obs;

  // User's saved resumes
  final RxList<ResumeModel> userResumes = <ResumeModel>[].obs;
  
  // Search state
  final RxString searchQuery = ''.obs;

  List<ResumeModel> get filteredResumes {
    if (searchQuery.value.isEmpty) {
      return userResumes;
    }
    final query = searchQuery.value.toLowerCase();
    return userResumes.where((resume) {
      return resume.title.toLowerCase().contains(query) ||
             resume.field.toLowerCase().contains(query);
    }).toList();
  }

  // Persistent Chat History
  final RxList<ChatMessage> chatMessages = <ChatMessage>[
    ChatMessage(
      text: "Hi there! I'm your AI Resume Builder. 👋\n\nTell me about your experience, skills, and the role you're targeting. You can write in any language!",
      isUser: false,
    )
  ].obs;

  @override
  void onInit() {
    super.onInit();
    if (auth.currentUser != null) {
      fetchUserResumes();
    }
  }

  void startNewResume() {
    currentResume.value = ResumeModel(
      id: '',
      userId: auth.currentUser?.uid ?? '',
      title: 'Untitled Resume',
      field: 'General',
      summary: '',
      atsScore: 0,
      updatedAt: DateTime.now(),
      personalInfo: PersonalInfo(
        fullName: auth.currentUser?.displayName ?? '',
        email: auth.currentUser?.email ?? '',
        phone: '',
        location: '',
        linkedIn: '',
        github: '',
        portfolio: '',
      ),
      education: [],
      experience: [],
      skills: [],
      projects: [],
      template: selectedTemplate.value.isNotEmpty ? selectedTemplate.value : 'Modern',
    );
  }

  Future<String?> generateFromPrompt(String prompt, {File? profileImage}) async {
    final String cleanPrompt = prompt.trim();
    if (cleanPrompt.isEmpty) {
      return "Please enter some details about yourself to get started!";
    }

    final int wordCount = cleanPrompt.split(RegExp(r'\s+')).length;
    final bool isQuickSelect = cleanPrompt.contains('Target Field/Industry:');
    
    if (wordCount < 10 && !isQuickSelect) {
      return "These details are a bit too short! 😅 To build a great and professional resume, please provide a bit more detail (such as your skills, experience, or the role you're applying for).";
    }

    try {
      isGeneratingAI.value = true;
      
      // Capture the selected template from UI and clear it immediately so it disappears during loading
      final String capturedTemplate = selectedTemplate.value;
      if (capturedTemplate.isNotEmpty) {
        selectedTemplate.value = '';
      }
      
      // Initialize a new resume if none exists
      if (currentResume.value == null) {
        startNewResume();
      }

      final generatedData = await GeminiService.generateResumeFromPrompt(prompt);
      
      // Merge AI generated data with current resume
      final current = currentResume.value!;
      
      final Map<String, dynamic> mergedMap = current.toMap();
      
      // Override with AI data
      mergedMap['title'] = generatedData['title'] ?? current.title;
      mergedMap['field'] = generatedData['field'] ?? current.field;
      mergedMap['summary'] = generatedData['summary'] ?? current.summary;
      mergedMap['atsScore'] = generatedData['atsScore'] ?? current.atsScore;
      
      if (profileImage != null) {
        final bytes = await profileImage.readAsBytes();
        final base64Image = base64Encode(bytes);
        final personalInfoMap = mergedMap['personalInfo'] as Map<String, dynamic>;
        personalInfoMap['photoBase64'] = base64Image;
        mergedMap['personalInfo'] = personalInfoMap;
      }
      
      if (generatedData['skills'] != null) {
        mergedMap['skills'] = generatedData['skills'];
      }
      if (generatedData['experience'] != null) {
        mergedMap['experience'] = generatedData['experience'];
      }
      if (generatedData['education'] != null) {
        mergedMap['education'] = generatedData['education'];
      }
      if (generatedData['projects'] != null) {
        mergedMap['projects'] = generatedData['projects'];
      }
      
      // Update template if one is selected in the UI
      if (capturedTemplate.isNotEmpty) {
        mergedMap['template'] = capturedTemplate;
      }

      // Preserve the current ID so we don't lose it if we are editing
      currentResume.value = ResumeModel.fromMap(mergedMap, current.id);
      
      // Auto-save generated resume without blocking the AI completion
      saveResume();
      
      return null; // Null means success
      
    } catch (e) {
      final errorStr = e.toString();
      
      if (errorStr.contains('RATE_LIMIT')) {
        return "I am receiving too many requests right now! Please give me about 60 seconds to catch my breath and try sending your message again. ⏳";
      }
      
      if (errorStr.contains('BAD_PROMPT')) {
        return "I couldn't quite understand that. Could you please provide a bit more detail about your experience, skills, or what kind of job you're looking for? 😅";
      }
      
      // Fallback for real unexpected errors
      return "I apologize, but I encountered an error while building your resume. Please try again.";
    } finally {
      isGeneratingAI.value = false;
    }
  }

  Future<void> saveResume() async {
    if (currentResume.value == null) return;
    
    try {
      isSaving.value = true;
      final uid = auth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      String resumeId = currentResume.value!.id;
      
      // If it's a new resume, generate an ID
      if (resumeId.isEmpty) {
        final docRef = firestore.collection('users').doc(uid).collection('resumes').doc();
        resumeId = docRef.id;
        
        // Update the model with the new ID
        final map = currentResume.value!.toMap();
        currentResume.value = ResumeModel.fromMap(map, resumeId);
      }

      // Save to Firestore
      final mapToSave = currentResume.value!.toMap();
      mapToSave['chatHistory'] = chatMessages.map((e) => e.toMap()).toList();
      
      await firestore
          .collection('users')
          .doc(uid)
          .collection('resumes')
          .doc(resumeId)
          .set(mapToSave);

      Get.snackbar(
        'Saved', 
        'Resume saved successfully!',
        backgroundColor: AppColors.success,
        colorText: AppColors.background,
      );
      
    } catch (e) {
      Get.snackbar(
        'Save Failed', 
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.textDark,
      );
    } finally {
      isSaving.value = false;
    }
  }

  void fetchUserResumes() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    firestore
        .collection('users')
        .doc(uid)
        .collection('resumes')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      userResumes.value = snapshot.docs.map((doc) {
        return ResumeModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Auto-load latest resume chat if none is active (e.g. on app startup)
      if (currentResume.value == null && userResumes.isNotEmpty) {
        final latest = userResumes.first;
        currentResume.value = latest;
        if (latest.chatHistory.isNotEmpty) {
          chatMessages.assignAll(latest.chatHistory);
        } else {
          chatMessages.clear();
          chatMessages.add(ChatMessage(
            text: "Hi there! I'm your AI Resume Builder. 👋\n\nTell me about your experience, skills, and the role you're targeting. You can write in any language!",
            isUser: false,
          ));
        }
      }
    });
  }
  Future<void> deleteResume(String resumeId) async {
    try {
      final uid = auth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      await firestore
          .collection('users')
          .doc(uid)
          .collection('resumes')
          .doc(resumeId)
          .delete();

      Get.snackbar(
        'Deleted', 
        'Resume deleted successfully',
        backgroundColor: AppColors.success,
        colorText: AppColors.background,
      );
    } catch (e) {
      Get.snackbar(
        'Delete Failed', 
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: AppColors.textDark,
      );
    }
  }
}
