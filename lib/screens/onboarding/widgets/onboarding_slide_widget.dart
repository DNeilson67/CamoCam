import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/onboarding_data.dart';

class OnboardingSlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const OnboardingSlideWidget({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.horizontalPadding,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.title,
          ),

          const SizedBox(height: AppDimensions.verticalSpacing),

          // Illustration (local image)
          SizedBox(
            height: AppDimensions.illustrationHeight,
            child: Image.asset(
              slide.imagePath,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: AppDimensions.verticalSpacing),

          // Description
          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.description,
          ),
        ],
      ),
    );
  }
}
