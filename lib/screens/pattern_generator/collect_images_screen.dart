import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiple_image_camera/multiple_image_camera.dart';
import 'package:multiple_image_camera/camera_file.dart';
import 'loading_screen.dart';

class CollectImagesScreen extends StatefulWidget {
  const CollectImagesScreen({super.key});

  @override
  State<CollectImagesScreen> createState() => _CollectImagesScreenState();
}

class _CollectImagesScreenState extends State<CollectImagesScreen> {
  final List<File?> _images = List.filled(9, null);
  final ImagePicker _picker = ImagePicker();

  int get _emptySlots => _images.where((img) => img == null).length;

  void _addImages(List<File> newImages) {
    setState(() {
      int added = 0;
      for (int i = 0; i < _images.length && added < newImages.length; i++) {
        if (_images[i] == null) {
          _images[i] = newImages[added];
          added++;
        }
      }
    });
  }

  Future<void> _pickFromCamera() async {
    if (_emptySlots == 0) return;
    try {
      final List<MediaModel> result = await MultipleImageCamera.capture(
        context: context,
      );
      if (result.isNotEmpty) {
        _addImages(result.map((m) => m.file).toList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_emptySlots == 0) return;
    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked.isNotEmpty) {
        _addImages(picked.map((f) => File(f.path)).toList());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: ${e.toString()}')),
        );
      }
    }
  }

  void _showPickerOptions() {
    if (_emptySlots == 0) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4A7C59)),
              title: Text(
                'Camera',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF4A7C59),
              ),
              title: Text(
                'Gallery',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images[index] = null;
    });
  }

  void _showImagePreview(int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.file(_images[index]!, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _removeImage(index);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFCF3017),
                      size: 18,
                    ),
                    label: Text(
                      'Remove',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFCF3017),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFCF3017),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      'Keep',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7C59),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _canGenerate ? _generatePattern : null,
                    icon: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Generate Pattern',
                      style: GoogleFonts.montserrat(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.14,
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: hasImage ? () => _showImagePreview(index) : _showPickerOptions,
          child: hasImage
              ? Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF4A7C59),
                      width: 2,
                    ),
                    image: DecorationImage(
                      image: FileImage(_images[index]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(10),
                  color: const Color(0xFF797777),
                  strokeWidth: 2,
                  dashPattern: const [6, 4],
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 26,
                        color: const Color(0xFF4A7C59),
                      ),
                    ),
                  ),
                ),
        ),

        // Delete button — outside clip bounds so it sits above the border
        if (hasImage)
          Positioned(
            top: -8,
            right: -8,
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
    );
  }
}
