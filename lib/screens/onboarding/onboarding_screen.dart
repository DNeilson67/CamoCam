import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/onboarding_data.dart';
import 'widgets/onboarding_slide_widget.dart';
import 'widgets/page_indicator.dart';
import 'widgets/onboarding_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final List<OnboardingSlide> _slides = OnboardingData.slides;

  void _onNextPressed() {
    if (_currentIndex < _slides.length - 1) {
      _carouselController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Handle Google Sign-In or navigate to home
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      debugPrint('Login with Google pressed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Carousel Slides
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _carouselController,
                itemCount: _slides.length,
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                itemBuilder: (context, index, realIndex) {
                  return OnboardingSlideWidget(slide: _slides[index]);
                },
              ),
            ),

            // Bottom Section (Page Indicator + Button)
            Padding(
              padding: EdgeInsets.only(
                left: AppDimensions.buttonHorizontalPadding,
                right: AppDimensions.buttonHorizontalPadding,
                bottom: MediaQuery.of(context).padding.bottom + 40,
              ),
              child: Column(
                children: [
                  // Page Indicator
                  PageIndicator(
                    currentIndex: _currentIndex,
                    totalPages: _slides.length,
                  ),

                  const SizedBox(height: AppDimensions.indicatorToButton),

                  // Action Button
                  OnboardingButton(
                    isLastSlide: _slides[_currentIndex].isLastSlide,
                    onPressed: _onNextPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
