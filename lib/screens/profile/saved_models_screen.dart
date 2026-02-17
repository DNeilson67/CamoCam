import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'model_viewer_screen.dart';
import 'image_viewer_screen.dart';

class SavedModelsScreen extends StatefulWidget {
  const SavedModelsScreen({super.key});

  @override
  State<SavedModelsScreen> createState() => _SavedModelsScreenState();
}

class _SavedModelsScreenState extends State<SavedModelsScreen> {
  String _selectedFilter = 'All'; // All, 2D, 3D
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredModels = [];

  final List<Map<String, dynamic>> patterns = [
    {
      'name': 'Pattern #1',
      'imageCount': 4,
      'imagePath': 'assets/images/pattern_1.jpg',
      'type': '3D',
      'modelUrl': 'assets/models/T34-85.glb',
    },
    {
      'name': 'Pattern #2',
      'imageCount': 6,
      'imagePath': 'assets/images/pattern_2.png',
      'type': '2D',
      'modelUrl': null,
    },
    {
      'name': 'Pattern #3',
      'imageCount': 9,
      'imagePath': 'assets/images/pattern_3.png',
      'type': '3D',
      'modelUrl': 'assets/models/T34-85.glb',
    },
    {
      'name': 'Pattern #4',
      'imageCount': 9,
      'imagePath': 'assets/images/pattern_4.png',
      'type': '2D',
      'modelUrl': null,
    },
    {
      'name': 'Pattern #5',
      'imageCount': 9,
      'imagePath': 'assets/images/pattern_5.png',
      'type': '3D',
      'modelUrl': 'assets/models/T34-85.glb',
    },
    {
      'name': 'Pattern #6',
      'imageCount': 9,
      'imagePath': 'assets/images/pattern_6.png',
      'type': '2D',
      'modelUrl': null,
    },
  ];


  @override
  void initState() {
    super.initState();
    _filteredModels = patterns;
    _searchController.addListener(_filterModels);
  }

  void _filterModels() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredModels = patterns.where((model) {
        final matchesSearch = model['name'].toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'All' || model['type'] == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filterModels();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Your Saved Models',
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            children: [
              // Search Bar and Filter Button
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: const Color(0xFFB3B3B3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.search,
                            color: Color(0xFF666666),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  color: const Color(0xFF666666),
                                ),
                                border: InputBorder.none,
                              ),
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: const Color(0xFF1A1A1A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('2D'),
                  const SizedBox(width: 8),
                  _buildFilterChip('3D'),
                ],
              ),

              const SizedBox(height: 22),

              // Patterns Grid
              _filteredModels.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No models found',
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
                            crossAxisSpacing: 22,
                            mainAxisSpacing: 22,
                            childAspectRatio: 175 / 224,
                          ),
                      itemCount: _filteredModels.length,
                      itemBuilder: (context, index) {
                        final pattern = _filteredModels[index];
                        return _buildModelCard(pattern);
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => _onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A7C59) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4A7C59)
                : const Color(0xFFB3B3B3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    final is3D = model['type'] == '3D';

    return GestureDetector(
      onTap: () {
        if (is3D && model['modelUrl'] != null && model['modelUrl'].isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModelViewerScreen(
                modelName: model['name'] ?? 'Unnamed Model',
                modelUrl: model['modelUrl']!,
                thumbnailUrl: model['imagePath'],
              ),
            ),
          );
        } else if (!is3D) {
          // Show image viewer for 2D try-on models
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(
                imageName: model['name'] ?? 'Unnamed Model',
                imageUrl: model['imagePath'],
                patternName: model['name'] ?? 'Default Pattern',
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pattern Image with 3D Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: Image.asset(
                    model['imagePath'],
                    height: 175,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 175,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),

                // Type Badge
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: is3D
                          ? const Color(0xFF4A7C59)
                          : const Color(0xFF68B0AB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      model['type'],
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                // 3D Icon overlay
                if (is3D)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.view_in_ar,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            // Pattern Info
            Padding(
              padding: const EdgeInsets.only(left: 9, top: 6, bottom: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['name'],
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
                    '${model['imageCount']} images',
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
