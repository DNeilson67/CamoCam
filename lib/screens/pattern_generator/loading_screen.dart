import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/collection_service.dart';
import 'pattern_result_screen.dart';

class LoadingScreen extends StatefulWidget {
  final List<File> images;
  final String title;

  const LoadingScreen({super.key, required this.images, required this.title});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _generatePattern();
  }

  Future<void> _generatePattern() async {
    try {
      final result = await CollectionService().createCollection(
        title: widget.title,
        images: widget.images,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PatternResultScreen(
              patternTitle: result.title,
              patternImageUrl: result.patternImageUrl,
              collectionId: result.collectionId,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pattern generation failed: ${e.toString()}')),
        );
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
        title: Text(
          'Pattern Generator',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: Center(
          child: SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A7C59)),
              strokeWidth: 4,
            ),
          ),
        ),
      ),
    );
  }
}
