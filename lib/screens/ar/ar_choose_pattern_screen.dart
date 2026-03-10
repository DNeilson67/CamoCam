import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ar_preview_model_screen.dart';

class ArChoosePatternScreen extends StatefulWidget {
  final String selectedModel;

  const ArChoosePatternScreen({super.key, required this.selectedModel});

  @override
  State<ArChoosePatternScreen> createState() => _ArChoosePatternScreenState();
}

class _ArChoosePatternScreenState extends State<ArChoosePatternScreen> {
  int? _selectedPatternIndex;
  final TextEditingController _searchController = TextEditingController();
  List<PatternItem> _filteredPatterns = [];

  final List<PatternItem> _patterns = [
    PatternItem(
      id: 1,
      name: 'Pattern #1',
      imageCount: 4,
      imagePath: 'assets/images/pattern_1.jpg',
    ),
    PatternItem(
      id: 2,
      name: 'Pattern #2',
      imageCount: 6,
      imagePath: 'assets/images/pattern_2.png',
    ),
    PatternItem(
      id: 3,
      name: 'Pattern #3',
      imageCount: 9,
      imagePath: 'assets/images/pattern_3.png',
    ),
    PatternItem(
      id: 4,
      name: 'Pattern #4',
      imageCount: 9,
      imagePath: 'assets/images/pattern_4.png',
    ),
    PatternItem(
      id: 5,
      name: 'Pattern #5',
      imageCount: 9,
      imagePath: 'assets/images/pattern_5.png',
    ),
    PatternItem(
      id: 6,
      name: 'Pattern #6',
      imageCount: 9,
      imagePath: 'assets/images/pattern_6.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredPatterns = _patterns;
    _searchController.addListener(_filterPatterns);
  }

  void _filterPatterns() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPatterns = _patterns;
      } else {
        _filteredPatterns = _patterns
            .where((pattern) => pattern.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Augmented Reality',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Choose Your Pattern',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF292929),
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Search and choose patterns to apply on your selected object',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF727272),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFB3B3B3)),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Color(0xFF666666),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF666666),
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search',
                                  hintStyle: GoogleFonts.montserrat(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF666666),
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Pattern Grid
                    _filteredPatterns.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No patterns found',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF727272),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.78,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            itemCount: _filteredPatterns.length,
                            itemBuilder: (context, index) {
                              return _buildPatternCard(
                                _filteredPatterns[index],
                                index,
                              );
                            },
                          ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Apply Now Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _selectedPatternIndex != null
                        ? () {
                            final selectedPattern =
                                _filteredPatterns[_selectedPatternIndex!];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArPreviewModelScreen(
                                  selectedModel: widget.selectedModel,
                                  selectedPattern: selectedPattern.name,
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
                        height: 1.14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF68B0AB),
                      disabledBackgroundColor: const Color(
                        0xFF68B0AB,
                      ).withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternCard(PatternItem pattern, int index) {
    final isSelected = _selectedPatternIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPatternIndex = index;
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
              ? Border.all(color: const Color(0xFF4A7C59), width: 3)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pattern Image
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.asset(pattern.imagePath, fit: BoxFit.cover),
              ),
            ),

            // Pattern Info
            Flexible(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pattern.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${pattern.imageCount} images',
                      style: GoogleFonts.montserrat(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF848383),
                        height: 1.5,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class PatternItem {
  final int id;
  final String name;
  final int imageCount;
  final String imagePath;

  PatternItem({
    required this.id,
    required this.name,
    required this.imageCount,
    required this.imagePath,
  });
}
