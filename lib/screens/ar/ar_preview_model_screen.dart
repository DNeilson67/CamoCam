import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/model_viewer_screen.dart';

class ArPreviewModelScreen extends StatefulWidget {
  final String selectedModel;
  final String appliedModelUrl;
  final String selectedCollectionTitle;

  const ArPreviewModelScreen({
    super.key,
    required this.selectedModel,
    required this.appliedModelUrl,
    required this.selectedCollectionTitle,
  });

  @override
  State<ArPreviewModelScreen> createState() => _ArPreviewModelScreenState();
}

class _ArPreviewModelScreenState extends State<ArPreviewModelScreen> {
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 55),

                      // Title
                      Text(
                        'Preview Your Blended Model',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF292929),
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Description
                      Text(
                        'See how your chosen pattern applies to the object before entering AR mode.',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF727272),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 55),

                      // 3D Model Preview
                      SizedBox(
                        height: 271,
                        child: Center(
                          child: Container(
                            width: 406,
                            height: 271,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.view_in_ar,
                              size: 100,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Pattern Name with Edit Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.selectedCollectionTitle,
                            style: GoogleFonts.montserrat(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF292929),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.edit_outlined,
                            size: 21,
                            color: Color(0xFF292929),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom bar with buttons
            Container(
              padding: const EdgeInsets.fromLTRB(21, 18, 21, 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFFE7E7E7),
                    width: 2,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFE7E7E7),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 24),
                      color: const Color(0xFF1A1A1A),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),

                  // View 3D Model Button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ModelViewerScreen(
                                modelName:
                                    '${widget.selectedModel} - ${widget.selectedCollectionTitle}',
                                modelUrl: widget.appliedModelUrl,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.view_in_ar,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          'View 3D Model',
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
}
