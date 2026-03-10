import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PatternDetailScreen extends StatefulWidget {
  final String patternName;
  final int patternIndex;

  const PatternDetailScreen({
    super.key,
    required this.patternName,
    required this.patternIndex,
  });

  @override
  State<PatternDetailScreen> createState() => _PatternDetailScreenState();
}

class _PatternDetailScreenState extends State<PatternDetailScreen> {
  late String _patternName;

  @override
  void initState() {
    super.initState();
    _patternName = widget.patternName;
  }

  void _showRenameDialog() {
    final controller = TextEditingController(text: _patternName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Rename Pattern',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          style: GoogleFonts.montserrat(),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.montserrat(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) setState(() => _patternName = newName);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A7C59),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.montserrat(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sample images for the pattern
    final List<String> imageUrls = [
      'https://www.figma.com/api/mcp/asset/2537e162-7219-4cdb-bb9f-3dc2454d39b3',
      'https://www.figma.com/api/mcp/asset/9d69d439-b79b-4f84-b3a1-c9a1d63e57c4',
      'https://www.figma.com/api/mcp/asset/56c1fdfc-9b70-42e2-94f9-ddb3dc66374b',
      'https://www.figma.com/api/mcp/asset/10bf3164-2399-4792-ab89-44ae4e8354d6',
    ];

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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final squareSize = constraints.maxWidth - 46;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 23),
                child: Column(
                  children: [
                    const SizedBox(height: 24),

                    // Pattern name with tappable edit icon
                    GestureDetector(
                      onTap: _showRenameDialog,
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
                                height: 1.0,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Color(0xFF4A7C59),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Pattern preview — explicit square
                    SizedBox(
                      width: squareSize,
                      height: squareSize,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: const Color(0xFF4A7C59),
                            width: 5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://www.figma.com/api/mcp/asset/e29b790b-13f6-4085-aab8-d2d2c482f105',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Icon(Icons.pattern, size: 60),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Used Images Title
                    Text(
                      'Used Images',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF292929),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Image Grid
                    _buildImageGrid(imageUrls),

                    const SizedBox(height: 20),

                    // Delete Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _showDeleteConfirmation(context);
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Color(0xFFFFE9E5),
                          size: 20,
                        ),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFE9E5),
                            height: 1.14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFCF3017),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  Widget _buildImageRow(
    List<String> imageUrls,
    int index1,
    int index2,
    int index3,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _buildImageSlot(imageUrls, index1)),
        const SizedBox(width: 10),
        Expanded(child: _buildImageSlot(imageUrls, index2)),
        const SizedBox(width: 10),
        Expanded(child: _buildImageSlot(imageUrls, index3)),
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
            color: hasImage ? const Color(0xFF4A7C59) : const Color(0xFF797777),
            width: 2,
          ),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 40),
                    );
                  },
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF797777),
                    width: 2,
                    style: BorderStyle.values[1],
                  ),
                ),
              ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pattern'),
        content: Text('Are you sure you want to delete $_patternName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to collections
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFCF3017)),
            ),
          ),
        ],
      ),
    );
  }
}
