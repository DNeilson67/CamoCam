import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../services/ar_service.dart';
import 'ar_preview_model_screen.dart';

class ArLoadingScreen extends StatefulWidget {
  final String selectedModel;
  final int selectedItemId;
  final CollectionDetailResponse selectedCollection;
  final String modelName;

  const ArLoadingScreen({
    Key? key,
    required this.selectedModel,
    required this.selectedItemId,
    required this.selectedCollection,
    required this.modelName,
  }) : super(key: key);

  @override
  State<ArLoadingScreen> createState() => _ArLoadingScreenState();
}

class _ArLoadingScreenState extends State<ArLoadingScreen> {
  late ArService _arService;
  String _statusMessage = 'Preparing pattern application...';

  @override
  void initState() {
    super.initState();
    _arService = ArService();
    _applyPatternAndNavigate();
  }

  Future<File> _downloadFile(String path, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');

    try {
      if (path.startsWith('assets/')) {
        // Handle local assets
        final byteData = await rootBundle.load(path);
        await file.writeAsBytes(byteData.buffer.asUint8List());
      } else {
        // Handle remote URLs
        final client = HttpClient();
        client.connectionTimeout = const Duration(seconds: 30);

        final request = await client.getUrl(Uri.parse(path));
        final response = await request.close();

        if (response.statusCode == 200) {
          final bytes = await response.fold<List<int>>(
            <int>[],
            (previous, element) => previous..addAll(element),
          );
          await file.writeAsBytes(bytes);
        } else {
          throw Exception('Failed to download file: ${response.statusCode}');
        }
      }
      return file;
    } catch (e) {
      throw Exception('Download error: $e');
    }
  }

  Future<void> _applyPatternAndNavigate() async {
    try {
      setState(() => _statusMessage = 'Downloading model...');

      // Download model file
      final modelFile = await _downloadFile(
        'assets/objects/models/helicopter/helicopter.glb',
        'model.glb',
      );

      setState(() => _statusMessage = 'Applying pattern to model...');

      // Call apply pattern and save endpoint
      final applied = await _arService.applyPatternAndSave(
        modelFile: modelFile,
        collectionId: widget.selectedCollection.collectionId,
      );

      // Clean up temp files
      await modelFile.delete();

      if (!mounted) return;

      setState(() => _statusMessage = 'Finalizing...');

      // Small delay for visual feedback
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Navigate to preview screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ArPreviewModelScreen(
            selectedModel: widget.selectedModel,
            appliedModelUrl: applied.appliedModelUrl,
            selectedCollectionTitle: widget.selectedCollection.title,
            modelName: widget.modelName,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Show error message on loading screen, then navigate back
      setState(
        () => _statusMessage =
            'Error: ${e.toString().replaceFirst('Exception: ', '')}',
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error applying pattern: ${e.toString().replaceFirst('Exception: ', '')}',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Augmented Reality',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
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
