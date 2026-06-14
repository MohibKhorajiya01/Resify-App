import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/resume_model.dart';
import '../../controllers/resume_controller.dart';

class PdfService {
  static Future<Uint8List> generateResumePdf(ResumeModel resume, {String? template}) async {
    String selectedTemplate = template ?? resume.template;
    if (selectedTemplate.isEmpty) {
      selectedTemplate = Get.find<ResumeController>().selectedTemplate.value;
    }
    
    final pdf = pw.Document();

    pw.Font? iconFont;
    if (selectedTemplate == 'Classic') {
      try {
        iconFont = await PdfGoogleFonts.materialIconsRegular();
      } catch (e) {
        debugPrint('Failed to load icon font: $e');
      }
    }

    pw.Page page;
    switch (selectedTemplate) {
      case 'Classic':
        page = _buildClassicTemplate(resume, iconFont);
        break;
      case 'Minimal':
        page = _buildMinimalTemplate(resume);
        break;
      case 'Creative':
        page = _buildCreativeTemplate(resume);
        break;
      case 'Grid':
        page = _buildGridTemplate(resume);
        break;
      case 'Executive':
        page = _buildExecutiveTemplate(resume);
        break;
      case 'Modern':
      default:
        page = _buildModernTemplate(resume);
        break;
    }

    pdf.addPage(page);
    return pdf.save();
  }

  // ==========================================
  // TEMPLATE 1: MODERN (Current Blue Header)
  // ==========================================
  static pw.Page _buildModernTemplate(ResumeModel resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Header Section
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(32),
              color: const PdfColor.fromInt(0xFF1E88E5), // Primary blue
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    resume.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 28, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    resume.field,
                    style: pw.TextStyle(color: PdfColors.white, fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    '${resume.personalInfo.email}  |  ${resume.personalInfo.phone}  |  ${resume.personalInfo.location}',
                    style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                  ),
                  if (resume.personalInfo.linkedIn.isNotEmpty || resume.personalInfo.github.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Text(
                        '${resume.personalInfo.linkedIn}  |  ${resume.personalInfo.github}',
                        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
                      ),
                    ),
                ],
              ),
            ),
            // Body Content
            pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: _buildStandardBodyContent(resume, const PdfColor.fromInt(0xFF1E88E5)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TEMPLATE 2: CLASSIC (Professional Two-Column)
  // ==========================================
  
  static pw.Widget _buildContactItem(int iconCodePoint, String text, pw.Font? iconFont) {
    if (text.isEmpty) return pw.SizedBox();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (iconFont != null)
          pw.Icon(pw.IconData(iconCodePoint), font: iconFont, size: 12, color: const PdfColor.fromInt(0xFF333333))
        else
          pw.SizedBox(width: 12, height: 12),
        pw.SizedBox(width: 8),
        pw.Expanded(child: pw.Text(text, style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF333333)))),
      ]
    );
  }

  static pw.Widget _buildProfessionalSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 12, top: 16),
      child: pw.Stack(
        children: [
          pw.Positioned(
            left: -6,
            top: -4,
            child: pw.Container(
              width: 20,
              height: 20,
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFE0E0E0),
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 0),
            child: pw.Text(
              title.toUpperCase(),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 2, color: const PdfColor.fromInt(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Page _buildClassicTemplate(ResumeModel resume, pw.Font? iconFont) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Centered Header
            pw.Center(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    resume.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, letterSpacing: 4, color: const PdfColor.fromInt(0xFF333333)),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Container(width: 6, height: 6, decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF555555), shape: pw.BoxShape.circle)),
                      pw.SizedBox(width: 4),
                      pw.Container(width: 60, height: 0.5, color: const PdfColor.fromInt(0xFF555555)),
                      pw.SizedBox(width: 12),
                      pw.Text(
                        resume.field.toUpperCase(),
                        style: pw.TextStyle(fontSize: 10, color: const PdfColor.fromInt(0xFF777777), letterSpacing: 4),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Container(width: 60, height: 0.5, color: const PdfColor.fromInt(0xFF555555)),
                      pw.SizedBox(width: 4),
                      pw.Container(width: 6, height: 6, decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF555555), shape: pw.BoxShape.circle)),
                    ]
                  ),
                  pw.SizedBox(height: 24),
                  pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                ],
              ),
            ),
            // Body Content
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                  // Left Column
                  pw.Expanded(
                    flex: 35,
                    child: pw.Container(
                      decoration: const pw.BoxDecoration(
                        border: pw.Border(right: pw.BorderSide(color: PdfColor.fromInt(0xFFBDBDBD), width: 0.5)),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.only(right: 16),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                _buildProfessionalSectionTitle('Contact'),
                                _buildContactItem(0xe4cd, resume.personalInfo.phone, iconFont),
                                pw.SizedBox(height: 8),
                                _buildContactItem(0xe158, resume.personalInfo.email, iconFont),
                                pw.SizedBox(height: 8),
                                _buildContactItem(0xe0c8, resume.personalInfo.location, iconFont),
                                pw.SizedBox(height: 16),
                              ],
                            ),
                          ),
                          pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                          
                          if (resume.education.isNotEmpty) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(right: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildProfessionalSectionTitle('Education'),
                                  ...resume.education.map((edu) => pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text('${edu.startDate} - ${edu.endDate}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF666666))),
                                      pw.SizedBox(height: 6),
                                      pw.Text(edu.school.toUpperCase(), style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF444444))),
                                      pw.SizedBox(height: 4),
                                      pw.Text('• ${edu.degree}', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF666666))),
                                      if (edu.description.isNotEmpty) ...[
                                        pw.SizedBox(height: 2),
                                        pw.Text('• ${edu.description}', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF666666))),
                                      ],
                                      pw.SizedBox(height: 12),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                          ],
                          
                          if (resume.skills.isNotEmpty) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(right: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildProfessionalSectionTitle('Skills'),
                                  ...resume.skills.map((skill) => pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 6),
                                    child: pw.Text('• ${skill.toUpperCase()}', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF555555))),
                                  )),
                                  pw.SizedBox(height: 12),
                                ],
                              ),
                            ),
                            pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                          ],

                          if (resume.languages.isNotEmpty) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(right: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildProfessionalSectionTitle('Languages'),
                                  ...resume.languages.map((lang) => pw.Padding(
                                    padding: const pw.EdgeInsets.only(bottom: 6),
                                    child: pw.Text('• ${lang.toUpperCase()}', style: const pw.TextStyle(fontSize: 9, color: PdfColor.fromInt(0xFF555555))),
                                  )),
                                  pw.SizedBox(height: 12),
                                ],
                              ),
                            ),
                            pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  // Right Column
                  pw.Expanded(
                    flex: 65,
                    child: pw.Container(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (resume.summary.isNotEmpty) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildProfessionalSectionTitle('Profile Summary'),
                                  pw.Text(resume.summary, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666), lineSpacing: 1.5)),
                                  pw.SizedBox(height: 16),
                                ],
                              ),
                            ),
                            pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                          ],
                          
                          if (resume.experience.isNotEmpty) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildProfessionalSectionTitle('Work Experience'),
                                  ...resume.experience.map((exp) => pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(exp.role, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF444444))),
                                          pw.Text('${exp.startDate} - ${exp.endDate}', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666))),
                                        ],
                                      ),
                                      pw.SizedBox(height: 4),
                                      pw.Text(exp.company, style: pw.TextStyle(fontSize: 10, color: const PdfColor.fromInt(0xFF666666))),
                                      pw.SizedBox(height: 4),
                                      ...exp.responsibilities.map((resp) => pw.Row(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text('• ', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666))),
                                          pw.Expanded(child: pw.Text(resp, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666), lineSpacing: 1.2))),
                                        ],
                                      )),
                                      pw.SizedBox(height: 12),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            pw.Container(height: 0.5, width: double.infinity, color: const PdfColor.fromInt(0xFFBDBDBD)),
                          ],

                          if (resume.projects.isNotEmpty) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  _buildProfessionalSectionTitle('Projects'),
                                  ...resume.projects.map((proj) => pw.Column(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Row(
                                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                        children: [
                                          pw.Text(proj.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF444444))),
                                          if (proj.technologies.isNotEmpty)
                                            pw.Text(proj.technologies, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666))),
                                        ],
                                      ),
                                      pw.SizedBox(height: 4),
                                      ...proj.description.split('\n').where((s) => s.trim().isNotEmpty).map((line) => pw.Row(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text('• ', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666))),
                                          pw.Expanded(child: pw.Text(line.trim(), style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF666666), lineSpacing: 1.2))),
                                        ],
                                      )),
                                      pw.SizedBox(height: 12),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TEMPLATE 3: MINIMAL (Clean, Lots of whitespace)
  // ==========================================
  static pw.Page _buildMinimalTemplate(ResumeModel resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left-aligned minimal header
            pw.Text(
              resume.personalInfo.fullName,
              style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF263238)),
            ),
            pw.Text(
              resume.field,
              style: pw.TextStyle(fontSize: 14, color: const PdfColor.fromInt(0xFF546E7A)),
            ),
            pw.SizedBox(height: 12),
            pw.Row(
              children: [
                pw.Text(resume.personalInfo.email, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                pw.SizedBox(width: 12),
                pw.Text(resume.personalInfo.phone, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                pw.SizedBox(width: 12),
                pw.Text(resume.personalInfo.location, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
              ],
            ),
            pw.SizedBox(height: 24),
            // Body Content
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: _buildStandardBodyContent(resume, const PdfColor.fromInt(0xFF263238), isMinimal: true),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TEMPLATE 4: CREATIVE / CHAPRI (Split Layout, Flashy)
  // ==========================================
  static pw.Page _buildCreativeTemplate(ResumeModel resume) {
    const primaryColor = PdfColor.fromInt(0xFF673AB7); // Deep Purple
    const accentColor = PdfColor.fromInt(0xFFFFC107); // Amber/Yellow
    
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left Sidebar
            pw.Container(
              width: 180,
              height: double.infinity,
              color: primaryColor,
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'CONTACT',
                    style: pw.TextStyle(color: accentColor, fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(resume.personalInfo.email, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                  pw.SizedBox(height: 4),
                  pw.Text(resume.personalInfo.phone, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                  pw.SizedBox(height: 4),
                  pw.Text(resume.personalInfo.location, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                  pw.SizedBox(height: 24),
                  
                  if (resume.skills.isNotEmpty) ...[
                    pw.Text(
                      'SKILLS',
                      style: pw.TextStyle(color: accentColor, fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5),
                    ),
                    pw.SizedBox(height: 12),
                    ...resume.skills.map((s) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 6),
                      child: pw.Row(
                        children: [
                          pw.Container(width: 4, height: 4, color: accentColor),
                          pw.SizedBox(width: 8),
                          pw.Text(s, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
            
            // Right Main Content
            pw.Expanded(
              child: pw.Container(
                color: const PdfColor.fromInt(0xFFFAFAFA),
                padding: const pw.EdgeInsets.all(32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      resume.personalInfo.fullName.toUpperCase(),
                      style: pw.TextStyle(color: primaryColor, fontSize: 32, fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      resume.field.toUpperCase(),
                      style: pw.TextStyle(color: accentColor, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 2),
                    ),
                    pw.SizedBox(height: 24),
                    
                    if (resume.summary.isNotEmpty) ...[
                      pw.Text(resume.summary, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800, lineSpacing: 1.5)),
                      pw.SizedBox(height: 24),
                    ],
                    
                    if (resume.experience.isNotEmpty) ...[
                      _buildCreativeSectionTitle('EXPERIENCE', primaryColor, accentColor),
                      ...resume.experience.map((e) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(e.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(e.company, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
                                if (e.startDate.isNotEmpty || e.endDate.isNotEmpty)
                                  pw.Container(
                                    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: pw.Text('${e.startDate}${e.startDate.isNotEmpty && e.endDate.isNotEmpty ? ' - ' : ''}${e.endDate}', style: pw.TextStyle(fontSize: 8, color: primaryColor, fontWeight: pw.FontWeight.bold)),
                                  ),
                              ],
                            ),
                            pw.SizedBox(height: 6),
                            ...e.responsibilities.map((r) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 2),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(margin: const pw.EdgeInsets.only(top: 3, right: 6, left: 2), width: 3, height: 3, decoration: const pw.BoxDecoration(color: accentColor, shape: pw.BoxShape.circle)),
                                  pw.Expanded(child: pw.Text(r.replaceAll(RegExp(r'^[\*\-•]\s*'), ''), style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      )),
                    ],
                    
                    if (resume.education.isNotEmpty) ...[
                      _buildCreativeSectionTitle('EDUCATION', primaryColor, accentColor),
                      ...resume.education.map((e) => pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 12),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(e.degree, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(e.school, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                                pw.Text('${e.startDate} - ${e.endDate}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _buildCreativeSectionTitle(String title, PdfColor primary, PdfColor accent) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Text(title, style: pw.TextStyle(color: primary, fontSize: 14, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
          pw.SizedBox(width: 8),
          pw.Expanded(child: pw.Container(height: 1, color: PdfColor(primary.red, primary.green, primary.blue, 0.2))),
          pw.Container(width: 30, height: 3, color: accent),
        ],
      ),
    );
  }

  // ==========================================
  // HELPER FOR STANDARD BODY CONTENT
  // ==========================================
  static List<pw.Widget> _buildStandardBodyContent(ResumeModel resume, PdfColor themeColor, {bool isClassic = false, bool isMinimal = false}) {
    pw.Widget sectionTitle(String title) {
      if (isClassic) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 12),
            pw.Center(child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5))),
            pw.SizedBox(height: 4),
            pw.Center(child: pw.Container(height: 1, width: 40, color: PdfColors.black)),
            pw.SizedBox(height: 12),
          ],
        );
      } else if (isMinimal) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 16),
            pw.Text(title.toUpperCase(), style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: themeColor, letterSpacing: 2)),
            pw.SizedBox(height: 12),
          ],
        );
      } else {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(color: themeColor, fontSize: 12, fontWeight: pw.FontWeight.bold, letterSpacing: 1.5)),
            pw.SizedBox(height: 4),
            pw.Container(height: 1, width: double.infinity, color: PdfColor(themeColor.red, themeColor.green, themeColor.blue, 0.2)),
            pw.SizedBox(height: 8),
          ],
        );
      }
    }

    return [
      if (resume.summary.isNotEmpty) 
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionTitle('SUMMARY'),
            pw.Text(resume.summary, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey900, lineSpacing: isMinimal ? 1.5 : 1.2)),
            pw.SizedBox(height: 16),
          ]
        ),

      if (resume.experience.isNotEmpty) 
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionTitle('EXPERIENCE'),
            ...resume.experience.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          isClassic ? '${e.role}, ${e.company}' : '${e.company} | ${e.role}',
                          style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: isMinimal ? themeColor : PdfColors.grey900),
                        ),
                      ),
                      pw.Text('${e.startDate} - ${e.endDate}', style: pw.TextStyle(fontSize: 9, color: isMinimal ? PdfColor(themeColor.red, themeColor.green, themeColor.blue, 0.6) : PdfColors.grey700)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  ...e.responsibilities.map((r) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2, left: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(margin: const pw.EdgeInsets.only(top: 4, right: 6, left: 2), width: 3, height: 3, decoration: const pw.BoxDecoration(color: PdfColors.black, shape: pw.BoxShape.circle)),
                        pw.Expanded(child: pw.Text(r.replaceAll(RegExp(r'^[\*\-•]\s*'), ''), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800))),
                      ],
                    ),
                  )),
                ],
              ),
            )),
            pw.SizedBox(height: 16),
          ]
        ),

      if (resume.education.isNotEmpty) 
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionTitle('EDUCATION'),
            ...resume.education.map((e) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        isClassic ? '${e.degree}, ${e.school}' : '${e.degree} - ${e.school}',
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: isMinimal ? themeColor : PdfColors.grey900),
                      ),
                      pw.Text('${e.startDate} - ${e.endDate}', style: pw.TextStyle(fontSize: 9, color: isMinimal ? PdfColor(themeColor.red, themeColor.green, themeColor.blue, 0.6) : PdfColors.grey700)),
                    ],
                  ),
                  if (e.description.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(e.description, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  ]
                ],
              ),
            )),
            pw.SizedBox(height: 16),
          ]
        ),

      if (resume.projects.isNotEmpty) 
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionTitle('PROJECTS'),
            ...resume.projects.map((p) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(p.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: isMinimal ? themeColor : PdfColors.grey900)),
                  pw.SizedBox(height: 2),
                  pw.Text(p.description, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800)),
                  pw.SizedBox(height: 2),
                  pw.Text('Tech: ${p.technologies}', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700)),
                ],
              ),
            )),
            pw.SizedBox(height: 16),
          ]
        ),

      if (resume.skills.isNotEmpty)
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            sectionTitle('SKILLS'),
            if (!isClassic && !isMinimal)
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: resume.skills.map((s) => pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: themeColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                  ),
                  child: pw.Text(s, style: const pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                )).toList(),
              )
            else
              pw.Text(resume.skills.join(' | '), style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey900, lineSpacing: 1.5)),
            pw.SizedBox(height: 16),
          ]
        ),
    ];
  }

  // ==========================================
  // EXPORT METHODS
  // ==========================================
  static Future<void> sharePdf(ResumeModel resume, {String? template}) async {
    try {
      final bytes = await generateResumePdf(resume, template: template);
      final filename = '${resume.personalInfo.fullName.replaceAll(' ', '_')}_Resume.pdf';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsBytes(bytes);
      
      await Share.shareXFiles([XFile(file.path)], text: 'Check out my resume!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to share resume: $e', backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    }
  }

  static Future<void> savePdfToDevice(ResumeModel resume, {String? template}) async {
    try {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar('Permission Denied', 'Storage permission is required to save the PDF.');
        return;
      }

      final bytes = await generateResumePdf(resume, template: template);
      final filename = '${resume.personalInfo.fullName.replaceAll(' ', '_')}_Resume.pdf';
      
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory != null) {
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes);
        Get.snackbar('Success', 'PDF saved to ${directory.path}', backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save PDF: $e', backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    }
  }

  static Future<void> saveImageToGallery(ResumeModel resume, {String? template}) async {
    try {
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
        if (!hasAccess) {
          Get.snackbar('Permission Denied', 'Storage permission is required to save the image.');
          return;
        }
      }

      Get.snackbar('Processing', 'Generating high-quality image...', backgroundColor: Colors.blue.withOpacity(0.8), colorText: Colors.white);

      final bytes = await generateResumePdf(resume, template: template);
      
      await for (var page in Printing.raster(bytes, pages: [0], dpi: 300)) {
        final imageBytes = await page.toPng();
        final directory = await getTemporaryDirectory();
        final filename = '${resume.personalInfo.fullName.replaceAll(' ', '_')}_Resume.png';
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(imageBytes);
        
        await Gal.putImage(file.path);
        
        Get.snackbar('Success', 'Resume saved to Gallery as image!', backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);
        break; 
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to save image: $e', backgroundColor: Colors.red.withOpacity(0.8), colorText: Colors.white);
    }
  }
  static pw.Widget _buildGridSectionTitle(String title) {
    if (title.isEmpty) return pw.SizedBox();
    final firstLetter = title.substring(0, 1).toUpperCase();
    final restOfTitle = title.substring(1).toUpperCase();

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12, top: 4),
      child: pw.Stack(
        alignment: pw.Alignment.centerLeft,
        children: [
          pw.Container(
            width: 24,
            height: 24,
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE0E0E0),
              shape: pw.BoxShape.circle,
            ),
          ),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(width: 6),
              pw.Text(
                firstLetter,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF424242),
                  letterSpacing: 2,
                ),
              ),
              pw.Text(
                restOfTitle,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF616161),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Page _buildGridTemplate(ResumeModel resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (pw.Context context) {
        return pw.Column(
          children: [
            // Header
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.only(bottom: 24, top: 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    resume.personalInfo.fullName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 6,
                      color: const PdfColor.fromInt(0xFF424242),
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Container(
                    width: 350, // Fixed width to control the span of the lines and dots
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        pw.Container(
                          width: 12, height: 12,
                          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF616161), shape: pw.BoxShape.circle),
                        ),
                        pw.Expanded(
                          child: pw.Container(
                            height: 1.5, color: const PdfColor.fromInt(0xFF616161),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 16),
                          child: pw.Text(
                            resume.field.toUpperCase(),
                            style: pw.TextStyle(
                              fontSize: 12,
                              letterSpacing: 3,
                              color: const PdfColor.fromInt(0xFF616161),
                            ),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Container(
                            height: 1.5, color: const PdfColor.fromInt(0xFF616161),
                          ),
                        ),
                        pw.Container(
                          width: 12, height: 12,
                          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF616161), shape: pw.BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Top Divider
            pw.Container(height: 1, color: const PdfColor.fromInt(0xFF9E9E9E), width: double.infinity, margin: const pw.EdgeInsets.only(bottom: 24)),

            // Body Columns
            pw.Expanded(
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Column (35%)
                  pw.Expanded(
                    flex: 35,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.only(right: 16),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _buildGridSectionTitle('CONTACT'),
                          pw.SizedBox(height: 4),
                          if (resume.personalInfo.phone.isNotEmpty)
                            pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text(resume.personalInfo.phone, style: const pw.TextStyle(fontSize: 10))),
                          if (resume.personalInfo.email.isNotEmpty)
                            pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text(resume.personalInfo.email, style: const pw.TextStyle(fontSize: 10))),
                          if (resume.personalInfo.location.isNotEmpty)
                            pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text(resume.personalInfo.location, style: const pw.TextStyle(fontSize: 10))),
                          if (resume.personalInfo.linkedIn.isNotEmpty)
                            pw.Padding(padding: const pw.EdgeInsets.only(bottom: 6), child: pw.Text(resume.personalInfo.linkedIn, style: const pw.TextStyle(fontSize: 10))),

                          pw.SizedBox(height: 16),
                          pw.Container(height: 1, color: const PdfColor.fromInt(0xFFE0E0E0), width: double.infinity),
                          pw.SizedBox(height: 16),

                          if (resume.education.isNotEmpty) ...[
                            _buildGridSectionTitle('EDUCATION'),
                            pw.SizedBox(height: 4),
                            ...resume.education.map((edu) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 12),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('${edu.startDate} - ${edu.endDate}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF616161))),
                                  pw.SizedBox(height: 8),
                                  pw.Text(edu.school.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 4),
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 4, height: 4,
                                        margin: const pw.EdgeInsets.only(top: 3, right: 6, left: 4),
                                        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF757575), shape: pw.BoxShape.circle),
                                      ),
                                      pw.Expanded(child: pw.Text(edu.degree, style: const pw.TextStyle(fontSize: 10))),
                                    ],
                                  ),
                                  if (edu.description.isNotEmpty)
                                    pw.Row(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Container(
                                          width: 4, height: 4,
                                          margin: const pw.EdgeInsets.only(top: 3, right: 6, left: 4),
                                          decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF757575), shape: pw.BoxShape.circle),
                                        ),
                                        pw.Expanded(child: pw.Text(edu.description, style: const pw.TextStyle(fontSize: 10))),
                                      ],
                                    ),
                                ],
                              ),
                            )),
                            pw.SizedBox(height: 4),
                            pw.Container(height: 1, color: const PdfColor.fromInt(0xFFE0E0E0), width: double.infinity),
                            pw.SizedBox(height: 16),
                          ],

                          if (resume.skills.isNotEmpty) ...[
                            _buildGridSectionTitle('SKILLS'),
                            pw.SizedBox(height: 4),
                            ...resume.skills.map((skill) => pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 4, height: 4,
                                  margin: const pw.EdgeInsets.only(top: 3, right: 8, left: 4),
                                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF757575), shape: pw.BoxShape.circle),
                                ),
                                pw.Expanded(child: pw.Text(skill.toUpperCase(), style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF616161)))),
                              ]
                            )),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Vertical Divider
                  pw.Container(width: 1, color: const PdfColor.fromInt(0xFF9E9E9E), height: double.infinity),

                  // Right Column (65%)
                  pw.Expanded(
                    flex: 65,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.only(left: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (resume.summary.isNotEmpty) ...[
                            _buildGridSectionTitle('PROFILE SUMMARY'),
                            pw.Text(
                              resume.summary,
                              style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5, color: PdfColor.fromInt(0xFF424242)),
                            ),
                            pw.SizedBox(height: 16),
                            pw.Container(height: 1, color: const PdfColor.fromInt(0xFFE0E0E0), width: double.infinity),
                            pw.SizedBox(height: 16),
                          ],

                          if (resume.experience.isNotEmpty) ...[
                            _buildGridSectionTitle('WORK EXPERIENCE'),
                            pw.SizedBox(height: 4),
                            ...resume.experience.map((exp) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 16),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                    children: [
                                      pw.Text(exp.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF424242))),
                                      pw.Text('${exp.startDate} - ${exp.endDate}', style: pw.TextStyle(fontSize: 10, color: const PdfColor.fromInt(0xFF616161))),
                                    ],
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Text(exp.company, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF616161))),
                                  pw.SizedBox(height: 6),
                                  ...exp.responsibilities.map((resp) => pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 4, height: 4,
                                        margin: const pw.EdgeInsets.only(top: 4, right: 8, left: 4),
                                        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF757575), shape: pw.BoxShape.circle),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(resp, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.2, color: PdfColor.fromInt(0xFF424242))),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            )),
                            pw.SizedBox(height: 4),
                            pw.Container(height: 1, color: const PdfColor.fromInt(0xFFE0E0E0), width: double.infinity),
                            pw.SizedBox(height: 16),
                          ],

                          if (resume.projects.isNotEmpty) ...[
                            _buildGridSectionTitle('PROJECTS'),
                            pw.SizedBox(height: 4),
                            ...resume.projects.map((proj) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 12),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(proj.name, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF424242))),
                                  pw.SizedBox(height: 4),
                                  pw.Row(
                                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Container(
                                        width: 4, height: 4,
                                        margin: const pw.EdgeInsets.only(top: 4, right: 8, left: 4),
                                        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF757575), shape: pw.BoxShape.circle),
                                      ),
                                      pw.Expanded(
                                        child: pw.Text(proj.description, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.2, color: PdfColor.fromInt(0xFF424242))),
                                      ),
                                    ],
                                  ),
                                  if (proj.technologies.isNotEmpty)
                                    pw.Padding(
                                      padding: const pw.EdgeInsets.only(left: 16, top: 2),
                                      child: pw.Text('Tech: ${proj.technologies}', style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic, color: const PdfColor.fromInt(0xFF616161))),
                                    ),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static pw.Widget _buildExecutiveSectionTitle(String title, {bool isDark = false}) {
    if (title.isEmpty) return pw.SizedBox();
    final textColor = isDark ? PdfColors.white : const PdfColor.fromInt(0xFF212121);
    final lineColor = isDark ? PdfColors.white : const PdfColor.fromInt(0xFF212121);

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12, top: 4),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: textColor,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Container(
            height: 2,
            width: 30,
            color: lineColor,
          ),
        ],
      ),
    );
  }

  static Uint8List? _safeBase64Decode(String base64Str) {
    try {
      if (base64Str.isEmpty) return null;
      final cleanStr = base64Str.contains(',') ? base64Str.split(',').last : base64Str;
      return base64Decode(cleanStr);
    } catch (e) {
      debugPrint('Error decoding base64 image: $e');
      return null;
    }
  }

  static pw.Page _buildExecutiveTemplate(ResumeModel resume) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (pw.Context context) {
        final imageBytes = _safeBase64Decode(resume.personalInfo.photoBase64);
        
        return pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left Sidebar (30%)
            pw.Expanded(
              flex: 30,
              child: pw.Container(
                color: const PdfColor.fromInt(0xFF28353E), // Dark Slate
                padding: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                height: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Profile Picture or Initials Circle
                    pw.Center(
                      child: imageBytes != null
                          ? pw.Container(
                              width: 80,
                              height: 80,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                image: pw.DecorationImage(
                                  image: pw.MemoryImage(imageBytes),
                                  fit: pw.BoxFit.cover,
                                ),
                              ),
                            )
                          : pw.Container(
                              width: 80,
                              height: 80,
                              decoration: const pw.BoxDecoration(
                                color: PdfColor.fromInt(0xFF78909C),
                                shape: pw.BoxShape.circle,
                              ),
                              alignment: pw.Alignment.center,
                              child: pw.Text(
                                resume.personalInfo.fullName.isNotEmpty ? resume.personalInfo.fullName[0].toUpperCase() : '?',
                                style: pw.TextStyle(color: PdfColors.white, fontSize: 32, fontWeight: pw.FontWeight.bold),
                              ),
                            ),
                    ),
                    pw.SizedBox(height: 32),

                    _buildExecutiveSectionTitle('Contact', isDark: true),
                    if (resume.personalInfo.location.isNotEmpty) ...[
                      pw.Text('Address', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(resume.personalInfo.location, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      pw.SizedBox(height: 12),
                    ],
                    if (resume.personalInfo.phone.isNotEmpty) ...[
                      pw.Text('Phone', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(resume.personalInfo.phone, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      pw.SizedBox(height: 12),
                    ],
                    if (resume.personalInfo.email.isNotEmpty) ...[
                      pw.Text('Email', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(resume.personalInfo.email, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      pw.SizedBox(height: 12),
                    ],
                    if (resume.personalInfo.linkedIn.isNotEmpty) ...[
                      pw.Text('LinkedIn', style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text(resume.personalInfo.linkedIn, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10)),
                      pw.SizedBox(height: 12),
                    ],

                    pw.SizedBox(height: 16),
                    if (resume.skills.isNotEmpty) ...[
                      _buildExecutiveSectionTitle('Skills', isDark: true),
                      ...resume.skills.map((skill) => pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Container(
                            width: 4, height: 4,
                            margin: const pw.EdgeInsets.only(right: 8),
                            decoration: const pw.BoxDecoration(color: PdfColors.white, shape: pw.BoxShape.circle),
                          ),
                          pw.Expanded(child: pw.Text(skill, style: const pw.TextStyle(color: PdfColors.white, fontSize: 10))),
                        ]
                      )),
                    ],
                  ],
                ),
              ),
            ),

            // Right Main Body (70%)
            pw.Expanded(
              flex: 70,
              child: pw.Container(
                color: PdfColors.white,
                padding: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Header
                    pw.Text(
                      resume.personalInfo.fullName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 32,
                        fontWeight: pw.FontWeight.bold,
                        color: const PdfColor.fromInt(0xFF212121),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      resume.field,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: const PdfColor.fromInt(0xFF424242),
                      ),
                    ),
                    pw.SizedBox(height: 32),

                    if (resume.summary.isNotEmpty) ...[
                      _buildExecutiveSectionTitle('Profile'),
                      pw.Text(
                        resume.summary,
                        style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.5, color: PdfColor.fromInt(0xFF212121)),
                      ),
                      pw.SizedBox(height: 24),
                    ],

                    if (resume.experience.isNotEmpty) ...[
                      _buildExecutiveSectionTitle('Work Experience'),
                      ...resume.experience.map((exp) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 16),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(exp.role, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF212121))),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(exp.company, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF424242))),
                                pw.Text('${exp.startDate} - ${exp.endDate}', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF424242))),
                              ],
                            ),
                            pw.SizedBox(height: 8),
                            ...exp.responsibilities.map((resp) => pw.Row(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 3, height: 3,
                                  margin: const pw.EdgeInsets.only(top: 4, right: 8, left: 4),
                                  decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF424242), shape: pw.BoxShape.circle),
                                ),
                                pw.Expanded(
                                  child: pw.Text(resp, style: const pw.TextStyle(fontSize: 10, lineSpacing: 1.2, color: PdfColor.fromInt(0xFF212121))),
                                ),
                              ],
                            )),
                          ],
                        ),
                      )),
                      pw.SizedBox(height: 8),
                    ],

                    if (resume.education.isNotEmpty) ...[
                      _buildExecutiveSectionTitle('Education'),
                      ...resume.education.map((edu) => pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 12),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(edu.degree, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF212121))),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(edu.school, style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF424242))),
                                pw.Text('${edu.startDate} - ${edu.endDate}', style: const pw.TextStyle(fontSize: 10, color: PdfColor.fromInt(0xFF424242))),
                              ],
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
