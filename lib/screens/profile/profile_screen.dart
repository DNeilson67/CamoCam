import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../onboarding/onboarding_screen.dart';
import 'saved_models_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Sample saved model images
  final List<String> savedModelImages = const [
    'assets/images/pattern_1.jpg',
    'assets/images/pattern_2.png',
    'assets/images/pattern_3.png',
    'assets/images/pattern_4.png',
    'assets/images/pattern_5.png',
    'assets/images/pattern_6.png',
    'assets/images/pattern_1.jpg',
    'assets/images/pattern_2.png',
    'assets/images/pattern_3.png',
  ];

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    final displayName = user?.userMetadata?['full_name'] ?? 'User';
    final email = user?.email ?? 'No email';
    final photoUrl = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 84),
          child: Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Title
                Text(
                  'Profile',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF292929),
                  ),
                ),

                const SizedBox(height: 16),

                // User Info Card
                Container(
                  width: double.infinity,
                  height: 89,
                  decoration: BoxDecoration(
                    color: const Color(0xFF68B0AB),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 44,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Profile Avatar
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          backgroundImage: photoUrl != null
                              ? NetworkImage(photoUrl)
                              : null,
                          child: photoUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 32,
                                  color: Color(0xFF68B0AB),
                                )
                              : null,
                        ),

                        const SizedBox(width: 11),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Your Saved Models Section Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Saved Models',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF111827),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SavedModelsScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF4A7C59),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Saved Models Grid
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          savedModelImages[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Log Out',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to log out?',
                            style: GoogleFonts.montserrat(),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFF797777),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                // 🔥 Proper logout from Supabase
                                await Supabase.instance.client.auth.signOut();

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const OnboardingScreen(),
                                  ),
                                  (route) => false,
                                );
                              },
                              child: Text(
                                'Log Out',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFFCF3017),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFCF3017),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: Color(0xFFFFE9E5),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFE9E5),
                          ),
                        ),
                      ],
                    ),
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