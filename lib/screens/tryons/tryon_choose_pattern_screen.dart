import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tryon_loading_screen.dart';

class TryonChoosePatternScreen extends StatefulWidget {
  final String selectedModel;
  final String selectedModelImage;

  const TryonChoosePatternScreen({
    super.key,
    required this.selectedModel,
    required this.selectedModelImage,
  });

  @override
  State<TryonChoosePatternScreen> createState() =>
      _TryonChoosePatternScreenState();
}

class _TryonChoosePatternScreenState extends State<TryonChoosePatternScreen> {
  // Data State
  final List<Map<String, dynamic>> _patterns = [];
  int? selectedPatternIndex;
  
  // Loading & Pagination State
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;
  static const int _pageSize = 10;
  int _offset = 0;

  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPatterns();

    // Debounced Search Listener
    _searchController.addListener(_onSearchChanged);

    // Infinite Scroll Listener
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isFetchingMore &&
          !_isLoading &&
          _hasMore) {
        _fetchPatterns();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
          selectedPatternIndex = null; // Reset selection on new search
        });
        _resetAndFetch();
      }
    });
  }

  void _resetAndFetch() {
    setState(() {
      _patterns.clear();
      _offset = 0;
      _hasMore = true;
      _isLoading = true;
    });
    _fetchPatterns();
  }

  Future<void> _fetchPatterns() async {
    if (_isFetchingMore) return;

    setState(() {
      _offset == 0 ? _isLoading = true : _isFetchingMore = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      var query = supabase
          .from('collections')
          .select('collection_id, title, pattern_image_url')
          .eq('user_id', userId);

      if (_searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$_searchQuery%');
      }

      final response = await query
          .order('collection_id', ascending: true)
          .range(_offset, _offset + _pageSize - 1);

      final newItems = (response as List).map((row) {
        return {
          'id': row['collection_id'],
          'name': row['title'],
          'image': row['pattern_image_url'],
        };
      }).toList();

      if (mounted) {
        setState(() {
          if (_offset == 0) _patterns.clear();
          _patterns.addAll(newItems);
          _offset += newItems.length;
          _hasMore = newItems.length == _pageSize;
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching patterns: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Column(
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
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: GoogleFonts.montserrat(
                      fontSize: 16,
                      color: const Color(0xFF666666),
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF666666)),
                    suffixIcon: _searchQuery.isNotEmpty 
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => _searchController.clear(),
                        ) 
                      : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 17),
            // Grid Area
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
                  : _patterns.isEmpty
                      ? Center(child: Text("No patterns found.", style: GoogleFonts.montserrat()))
                      : GridView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 22,
                            mainAxisSpacing: 22,
                            childAspectRatio: 175 / 224,
                          ),
                          itemCount: _patterns.length + (_isFetchingMore ? 2 : 0),
                          itemBuilder: (context, index) {
                            if (index >= _patterns.length) {
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            }

                            final pattern = _patterns[index];
                            final isSelected = selectedPatternIndex == index;

                            return GestureDetector(
                              onTap: () => setState(() => selectedPatternIndex = index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      offset: const Offset(0, 4),
                                      blurRadius: 4,
                                    ),
                                  ],
                                  border: isSelected
                                      ? Border.all(color: const Color(0xFF4A7C59), width: 3)
                                      : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          pattern['image'],
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              const Icon(Icons.broken_image, size: 50),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(9),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            pattern['name'],
                                            style: GoogleFonts.montserrat(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Custom Pattern',
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
            // Footer Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: selectedPatternIndex != null
                      ? () {
                          final pattern = _patterns[selectedPatternIndex!];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TryonLoadingScreen(
                                selectedModel: widget.selectedModel,
                                selectedModelImage: widget.selectedModelImage,
                                selectedPattern: pattern['image'],
                                collectionId: pattern['id'] as int,
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
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