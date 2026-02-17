import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pattern_detail_screen.dart';

class PatternCollectionsScreen extends StatefulWidget {
  const PatternCollectionsScreen({super.key});

  @override
  State<PatternCollectionsScreen> createState() =>
      _PatternCollectionsScreenState();
}

class _PatternCollectionsScreenState extends State<PatternCollectionsScreen> {
  final List<Map<String, dynamic>> _patterns = [
  {
    'name': 'Pattern #1',
    'imageCount': 4,
    'imagePath': 'assets/images/pattern_1.jpg',
  },
  {
    'name': 'Pattern #2',
    'imageCount': 6,
    'imagePath': 'assets/images/pattern_2.png',
  },
  {
    'name': 'Pattern #3',
    'imageCount': 9,
    'imagePath': 'assets/images/pattern_3.png',
  },
  {
    'name': 'Pattern #4',
    'imageCount': 9,
    'imagePath': 'assets/images/pattern_4.png',
  },
  {
    'name': 'Pattern #5',
    'imageCount': 9,
    'imagePath': 'assets/images/pattern_5.png',
  },
  {
    'name': 'Pattern #6',
    'imageCount': 9,
    'imagePath': 'assets/images/pattern_6.png',
  },
];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pattern Collections',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 17),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                    color: const Color(0xFFB3B3B3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.search,
                      size: 24,
                      color: Color(0xFF666666),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF666666),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Pattern Grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 21),
                child: Column(
                  children: [
                    for (int i = 0; i < _patterns.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPatternCard(_patterns[i], i),
                            if (i + 1 < _patterns.length)
                              _buildPatternCard(_patterns[i + 1], i + 1)
                            else
                              const SizedBox(width: 175),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(Map<String, dynamic> pattern, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatternDetailScreen(
              patternName: pattern['name'],
              patternIndex: index,
            ),
          ),
        );
      },
      child: Container(
        width: 175,
        height: 224,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pattern Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.asset(
              pattern['imagePath'],
              width: 175,
              height: 175,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 175,
                  height: 175,
                  color: Colors.grey[300],
                  child: const Icon(Icons.pattern, size: 60),
                );
              },
            ),
            ),

            // Pattern Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pattern['name'],
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.33,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${pattern['imageCount']} images',
                    style: GoogleFonts.montserrat(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF848383),
                      height: 2.0,
                      letterSpacing: 0.4,
                    ),
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
