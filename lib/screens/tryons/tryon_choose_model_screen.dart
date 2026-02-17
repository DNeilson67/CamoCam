import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'tryon_choose_pattern_screen.dart';

class TryonChooseModelScreen extends StatefulWidget {
  const TryonChooseModelScreen({super.key});

  @override
  State<TryonChooseModelScreen> createState() => _TryonChooseModelScreenState();
}

class _TryonChooseModelScreenState extends State<TryonChooseModelScreen> {
  int currentIndex = 0;

  final List<Map<String, String>> models = [
    {'name': 'Hoodies', 'image': 'assets/images/hoodie.png'},
    {'name': 'T-Shirt', 'image': 'assets/images/tshirt.png'},
    {'name': 'Jacket', 'image': 'assets/images/jacket.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        elevation: 0,
        title: Text(
          'Virtual-TryOn',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final carouselHeight = (constraints.maxHeight * 0.5).clamp(300.0, 425.0);
            return Column(
              children: [
                const SizedBox(height: 32),
                Text(
                  'Choose Your Outfit',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Select the clothing item you\'d like to try on with camouflage patterns',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: const Color(0xFF797777),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: CarouselSlider.builder(
                    itemCount: models.length,
                    itemBuilder: (context, index, realIndex) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: carouselHeight,
                            maxWidth: constraints.maxWidth * 0.7,
                          ),
                          child: AspectRatio(
                            aspectRatio: 299 / 425,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  models[index]['image']!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      Icons.checkroom,
                                      size: 100,
                                      color: Colors.grey[400],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      height: carouselHeight,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                ),
              ),

                // Indicator dots
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    models.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentIndex == index
                            ? const Color(0xFF4A7C59)
                            : const Color(0xFFD9D9D9),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  models[currentIndex]['name']!,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 43),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TryonChoosePatternScreen(
                              selectedModel: models[currentIndex]['name']!,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF68B0AB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Apply',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
