import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatternDetailScreen extends StatefulWidget {
  final int collectionId;       // ✅ new
  final String patternName;
  final int patternIndex;

  const PatternDetailScreen({
    super.key,
    required this.collectionId, // ✅ new
    required this.patternName,
    required this.patternIndex,
  });

  @override
  State<PatternDetailScreen> createState() => _PatternDetailScreenState();
}

class _PatternDetailScreenState extends State<PatternDetailScreen> {
  late String _patternName;
  String? _patternImageUrl;
  List<String> _usedImageUrls = [];
  bool _isLoadingPattern = true;
  bool _isLoadingImages = true;
  bool _isRenaming = false;

  final supabase = Supabase.instance.client;
  String? get _userId => supabase.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _patternName = widget.patternName;
    _fetchPatternImage();
    _fetchUsedImages();
  }

  // Fetch pattern image from bucket using collection_id
  Future<void> _fetchPatternImage() async {
    try {
      if (_userId == null) return;

      // File is named "pattern_collection_{id}.jpg" in the bucket
      final List<FileObject> files = await supabase.storage
          .from('camouflage-patterns')
          .list(path: 'user_$_userId');

      // Match by collection_id number in the filename
      final match = files.firstWhere(
        (f) => f.name.contains('collection_${widget.collectionId}'),
        orElse: () => throw Exception('Pattern file not found'),
      );

      final url = supabase.storage
          .from('camouflage-patterns')
          .getPublicUrl('user_$_userId/${match.name}');

      if (mounted) {
        setState(() {
          _patternImageUrl = url;
          _isLoadingPattern = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pattern image: $e');
      if (mounted) setState(() => _isLoadingPattern = false);
    }
  }

  // Fetch used images from camouflage-images using collection_id
  Future<void> _fetchUsedImages() async {
    try {
      if (_userId == null) return;

      // Folder is named "collection_{id}" in camouflage-images
      final folderPath = 'user_$_userId/collection_${widget.collectionId}';
      debugPrint('Fetching used images from: $folderPath');

      final List<FileObject> files = await supabase.storage
          .from('camouflage-images')
          .list(path: folderPath);

      final urls = files
          .where((f) => f.name != '.emptyFolderPlaceholder')
          .map((f) => supabase.storage
              .from('camouflage-images')
              .getPublicUrl('$folderPath/${f.name}'))
          .toList();

      if (mounted) {
        setState(() {
          _usedImageUrls = urls;
          _isLoadingImages = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching used images: $e');
      if (mounted) setState(() => _isLoadingImages = false);
    }
  }

  // Rename: update ONLY the title in the database
  Future<void> _renamePattern(String newName) async {
    if (newName == _patternName) return;
    if (mounted) setState(() => _isRenaming = true);

    try {
      // Update title in collections table — no bucket changes needed
      await supabase
          .from('collections')
          .update({'title': newName})
          .eq('collection_id', widget.collectionId)
          .eq('user_id', _userId!);

      debugPrint('Title updated to "$newName" for collection_id=${widget.collectionId}');

      if (mounted) {
        setState(() {
          _patternName = newName;
          _isRenaming = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Renamed to "$newName"', style: GoogleFonts.montserrat()),
            backgroundColor: const Color(0xFF4A7C59),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error renaming: $e');
      if (mounted) {
        setState(() => _isRenaming = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rename.', style: GoogleFonts.montserrat()),
            backgroundColor: const Color(0xFFCF3017),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _patternName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Rename Pattern',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Enter pattern name',
            hintStyle: GoogleFonts.montserrat(color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4A7C59), width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          style: GoogleFonts.montserrat(),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.montserrat(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              Navigator.pop(ctx);
              if (newName.isNotEmpty && newName != _patternName) {
                _renamePattern(newName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: Text('Save',
                style: GoogleFonts.montserrat(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

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
        title: Text('Pattern Collections',
            style: GoogleFonts.montserrat(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final squareSize = constraints.maxWidth - 46;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // ── Pattern name + rename icon ──────────────────────────
                    GestureDetector(
                      onTap: _isRenaming ? null : _showRenameDialog,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _patternName,
                              style: GoogleFonts.montserrat(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF292929),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _isRenaming
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF4A7C59)),
                                )
                              : const Icon(Icons.edit_outlined,
                                  size: 20, color: Color(0xFF4A7C59)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Big pattern preview from camouflage-patterns ────────
                    SizedBox(
                      width: squareSize,
                      height: squareSize,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                              color: const Color(0xFF4A7C59), width: 5),
                          color: Colors.grey[200],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: _isLoadingPattern
                              ? const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF4A7C59)))
                              : _patternImageUrl != null
                                  ? Image.network(
                                      _patternImageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(
                                              child: Icon(Icons.broken_image,
                                                  size: 60,
                                                  color: Color(0xFF4A7C59))),
                                    )
                                  : const Center(
                                      child: Icon(Icons.pattern,
                                          size: 60, color: Color(0xFF4A7C59))),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Used Images from camouflage-images ─────────────────
                    Text('Used Images',
                        style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF292929)),
                        textAlign: TextAlign.center),

                    const SizedBox(height: 16),

                    _isLoadingImages
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 32),
                            child: CircularProgressIndicator(
                                color: Color(0xFF4A7C59)),
                          )
                        : _usedImageUrls.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 32),
                                child: Text('No images found.',
                                    style: GoogleFonts.montserrat(
                                        color: Colors.grey)),
                              )
                            : _buildImageGrid(_usedImageUrls),

                    const SizedBox(height: 20),

                    // ── Delete button ───────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteConfirmation(context),
                        icon: const Icon(Icons.delete_outline,
                            color: Color(0xFFFFE9E5), size: 20),
                        label: Text('Delete',
                            style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFFE9E5))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCF3017),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageGrid(List<String> imageUrls) {
    return Column(
      children: [
        _buildImageRow(imageUrls, 0, 1, 2),
        const SizedBox(height: 25),
        _buildImageRow(imageUrls, 3, 4, 5),
        const SizedBox(height: 25),
        _buildImageRow(imageUrls, 6, 7, 8),
      ],
    );
  }

  Widget _buildImageRow(List<String> imageUrls, int i1, int i2, int i3) {
    return Row(
      children: [
        Expanded(child: _buildImageSlot(imageUrls, i1)),
        const SizedBox(width: 10),
        Expanded(child: _buildImageSlot(imageUrls, i2)),
        const SizedBox(width: 10),
        Expanded(child: _buildImageSlot(imageUrls, i3)),
      ],
    );
  }

  Widget _buildImageSlot(List<String> imageUrls, int index) {
    final hasImage = index < imageUrls.length;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasImage
                ? const Color(0xFF4A7C59)
                : const Color(0xFF797777),
            width: 2,
          ),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF4A7C59)),
                          ),
                        ),
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 40),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Future<void> _deletePattern() async {
  try {
    if (_userId == null) return;

    // Step 1: Delete row from collections table
    await supabase
        .from('collections')
        .delete()
        .eq('collection_id', widget.collectionId)
        .eq('user_id', _userId!);

    debugPrint('Deleted row for collection_id=${widget.collectionId}');

    // Step 2: Find and delete the pattern file from camouflage-patterns
    final List<FileObject> patternFiles = await supabase.storage
        .from('camouflage-patterns')
        .list(path: 'user_$_userId');

    final match = patternFiles
        .where((f) => f.name.contains('collection_${widget.collectionId}'))
        .toList();

    if (match.isNotEmpty) {
      await supabase.storage
          .from('camouflage-patterns')
          .remove(match
              .map((f) => 'user_$_userId/${f.name}')
              .toList());
      debugPrint('Deleted pattern file: ${match.first.name}');
    }

    // Step 3: Delete all images inside the collection folder
    // from camouflage-images (Supabase has no folder delete — remove each file)
    final folderPath = 'user_$_userId/collection_${widget.collectionId}';
    final List<FileObject> imageFiles = await supabase.storage
        .from('camouflage-images')
        .list(path: folderPath);

    final validImages = imageFiles
        .where((f) => f.name != '.emptyFolderPlaceholder')
        .toList();

    if (validImages.isNotEmpty) {
      await supabase.storage
          .from('camouflage-images')
          .remove(validImages
              .map((f) => '$folderPath/${f.name}')
              .toList());
      debugPrint('Deleted ${validImages.length} images from $folderPath');
    }

    if (mounted) Navigator.pop(context); // go back to collections
  } catch (e) {
    debugPrint('Error deleting pattern: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete pattern.',
              style: GoogleFonts.montserrat()),
          backgroundColor: const Color(0xFFCF3017),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Pattern',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        content: Text(
          'Are you sure you want to delete "$_patternName"? This cannot be undone.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.montserrat(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              _deletePattern();   // then delete
            },
            child: Text('Delete',
                style: GoogleFonts.montserrat(
                    color: const Color(0xFFCF3017),
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}