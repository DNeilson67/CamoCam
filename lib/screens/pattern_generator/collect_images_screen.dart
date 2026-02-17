import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'loading_screen.dart';

class CollectImagesScreen extends StatefulWidget {
  const CollectImagesScreen({super.key});

  @override
  State<CollectImagesScreen> createState() => _CollectImagesScreenState();
}

class _CollectImagesScreenState extends State<CollectImagesScreen> {
  final List<File?> _images = List.filled(9, null);
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _images[index] = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
  }

  int get _imageCount => _images.where((img) => img != null).length;

  bool get _canGenerate => _imageCount > 0;

  void _generatePattern() {
    if (_canGenerate) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoadingScreen(
            images: _images.where((img) => img != null).cast<File>().toList(),
          ),
        ),
      );
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
          'Pattern Generator',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 25, right: 25, bottom: 84),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  'Let\'s get started',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF292929),
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 7),

                // Description
                Text(
                  'Capture up to 9 images to generate your camouflage pattern',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF727272),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 50),

                // 3x3 Grid
                _buildImageGrid(),

                const SizedBox(height: 146),

                // Generate Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _canGenerate ? _generatePattern : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canGenerate
                          ? const Color(0xFF68B0AB)
                          : const Color(0xFFB1BBBA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFFB1BBBA),
                    ),
                    child: Text(
                      'Generate Pattern',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return SizedBox(
      width: 364,
      child: Column(
        children: [
          _buildImageRow(0, 1, 2),
          const SizedBox(height: 25),
          _buildImageRow(3, 4, 5),
          const SizedBox(height: 25),
          _buildImageRow(6, 7, 8),
        ],
      ),
    );
  }

  Widget _buildImageRow(int index1, int index2, int index3) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildImageSlot(index1),
        _buildImageSlot(index2),
        _buildImageSlot(index3),
      ],
    );
  }

  Widget _buildImageSlot(int index) {
    final hasImage = _images[index] != null;

    return GestureDetector(
      onTap: hasImage ? null : () => _pickImage(index),
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasImage
                    ? const Color(0xFF4A7C59)
                    : const Color(0xFF797777),
                width: 2,
                style: hasImage ? BorderStyle.solid : BorderStyle.solid,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(_images[index]!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? null
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF797777),
                        width: 2,
                        style: BorderStyle.values[1], // dashed
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 26,
                        color: const Color(0xFF4A7C59),
                      ),
                    ),
                  ),
          ),

          // Delete button overlay
          if (hasImage)
            Positioned(
              top: -6,
              right: -6,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFCF3017),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
