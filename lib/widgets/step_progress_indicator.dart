import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class StepProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final List<String> stepLabels;

  const StepProgressIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(totalSteps * 2 - 1, (index) {
            if (index.isEven) {
              int stepIndex = index ~/ 2;
              return _buildStepCircle(stepIndex);
            } else {
              int lineIndex = index ~/ 2;
              return _buildConnectingLine(lineIndex);
            }
          }),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            return SizedBox(
              width: 50,
              child: Text(
                stepLabels.length > index ? stepLabels[index] : '',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 9,
                  color: currentStep >= index ? AppColors.textWhite : AppColors.textMuted,
                  fontWeight: currentStep == index ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int index) {
    bool isCompleted = index < currentStep;
    bool isActive = index == currentStep;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isCompleted || isActive ? AppColors.primary : AppColors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted || isActive ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                size: 14,
                color: AppColors.background,
              )
            : Text(
                '${index + 1}',
                style: AppTextStyles.label.copyWith(
                  color: isActive ? AppColors.background : AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
      ),
    );
  }

  Widget _buildConnectingLine(int index) {
    bool isCompleted = index < currentStep;

    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
