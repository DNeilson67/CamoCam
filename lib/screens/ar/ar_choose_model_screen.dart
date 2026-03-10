import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'ar_choose_pattern_screen.dart';
import '../profile/model_viewer_screen.dart';

class ArChooseModelScreen extends StatefulWidget {
  const ArChooseModelScreen({super.key});

  @override
  State<ArChooseModelScreen> createState() => _ArChooseModelScreenState();
}

class _ArChooseModelScreenState extends State<ArChooseModelScreen> {
  int _currentIndex = 0;

  final List<ModelItem> _models = [
    ModelItem(
      name: 'Helicopter',
      imagePath: 'assets/objects/models/helicopter/helicopter.png',
      modelPath: 'assets/objects/models/helicopter/helicopter.glb',
    ),
    ModelItem(
      name: 'Jeep',
      imagePath: 'assets/objects/models/jeep/jeep.png',
      modelPath: 'assets/objects/models/jeep/jeep.glb',
    ),
    ModelItem(
      name: 'Tank',
      imagePath: 'assets/objects/models/tank/tank.png',
      modelPath: 'assets/objects/models/tank/tank.glb',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        title: Text(
          'Augmented Reality',
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
                'Choose Your Object',
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select the item you want to camouflage\nand preview in AR',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: const Color(0xFF797777),
                ),
              ),
              const SizedBox(height: 48),

              // Model carousel
              Expanded(
                child: CarouselSlider.builder(
                  itemCount: _models.length,
                  itemBuilder: (context, index, realIndex) {
                    return Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        // color: Colors.grey[200],
                        child: Image.asset(
                          _models[index].imagePath, // <-- Local image
                          fit: BoxFit.contain,
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
                  _models.length,
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
                _models[_currentIndex].name,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ModelViewerScreen(
                                  modelName: _models[_currentIndex].name,
                                  modelUrl: _models[_currentIndex].modelPath,
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
                                builder: (_) => ArChoosePatternScreen(
                                  selectedModel: _models[_currentIndex].name,
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

class ModelItem {
  final String name;
  final String imagePath;
  final String modelPath;

  ModelItem({
    required this.name,
    required this.imagePath,
    required this.modelPath,
  });
}
