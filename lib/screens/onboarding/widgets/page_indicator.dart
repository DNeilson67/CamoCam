import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const PageIndicator({
    super.key,
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.indicatorPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          AppDimensions.indicatorBorderRadius,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalPages, (index) {
          final isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(
              horizontal: AppDimensions.indicatorDotGap / 2,
            ),
            width: isActive
                ? AppDimensions.activeDotSize
                : AppDimensions.inactiveDotSize,
            height: isActive
                ? AppDimensions.activeDotSize
                : AppDimensions.inactiveDotSize,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.indicatorActive
                  : AppColors.indicatorInactive,
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}
