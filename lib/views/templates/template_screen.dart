import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/custom_button.dart';
import '../../controllers/resume_controller.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  int _selectedTemplateIndex = 0;

  final List<Map<String, dynamic>> _templates = [
    {
      'name': 'Classic',
      'headerColor': AppColors.surfaceHigh,
    },
    {
      'name': 'Modern',
      'headerColor': AppColors.primary,
    },
    {
      'name': 'Minimal',
      'headerColor': Colors.transparent,
      'accent': AppColors.primary,
    },
    {
      'name': 'Creative',
      'headerColor': AppColors.primarySoft,
      'isSplit': true,
    },
    {
      'name': 'Grid',
      'headerColor': Colors.transparent,
      'isGrid': true,
    },
    {
      'name': 'Executive',
      'headerColor': const Color(0xFF28353E),
      'isExecutive': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Choose Template',
          style: AppTextStyles.title,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Text(
              'Pick a design that suits your style',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(24.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                return _buildTemplateCard(index, _templates[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.borderGlass)),
            ),
            child: CustomButton(
              text: 'Use This Template',
              onPressed: () {
                final String templateName = _templates[_selectedTemplateIndex]['name'];
                Get.find<ResumeController>().selectedTemplate.value = templateName;
                Get.offNamed('/ai_input');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(int index, Map<String, dynamic> template) {
    final isSelected = _selectedTemplateIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTemplateIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: isSelected ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildMiniPreview(template),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySoft : AppColors.surfaceHigh,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    template['name'],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.textWhite,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 16,
                    color: AppColors.background,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPreview(Map<String, dynamic> template) {
    final String name = template['name'];

    Widget drawLine(double height, double width, {Color color = const Color(0xFFBDBDBD)}) { // grey[400]
      return Container(height: height, width: width, color: color);
    }

    Widget content;
    switch (name) {
      case 'Modern':
        content = Column(
          children: [
            Container(
              height: 30,
              padding: const EdgeInsets.all(4),
              color: AppColors.primary,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  drawLine(4, 40, color: Colors.white),
                  const SizedBox(height: 2),
                  drawLine(2, 60, color: Colors.white70),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    drawLine(3, 30, color: AppColors.primary),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                    const SizedBox(height: 6),
                    drawLine(3, 40, color: AppColors.primary),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                  ],
                ),
              ),
            ),
          ],
        );
        break;

      case 'Creative':
        content = Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: AppColors.primarySoft,
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    drawLine(3, double.infinity, color: AppColors.primary),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity, color: const Color(0xFF757575)),
                    const SizedBox(height: 8),
                    drawLine(3, double.infinity, color: AppColors.primary),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity, color: const Color(0xFF757575)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    drawLine(6, 60, color: const Color(0xFF424242)),
                    const SizedBox(height: 2),
                    drawLine(2, 80),
                    const SizedBox(height: 8),
                    drawLine(4, 30),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                    const SizedBox(height: 8),
                    drawLine(4, 40),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                  ],
                ),
              ),
            ),
          ],
        );
        break;

      case 'Classic':
        content = Column(
          children: [
            Container(
              height: 30,
              color: Colors.white,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  drawLine(4, 50, color: const Color(0xFF424242)),
                  const SizedBox(height: 2),
                  drawLine(2, 80),
                  const SizedBox(height: 2),
                  drawLine(1, double.infinity),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    drawLine(3, 40),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                    const SizedBox(height: 6),
                    drawLine(3, 30),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                  ],
                ),
              ),
            ),
          ],
        );
        break;

      case 'Minimal':
        content = Row(
          children: [
            Container(width: 4, color: AppColors.primary),
            Expanded(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    drawLine(6, 50, color: const Color(0xFF424242)),
                    const SizedBox(height: 4),
                    drawLine(2, 80),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: drawLine(3, 30)),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              drawLine(2, double.infinity),
                              const SizedBox(height: 2),
                              drawLine(2, double.infinity),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
        break;

      case 'Grid':
        content = Column(
          children: [
            Container(
              height: 30,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  drawLine(4, 60, color: const Color(0xFF424242)),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFF424242), shape: BoxShape.circle)),
                      drawLine(1, 40),
                      Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFF424242), shape: BoxShape.circle)),
                    ],
                  ),
                ],
              ),
            ),
            drawLine(1, double.infinity),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 35,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle)), const SizedBox(width: 2), drawLine(3, 20)]),
                          const SizedBox(height: 2), drawLine(1, 20),
                          const SizedBox(height: 6),
                          drawLine(1, double.infinity),
                          const SizedBox(height: 2),
                          Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle)), const SizedBox(width: 2), drawLine(3, 20)]),
                          const SizedBox(height: 2), drawLine(1, 20),
                        ],
                      ),
                    ),
                  ),
                  Container(width: 1, color: const Color(0xFFBDBDBD)),
                  Expanded(
                    flex: 65,
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle)), const SizedBox(width: 2), drawLine(3, 30)]),
                          const SizedBox(height: 2), drawLine(1, double.infinity), drawLine(1, double.infinity),
                          const SizedBox(height: 6),
                          drawLine(1, double.infinity),
                          const SizedBox(height: 2),
                          Row(children: [Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFE0E0E0), shape: BoxShape.circle)), const SizedBox(width: 2), drawLine(3, 30)]),
                          const SizedBox(height: 2), drawLine(1, double.infinity), drawLine(1, double.infinity),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
        break;

      case 'Executive':
        content = Row(
          children: [
            Expanded(
              flex: 30,
              child: Container(
                color: const Color(0xFF28353E), // Dark slate
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    Container(width: 16, height: 16, decoration: const BoxDecoration(color: Color(0xFF78909C), shape: BoxShape.circle)),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        drawLine(3, 20, color: Colors.white),
                        const SizedBox(height: 2),
                        drawLine(1, 10, color: Colors.white),
                        const SizedBox(height: 4),
                        drawLine(2, double.infinity, color: Colors.white70),
                        const SizedBox(height: 8),
                        drawLine(3, 20, color: Colors.white),
                        const SizedBox(height: 2),
                        drawLine(1, 10, color: Colors.white),
                        const SizedBox(height: 4),
                        drawLine(2, double.infinity, color: Colors.white70),
                      ]
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 70,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    drawLine(6, 60, color: const Color(0xFF424242)),
                    const SizedBox(height: 2),
                    drawLine(3, 40, color: const Color(0xFF757575)),
                    const SizedBox(height: 12),
                    
                    drawLine(4, 30, color: const Color(0xFF424242)),
                    const SizedBox(height: 2),
                    drawLine(1, 15, color: const Color(0xFF424242)),
                    const SizedBox(height: 4),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                    
                    const SizedBox(height: 8),
                    drawLine(4, 40, color: const Color(0xFF424242)),
                    const SizedBox(height: 2),
                    drawLine(1, 20, color: const Color(0xFF424242)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        drawLine(3, 30),
                        drawLine(2, 20),
                      ],
                    ),
                    const SizedBox(height: 2),
                    drawLine(2, double.infinity),
                    drawLine(2, double.infinity),
                  ],
                ),
              ),
            ),
          ],
        );
        break;
        
      default:
        content = Container(color: Colors.white);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: content,
      ),
    );
  }
}
