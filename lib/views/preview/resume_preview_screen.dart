import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import 'package:printing/printing.dart';
import '../../core/services/pdf_service.dart';
import '../../controllers/resume_controller.dart';
import '../../models/resume_model.dart';

class ResumePreviewScreen extends StatefulWidget {
  const ResumePreviewScreen({super.key});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen> {
  final ResumeController resumeController = Get.find<ResumeController>();
  Future<Uint8List>? _pdfFuture;
  ResumeModel? _lastResume;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Get.offAllNamed('/dashboard'),
        ),
        title: Text(
          'Preview',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final resume = resumeController.currentResume.value;
        if (resume == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        final template = resume.template;
        
        if (_pdfFuture == null || _lastResume != resume) {
          _lastResume = resume;
          _pdfFuture = _rasterizePdf(resume, template);
        }
        
        return FutureBuilder<Uint8List>(
          future: _pdfFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Failed to render preview", style: TextStyle(color: AppColors.textMuted)));
            }
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          )
                        ]
                      ),
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  // Bottom Action Bar directly under resume
                  Container(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32, top: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Share',
                            variant: ButtonVariant.outline,
                            icon: const Icon(Icons.share_rounded, size: 20, color: AppColors.primary),
                            onPressed: () => _sharePdf(resume, template),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'Edit',
                            icon: const Icon(Icons.edit_rounded, size: 20, color: AppColors.textDark),
                            onPressed: () => Get.toNamed('/create_resume'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  Future<Uint8List> _rasterizePdf(ResumeModel resume, String? template) async {
    try {
      final bytes = await PdfService.generateResumePdf(resume, template: template);
      await for (var page in Printing.raster(bytes, dpi: 72)) {
        return await page.toPng();
      }
    } catch (e) {
      debugPrint('Error rasterizing PDF: $e');
    }
    return Uint8List(0);
  }

  Future<void> _sharePdf(ResumeModel resume, String? template) async {
    try {
      Get.snackbar(
        'Generating PDF', 
        'Please wait...', 
        backgroundColor: AppColors.surfaceHigh, 
        colorText: AppColors.textWhite,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );
      
      final bytes = await PdfService.generateResumePdf(resume, template: template);
      
      String safeTitle = resume.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').replaceAll(' ', '_');
      if (safeTitle.isEmpty) safeTitle = 'Resume';
      
      await Printing.sharePdf(bytes: bytes, filename: '$safeTitle.pdf');
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to share PDF: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

}
