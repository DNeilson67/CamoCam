import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

import '../../services/ar_service.dart';
import 'tryon_preview_screen.dart';

class TryonLoadingScreen extends StatefulWidget {
  final String selectedModel;
  final String selectedModelImage;
  final String selectedPattern;
  final int collectionId;

  const TryonLoadingScreen({
    super.key,
    required this.selectedModel,
    required this.selectedModelImage,
    required this.selectedPattern,
    required this.collectionId,
  });

  @override
  State<TryonLoadingScreen> createState() => _TryonLoadingScreenState();
}

class _TryonLoadingScreenState extends State<TryonLoadingScreen> {
  String _statusMessage = 'Preparing your outfit...';

  @override
  void initState() {
    super.initState();
    _applyPattern();
  }

  Future<File> _assetToFile(String assetPath, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    final data = await rootBundle.load(assetPath);
    await file.writeAsBytes(data.buffer.asUint8List());
    return file;
  }

  Future<void> _applyPattern() async {
    File? outfitFile;
    try {
      setState(() => _statusMessage = 'Loading outfit...');
      outfitFile = await _assetToFile(widget.selectedModelImage, 'outfit.png');

      if (!mounted) return;
      setState(() => _statusMessage = 'Applying pattern to your ${widget.selectedModel}...');

      final applied = await ArService().retextureOutfit(
        outfit: outfitFile,
        collectionId: widget.collectionId,
        outfitType: widget.selectedModel.toLowerCase(),
      );

      if (!mounted) return;
      setState(() => _statusMessage = 'Finalizing...');
      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => TryonPreviewScreen(
            selectedModel: widget.selectedModel,
            selectedPattern: widget.selectedPattern,
            patternedOutfitUrl: applied.appliedModelUrl,
            collectionId: widget.collectionId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _statusMessage = 'Error: ${e.toString().replaceFirst('Exception: ', '')}',
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to apply pattern: ${e.toString().replaceFirst('Exception: ', '')}',
            style: GoogleFonts.montserrat(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (outfitFile != null) {
        try {
          await outfitFile.delete();
        } catch (_) {}
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
          'Virtual-TryOn',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _statusMessage,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4A7C59),
                ),
                textAlign: TextAlign.center,
              ),
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
