import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../screens/main_layout.dart';
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

  // ---------------- NEXT BUTTON ----------------
  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: AppDimensions.buttonHeight,
      decoration: BoxDecoration(
        color: AppColors.primaryButton,
        borderRadius:
            BorderRadius.circular(AppDimensions.buttonBorderRadius),
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
          borderRadius:
              BorderRadius.circular(AppDimensions.buttonBorderRadius),
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Text(
                'Next',
                style:
                    AppTextStyles.button.copyWith(color: AppColors.white),
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
        borderRadius:
            BorderRadius.circular(AppDimensions.buttonBorderRadius),
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
          borderRadius:
              BorderRadius.circular(AppDimensions.buttonBorderRadius),
          onTap: () async {
            try {
              await AuthService().signInWithGoogle();

              // Wait briefly for session to update
              await Future.delayed(const Duration(seconds: 2));

              final user = AuthService().currentUser;

              if (user != null) {
                debugPrint("User ID: ${user.id}");
                debugPrint("Email: ${user.email}");

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainLayout(),
                  ),
                );
              }
            } catch (e) {
              debugPrint("Google login error: $e");

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Google sign-in failed"),
                ),
              );
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.login, size: 18),
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