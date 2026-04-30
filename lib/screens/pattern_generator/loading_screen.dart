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
  String _statusMessage = 'Preparing pattern generation...';

  @override
  void initState() {
    super.initState();
    _generatePattern();
  }

  Future<void> _generatePattern() async {
    try {
      setState(() => _statusMessage = 'Uploading images...');

      final result = await CollectionService().createCollection(
        title: widget.title,
        images: widget.images,
      );

      setState(() => _statusMessage = 'Generating pattern...');

      if (mounted) {
        setState(() => _statusMessage = 'Finalizing...');
        await Future.delayed(const Duration(milliseconds: 500));

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
        setState(
          () => _statusMessage =
              'Error: ${e.toString().replaceFirst('Exception: ', '')}',
        );
        await Future.delayed(const Duration(seconds: 2));

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pattern generation failed: ${e.toString()}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A7C59)),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            Text(
              _statusMessage,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4A7C59),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'This may take a moment...',
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
