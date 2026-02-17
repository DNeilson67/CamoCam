import 'package:camocam/screens/main_layout.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../home/home_screen.dart';
import '../../../services/auth/auth_services.dart';

class OnboardingButton extends StatelessWidget {
  final bool isLastSlide;
  final VoidCallback onPressed;

  const OnboardingButton({
    super.key,
    required this.isLastSlide,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isLastSlide) {
      return _buildGoogleButton(context);
    }
    return _buildNextButton();
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.primaryButton,
        borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                'Next',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
          final userCredential = await AuthService.signInWithGoogle();

          if (userCredential != null) {
            final user = userCredential.user;

            debugPrint("UID: ${user?.uid}");
            debugPrint("Email: ${user?.email}");
            debugPrint("Name: ${user?.displayName}");

            final idToken = await user?.getIdToken();
            debugPrint("Firebase ID Token: $idToken");

            // Navigate after success
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainLayout()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Google sign-in failed")),
            );
          }
        },

          borderRadius: BorderRadius.circular(AppDimensions.buttonBorderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  'https://www.figma.com/api/mcp/asset/f243668d-3132-4c0f-8c4b-f881fc1e69cd',
                  width: 18,
                  height: 18,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.login, size: 18);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Login with Google',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textOnButton,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
