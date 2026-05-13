class OnboardingSlide {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastSlide;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLastSlide = false,
  });
}

class OnboardingData {
  static List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'Adaptive Camouflage,\nPowered by AI',
      description:
          'Generate unique camouflage patterns that seamlessly blend into any environment.',
      imagePath: 'assets/images/create_camouflage.png',
    ),
    OnboardingSlide(
      title: 'See It Instantly\nin AR',
      description:
          'Use your camera to preview camouflage directly on clothing, gear, or 3D models in real time.',
      imagePath: 'assets/images/onboarding_2.png',
    ),
    OnboardingSlide(
      title: 'Have fun with your\nsaved Camo photos',
      description:
          'Don\'t forget to save your favorite moments with your camo objects',
      imagePath: 'assets/images/onboarding_3.png',
      isLastSlide: true,
    ),
  ];
}

