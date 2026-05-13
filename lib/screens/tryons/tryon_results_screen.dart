import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/ar_service.dart';

class TryonResultsScreen extends StatefulWidget {
  final String selectedModel;
  final String selectedPattern;
  final String photoPath;
  final int collectionId;

  const TryonResultsScreen({
    super.key,
    required this.selectedModel,
    required this.selectedPattern,
    required this.photoPath,
    required this.collectionId,
  });

  @override
  State<TryonResultsScreen> createState() => _TryonResultsScreenState();
}

class _TryonResultsScreenState extends State<TryonResultsScreen> {
  final ArService _arService = ArService();
  Uint8List? _resultBytes;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _applyRetexture();
  }

  Future<void> _applyRetexture() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bytes = await _arService.retextureClothes(
        photo: File(widget.photoPath),
        collectionId: widget.collectionId,
      );

      if (!mounted) return;
      setState(() {
        _resultBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
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
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      _isLoading
                          ? 'Applying Pattern...'
                          : _errorMessage != null
                              ? 'Apply Failed'
                              : 'Apply Successful',
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF292929),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 29),
                      child: Text(
                        _isLoading
                            ? 'The AI is generating your camouflaged outfit. This usually takes 1–2 minutes.'
                            : _errorMessage != null
                                ? _errorMessage!
                                : 'Your outfit has been applied! Check how it looks on you before saving or trying again',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF727272),
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.5,
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: AspectRatio(
                          aspectRatio: 331 / 444,
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: _buildResultImage(),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(21, 18, 21, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                border: Border(
                  top: BorderSide(color: const Color(0xFFE7E7E7), width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _errorMessage != null
                            ? _applyRetexture
                            : () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                        icon: Icon(
                          _errorMessage != null
                              ? Icons.refresh
                              : Icons.refresh,
                          color: const Color(0xFF4A7C59),
                          size: 18,
                        ),
                        label: Text(
                          _errorMessage != null ? 'Retry' : 'Restart',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF8FC0A9),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _resultBytes != null
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Saved to gallery successfully!',
                                      style: GoogleFonts.montserrat(),
                                    ),
                                    backgroundColor: const Color(0xFF4A7C59),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(
                          Icons.save_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text(
                          'Save to Gallery',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF68B0AB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: const Color(0xFFB1BBBA),
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
    );
  }

  Widget _buildResultImage() {
    if (_isLoading) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(
            File(widget.photoPath),
            fit: BoxFit.cover,
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Generating...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_resultBytes != null) {
      return Image.memory(_resultBytes!, fit: BoxFit.cover);
    }

    // Error state — show original photo with a faint overlay
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(widget.photoPath), fit: BoxFit.cover),
        Container(color: Colors.black.withOpacity(0.25)),
        const Center(
          child: Icon(Icons.error_outline, size: 64, color: Colors.white),
        ),
      ],
    );
  }
}
