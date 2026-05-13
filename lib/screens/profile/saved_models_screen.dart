import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'model_viewer_screen.dart';
import 'image_viewer_screen.dart';

class SavedModelsScreen extends StatefulWidget {
  const SavedModelsScreen({super.key});

  @override
  State<SavedModelsScreen> createState() => _SavedModelsScreenState();
}

class _SavedModelsScreenState extends State<SavedModelsScreen> {
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allModels = [];
  List<Map<String, dynamic>> _filteredModels = [];
  bool _isLoading = true;
  String? _errorMessage;

  static const String _bucketName = 'camouflage-applied-models';

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
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        setState(() {
          _errorMessage = 'Not signed in.';
          _isLoading = false;
        });
        return;
      }

      // ==========================================
      // NEW STEP: Fetch titles from DB as a lookup map
      // ==========================================
      final Map<String, String> titleLookup = {};
      try {
        final dbData = await supabase
            .from('applied_patterns')
            .select('collection_id, title');
        
        for (final row in dbData) {
          final id = row['collection_id']?.toString();
          final title = row['title'] as String?;
          if (id != null && title != null && title.trim().isNotEmpty) {
            titleLookup[id] = title; // Maps '4' -> 'Cappucino Assassin'
          }
        }
      } catch (dbError) {
        debugPrint('[SavedModels] Optional DB fetch failed: $dbError');
        // We catch this so even if the DB fails, the bucket items still load with fallbacks
      }
      // ==========================================

      final List<Map<String, dynamic>> fetchedModels = [];

      // Step 1: list bucket root to discover the actual user folder name.
      final rootFolders = await supabase.storage
          .from(_bucketName)
          .list(path: '');

      debugPrint('[SavedModels] root folders: ${rootFolders.map((f) => f.name).toList()}');

      if (rootFolders.isEmpty) {
        setState(() {
          _errorMessage =
              'Storage returned no folders. Check your Supabase Storage '
              'RLS policy — authenticated users need SELECT on this bucket.';
          _isLoading = false;
        });
        return;
      }

      // Find whichever root folder contains the userId substring
      FileObject? userFolder;
      for (final f in rootFolders) {
        if (f.name.contains(userId)) {
          userFolder = f;
          break;
        }
      }

      if (userFolder == null) {
        setState(() {
          _errorMessage =
              'No folder found for this user.\n'
              'Root folders: ${rootFolders.map((f) => f.name).toList()}\n'
              'Looking for userId: $userId';
          _isLoading = false;
        });
        return;
      }

      final userPath = userFolder.name;
      debugPrint('[SavedModels] resolved userPath = $userPath');

      // Step 2: list collection folders
      final collectionFolders = await supabase.storage
          .from(_bucketName)
          .list(path: userPath);

      debugPrint('[SavedModels] collections: ${collectionFolders.map((f) => f.name).toList()}');

      for (final collectionObj in collectionFolders) {
        if (collectionObj.name.isEmpty) continue;

        final collectionPath = '$userPath/${collectionObj.name}';

        // Step 3: list 2d / 3d type folders
        final typeFolders = await supabase.storage
            .from(_bucketName)
            .list(path: collectionPath);

        debugPrint('[SavedModels]   types in ${collectionObj.name}: ${typeFolders.map((f) => f.name).toList()}');

        for (final typeObj in typeFolders) {
          final rawType = typeObj.name.toLowerCase();
          if (rawType != '2d' && rawType != '3d') continue;

          final modelType = rawType == '3d' ? '3D' : '2D';
          final typePath = '$collectionPath/${typeObj.name}';

          // Step 4: list model folders
          final modelFolders = await supabase.storage
              .from(_bucketName)
              .list(path: typePath);

          debugPrint('[SavedModels]     models in $rawType: ${modelFolders.map((f) => f.name).toList()}');

          for (final modelObj in modelFolders) {
            if (modelObj.name.isEmpty) continue;

            final modelPath = '$typePath/${modelObj.name}';

            // Step 5: list actual files
            final files = await supabase.storage
                .from(_bucketName)
                .list(path: modelPath);

            debugPrint('[SavedModels]       files in ${modelObj.name}: ${files.map((f) => f.name).toList()}');

            final glbFiles = files
                .where((f) => f.name.toLowerCase().endsWith('.glb'));
            final imageFiles = files.where((f) =>
                f.name.toLowerCase().endsWith('.jpg') ||
                f.name.toLowerCase().endsWith('.jpeg') ||
                f.name.toLowerCase().endsWith('.png') ||
                f.name.toLowerCase().endsWith('.webp'));

            String? modelUrl;
            String? imagePath;

            if (modelType == '3D' && glbFiles.isNotEmpty) {
              final filePath = '$modelPath/${glbFiles.first.name}';
              modelUrl = supabase.storage
                  .from(_bucketName)
                  .getPublicUrl(filePath);
              debugPrint('[SavedModels]       GLB url: $modelUrl');
            }

            if (imageFiles.isNotEmpty) {
              final filePath = '$modelPath/${imageFiles.first.name}';
              imagePath = supabase.storage
                  .from(_bucketName)
                  .getPublicUrl(filePath);
            }

            if (modelType == '3D' && modelUrl == null) continue;

            // Extract the collection number ID from the folder name string (e.g., "collection_4" -> "4")
            final collId = collectionObj.name.replaceAll(RegExp(r'[^0-9]'), '');
            
            // Check if our database lookup map has a title for this collection ID
            String finalTitle;
            if (titleLookup.containsKey(collId)) {
              finalTitle = titleLookup[collId]!;
            } else {
              // Fallback to original layout naming if id isn't in database table
              finalTitle = _formatName(modelObj.name, collectionObj.name);
            }

            fetchedModels.add({
              'name': finalTitle, // Uses the DB Title here!
              'imageCount': files.length,
              'imagePath': imagePath,
              'type': modelType,
              'modelUrl': modelUrl,
            });
          }
        }
      }

      debugPrint('[SavedModels] total fetched: ${fetchedModels.length}');

      if (mounted) {
        setState(() {
          _allModels = fetchedModels;
          _filteredModels = fetchedModels;
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

  String _formatName(String modelFolder, String collectionFolder) {
    final collNum = collectionFolder.replaceAll(RegExp(r'[^0-9]'), '');
    final modelNum = modelFolder.replaceAll(RegExp(r'[^0-9]'), '');
    if (collNum.isNotEmpty && modelNum.isNotEmpty) {
      return 'Collection $collNum - Model $modelNum';
    }
    return modelFolder;
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredModels = _allModels.where((model) {
        final matchesSearch =
            (model['name'] as String).toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'All' || model['type'] == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() => _selectedFilter = filter);
    _applyFilters();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchModels,
          ),
        ],
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
    final primaryColor =
        is3D ? const Color(0xFF4A7C59) : const Color(0xFF68B0AB);
    final imageUrl = model['imagePath'] as String?;

    return GestureDetector(
      onTap: () {
        if (is3D && (model['modelUrl'] as String?)?.isNotEmpty == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModelViewerScreen(
                modelName: model['name'],
                modelUrl: model['modelUrl']!,
                thumbnailUrl: model['imagePath'],
              ),
            ),
          );
        } else if (!is3D) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImageViewerScreen(
                imageName: model['name'],
                imageUrl: model['imagePath'],
                patternName: model['name'],
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
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 175,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) =>
                              progress == null
                                  ? child
                                  : _placeholderBox(primaryColor, model['type']),
                          errorBuilder: (_, __, ___) =>
                              _placeholderBox(primaryColor, model['type']),
                        )
                      : _placeholderBox(primaryColor, model['type']),
                ),
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
                      child: const Icon(Icons.view_in_ar,
                          size: 20, color: Colors.white),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9, top: 6, bottom: 9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    model['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.33,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${model['imageCount']} file${model['imageCount'] == 1 ? '' : 's'}',
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

  Widget _placeholderBox(Color color, String type) {
    return Container(
      height: 175,
      width: double.infinity,
      color: color,
      child: Center(
        child: Text(
          type,
          style: GoogleFonts.montserrat(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}