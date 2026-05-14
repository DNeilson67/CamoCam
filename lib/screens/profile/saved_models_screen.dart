import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/ar_service.dart';
import 'model_viewer_screen.dart';

class SavedModelsScreen extends StatefulWidget {
  const SavedModelsScreen({super.key});

  @override
  State<SavedModelsScreen> createState() => _SavedModelsScreenState();
}

class _SavedModelsScreenState extends State<SavedModelsScreen> {
  final ArService _arService = ArService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allModels = [];
  List<Map<String, dynamic>> _filteredModels = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _fetchModels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchModels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final applied = await _arService.getUserAppliedPatterns();

      // 3D models only — drop entries whose stored URL isn't a .glb
      // (existing 2D rows from the removed retexture flow).
      final fetched = applied
          .where((p) => p.appliedModelUrl.toLowerCase().endsWith('.glb'))
          .map((p) => {
                'name': (p.title != null && p.title!.trim().isNotEmpty)
                    ? p.title!
                    : 'Collection ${p.collectionId} - Model ${p.appliedId}',
                'imagePath': p.thumbnailUrl,
                'modelUrl': p.appliedModelUrl,
              })
          .toList();

      if (mounted) {
        setState(() {
          _allModels = fetched;
          _filteredModels = fetched;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e, stack) {
      debugPrint('[SavedModels] ERROR: $e\n$stack');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredModels = _allModels
          .where(
              (model) => (model['name'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A7C59),
        automaticallyImplyLeading: false,
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
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
            : _errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFFB3B3B3)),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                  fontSize: 13, color: const Color(0xFF727272)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchModels,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7C59),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Search bar
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFB3B3B3)),
              borderRadius: BorderRadius.circular(48),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search, color: Color(0xFF666666), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: GoogleFonts.montserrat(
                          fontSize: 16, color: const Color(0xFF666666)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear,
                                  size: 18, color: Color(0xFF666666)),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                    ),
                    style: GoogleFonts.montserrat(
                        fontSize: 16, color: const Color(0xFF1A1A1A)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filter chips
          const SizedBox(height: 22),

          // Grid
          _filteredModels.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'No models found',
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF727272)),
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
                  itemBuilder: (context, index) =>
                      _buildModelCard(_filteredModels[index]),
                ),
        ],
      ),
    );
  }

  Widget _buildModelCard(Map<String, dynamic> model) {
    const primaryColor = Color(0xFF4A7C59);
    final imageUrl = model['imagePath'] as String?;
    final modelUrl = model['modelUrl'] as String?;

    return GestureDetector(
      onTap: () {
        if (modelUrl != null && modelUrl.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModelViewerScreen(
                modelName: model['name'],
                modelUrl: modelUrl,
                thumbnailUrl: model['imagePath'],
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
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) =>
                                progress == null
                                    ? child
                                    : _placeholderBox(primaryColor),
                            errorBuilder: (_, __, ___) =>
                                _placeholderBox(primaryColor),
                          )
                        : _placeholderBox(primaryColor),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.view_in_ar,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(9, 6, 9, 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    model['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.25,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '3D model',
                    style: GoogleFonts.montserrat(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF848383),
                      height: 1.4,
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

  Widget _placeholderBox(Color color) {
    return Container(
      width: double.infinity,
      color: color,
      child: const Center(
        child: Icon(Icons.view_in_ar, size: 48, color: Colors.white),
      ),
    );
  }
}