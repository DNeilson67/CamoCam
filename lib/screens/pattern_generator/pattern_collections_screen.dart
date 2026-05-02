import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pattern_detail_screen.dart';

class PatternCollectionsScreen extends StatefulWidget {
  const PatternCollectionsScreen({super.key});

  @override
  State<PatternCollectionsScreen> createState() =>
      _PatternCollectionsScreenState();
}

class _PatternCollectionsScreenState extends State<PatternCollectionsScreen> {
  final List<Map<String, dynamic>> _patterns = [];
  bool _isLoading = true;
  bool _isFetchingMore = false;
  bool _hasMore = true;

  static const int _pageSize = 9;
  int _offset = 0;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Timer for debouncing search input
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPatterns();

    // Listen for search changes with debouncing
    _searchController.addListener(_onSearchChanged);

    // Infinite scroll listener
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
    // If the user is typing, cancel the previous timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Wait 500ms after the user stops typing to trigger the search
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _searchController.text.trim();
      if (query != _searchQuery) {
        setState(() {
          _searchQuery = query;
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
    // Prevent overlapping fetches or fetching when no more data exists
    if (_isFetchingMore) return;

    setState(() {
      _offset == 0 ? _isLoading = true : _isFetchingMore = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Build query dynamically
      var query = supabase
          .from('collections')
          .select('collection_id, title, pattern_image_url')
          .eq('user_id', userId);

      // Apply search filter if query exists
      if (_searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$_searchQuery%');
      }

      final response = await query
          .order('collection_id', ascending: true)
          .range(_offset, _offset + _pageSize - 1);

      final newPatterns = (response as List).map((row) {
        return {
          'collection_id': row['collection_id'] as int,
          'name': row['title'] as String,
          'imageUrl': row['pattern_image_url'] as String,
        };
      }).toList();

      if (mounted) {
        setState(() {
          // Double check to clear list if this is a fresh search result
          if (_offset == 0) _patterns.clear();

          _patterns.addAll(newPatterns);
          _offset += newPatterns.length;
          _hasMore = newPatterns.length == _pageSize;
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
                  border: Border.all(color: const Color(0xFFB3B3B3), width: 1),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    const Icon(Icons.search, size: 24, color: Color(0xFF666666)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          color: const Color(0xFF292929),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search patterns...',
                          hintStyle: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: const Color(0xFF666666),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      size: 18, color: Color(0xFF666666)),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Pattern Grid
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4A7C59)))
                  : _patterns.isEmpty
                      ? Center(
                          child: Text(
                            _searchQuery.isEmpty
                                ? 'No patterns yet.'
                                : 'No results for "$_searchQuery"',
                            style: GoogleFonts.montserrat(color: Colors.grey),
                          ),
                        )
                      : SingleChildScrollView(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 21),
                          child: Column(
                            children: [
                              for (int i = 0; i < _patterns.length; i += 2)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 22),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildPatternCard(_patterns[i], i),
                                      if (i + 1 < _patterns.length)
                                        _buildPatternCard(
                                            _patterns[i + 1], i + 1)
                                      else
                                        const SizedBox(width: 175),
                                    ],
                                  ),
                                ),
                              if (_isFetchingMore)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF4A7C59)),
                                ),
                              const SizedBox(height: 16),
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
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PatternDetailScreen(
              collectionId: pattern['collection_id'] as int,
              patternName: pattern['name'],
              patternIndex: index,
            ),
          ),
        );
        _resetAndFetch();
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
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Image.network(
                pattern['imageUrl'],
                width: 175,
                height: 175,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        width: 175,
                        height: 175,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Color(0xFF4A7C59)),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Container(
                  width: 175,
                  height: 175,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 60),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              child: Text(
                pattern['name'],
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.4,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}