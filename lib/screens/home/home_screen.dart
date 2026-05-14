import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../pattern_generator/pattern_generator_landing_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../ar/ar_choose_model_screen.dart';
class HomeScreenContent extends StatelessWidget {
  final VoidCallback? onNavigateToPatternGenerator;
  final Function(int)? onNavigateToTab;
  const HomeScreenContent({
    super.key,
    this.onNavigateToPatternGenerator,
    this.onNavigateToTab,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header with profile
              _buildHeader(),

              const SizedBox(height: 29),

              // Explore Section
              _buildExploreSection(),

              const SizedBox(height: 14),

              // Main Content Cards
              _buildContentCards(context),

              const SizedBox(height: 100), // Extra space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

    Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;

    final displayName = user?.userMetadata?['full_name'] ?? "User";
    final photoUrl = user?.userMetadata?['avatar_url'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0E0E0),
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(Icons.person, color: Colors.grey)
                : null,
          ),

          const SizedBox(width: 11),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: AppTextStyles.description.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF727272),
                  height: 1.44,
                ),
              ),
              Text(
                displayName,
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF090814),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildExploreSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: AppTextStyles.title.copyWith(color: const Color(0xFF090814)),
          ),
          const SizedBox(height: 6),
          Text(
            'Innovate your style with CamoCam',
            style: AppTextStyles.description.copyWith(
              color: const Color(0xFF727272),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildContentCards(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        _buildLargeCard(context),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSmallCard(
                  title: 'AR Mode',
                  subtitle: 'See your camouflaged object live',
                  icon: Image.asset(
                    'assets/images/AR_mode.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                  onTap: () => onNavigateToTab?.call(1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSmallCard(
                  title: 'Saved Models',
                  subtitle: 'Open your applied 3D camo models',
                  icon: const Icon(
                    Icons.bookmark_outline,
                    size: 64,
                    color: Color(0xFF4A7C59),
                  ),
                  onTap: () => onNavigateToTab?.call(2),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildLargeCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D5B9), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: Image.asset(
              'assets/images/Camouflage_generator.png',
              height: 265,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

          ),

          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Camouflage Generator',
              style: AppTextStyles.title.copyWith(
                fontSize: 20,
                color: const Color(0xFF090814),
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your unique camo, instantly generated',
              style: AppTextStyles.description.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.43,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Make your own camouflage pattern by capturing background images',
              style: AppTextStyles.description.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.43,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (onNavigateToPatternGenerator != null) {
                    onNavigateToPatternGenerator!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PatternGeneratorLandingScreen(),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                label: Text(
                  'Generate Camouflage',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
Widget _buildSmallCard({
  required String title,
  required String subtitle,
  required Widget icon,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D5B9), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 72, height: 72, child: Center(child: icon)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontSize: 20,
                color: const Color(0xFF090814),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.description.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}

// Original HomeScreen with navbar (kept for compatibility)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<IconData> _iconList = [
    Icons.home,
    Icons.view_in_ar_outlined,
    Icons.person_outline,
  ];

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home - already here
        break;
      case 1: // AR
        break;
      case 2: // Profile
        break;
    }
  }

  void _onFABTapped() {
    // Navigate to Pattern Generator screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PatternGeneratorLandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header with profile
              _buildHeader(),

              const SizedBox(height: 29),

              // Explore Section
              _buildExploreSection(),

              const SizedBox(height: 14),

              // Main Content Cards
              _buildContentCards(context),

              const SizedBox(height: 100), // Extra space for bottom nav
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onFABTapped,
        backgroundColor: const Color(0xFF4A7C59),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.auto_awesome, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _iconList,
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: _onNavItemTapped,
        activeColor: const Color(0xFF4A7C59),
        inactiveColor: const Color(0xFF1A1A1A),
        backgroundColor: Colors.white,
        splashColor: const Color(0xFF4A7C59).withOpacity(0.1),
        splashSpeedInMilliseconds: 300,
        notchAndCornersAnimation: null,
        iconSize: 24,
        height: 60,
        elevation: 8,
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          // Profile Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE0E0E0),
            child: CachedNetworkImage(
              imageUrl:
                  'https://www.figma.com/api/mcp/asset/1d26b182-8a61-458e-8111-30e4394913b2',
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) =>
                  const Icon(Icons.person, color: Colors.grey),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.person, color: Colors.grey),
            ),
          ),

          const SizedBox(width: 11),

          // Welcome Text
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: AppTextStyles.description.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF727272),
                  height: 1.44,
                ),
              ),
              Text(
                'Davin Neilson',
                style: AppTextStyles.title.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF090814),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Explore',
            style: AppTextStyles.title.copyWith(color: const Color(0xFF090814)),
          ),
          const SizedBox(height: 6),
          Text(
            'Innovate your style with CamoCam',
            style: AppTextStyles.description.copyWith(
              color: const Color(0xFF727272),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
Widget _buildContentCards(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Column(
      children: [
        _buildLargeCard(),
        const SizedBox(height: 16),
        _buildSmallCard(
          title: 'AR Mode',
          subtitle: 'See your camouflaged object live',
          iconPath: 'https://www.figma.com/api/mcp/asset/a833e348-e030-4f6b-b801-5be74f47bc9b',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArChooseModelScreen()),
            );
          },
        ),
      ],
    ),
  );
}

  Widget _buildLargeCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D5B9), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: CachedNetworkImage(
              imageUrl:
                  'https://www.figma.com/api/mcp/asset/689ef520-7764-4936-924b-c0afe4a53c2f',
              height: 265,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 265,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 265,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 80),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Camouflage Generator',
              style: AppTextStyles.title.copyWith(
                fontSize: 20,
                color: const Color(0xFF090814),
                height: 1.2,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Your unique camo, instantly generated',
              style: AppTextStyles.description.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.43,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Make your own camouflage pattern by capturing background images',
              style: AppTextStyles.description.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.43,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatternGeneratorLandingScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
                label: Text(
                  'Generate Camouflage',
                  style: AppTextStyles.button.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
Widget _buildSmallCard({
  required String title,
  required String subtitle,
  required String iconPath,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC8D5B9), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 72,
              height: 72,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontSize: 20,
                color: const Color(0xFF090814),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.description.copyWith(
                fontSize: 14,
                color: const Color(0xFF666666),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
