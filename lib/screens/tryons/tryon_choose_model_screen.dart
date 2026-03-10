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
  int _currentIndex = 0;

  final List<OutfitItem> _outfits = [
    OutfitItem(name: 'Hoodie', imagePath: 'assets/images/hoodie.png'),
    OutfitItem(name: 'T-Shirt', imagePath: 'assets/images/tshirt.png'),
    OutfitItem(name: 'Jacket', imagePath: 'assets/images/jacket.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        title: Text(
          'Virtual Try-On',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 84),
          child: Column(
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
              Text(
                'Select the clothing item you want to\ncamouflage and try on',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF797777),
                ),
              ),
              const SizedBox(height: 48),

              // Outfit carousel
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: _outfits.length,
                  itemBuilder: (context, index, realIndex) {
                    return Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        child: Image.asset(
                          _outfits[index].imagePath,
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
                    );
                  },
                  options: CarouselOptions(
                    height: 300,
                    viewportFraction: 0.8,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
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
                  _outfits.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? const Color(0xFF4A7C59)
                          : const Color(0xFFD9D9D9),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                _outfits[_currentIndex].name,
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    // Preview Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    _outfits[_currentIndex].imagePath,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF4A7C59),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Preview',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4A7C59),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Next Button
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TryonChoosePatternScreen(
                                  selectedModel: _outfits[_currentIndex].name,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF68B0AB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Next',
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutfitItem {
  final String name;
  final String imagePath;

  OutfitItem({required this.name, required this.imagePath});
}
