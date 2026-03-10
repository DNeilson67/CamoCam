import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tryon_preview_screen.dart';

class TryonChoosePatternScreen extends StatefulWidget {
  final String selectedModel;

  const TryonChoosePatternScreen({super.key, required this.selectedModel});

  @override
  State<TryonChoosePatternScreen> createState() =>
      _TryonChoosePatternScreenState();
}

class _TryonChoosePatternScreenState extends State<TryonChoosePatternScreen> {
  int? selectedPatternIndex;

  final List<Map<String, String>> patterns = [
    {'name': 'Woodland', 'image': 'assets/images/pattern_1.jpg'},
    {'name': 'Desert', 'image': 'assets/images/pattern_2.png'},
    {'name': 'Urban', 'image': 'assets/images/pattern_3.png'},
    {'name': 'Snow', 'image': 'assets/images/pattern_4.png'},
    {'name': 'Digital', 'image': 'assets/images/pattern_5.png'},
    {'name': 'Tiger', 'image': 'assets/images/pattern_6.png'},
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
          'Virtual-TryOn',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Title and Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Choose Your Pattern',
                    style: GoogleFonts.montserrat(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF292929),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Search and choose patterns to apply on your selected outfit',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF727272),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: const Color(0xFFB3B3B3)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: const Color(0xFF666666),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF666666),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 17),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 22,
                  mainAxisSpacing: 22,
                  childAspectRatio: 175 / 224,
                ),
                itemCount: patterns.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedPatternIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedPatternIndex = index;
                      });
                    },
                    child: Container(
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
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF4A7C59),
                                width: 3,
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pattern Image
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: Image.asset(
                                  patterns[index]['image']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.image,
                                      size: 50,
                                      color: Colors.grey,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          // Pattern Info
                          Padding(
                            padding: const EdgeInsets.all(9),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Pattern #${index + 1}',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${(index + 2) * 2} images',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 8,
                                    color: const Color(0xFF848383),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: selectedPatternIndex != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TryonPreviewScreen(
                                selectedModel: widget.selectedModel,
                                selectedPattern:
                                    patterns[selectedPatternIndex!]['name']!,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Apply Now',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedPatternIndex != null
                        ? const Color(0xFF68B0AB)
                        : const Color(0xFFB1BBBA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFB1BBBA),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
