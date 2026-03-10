import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../profile/model_viewer_screen.dart';

class ArPreviewModelScreen extends StatelessWidget {
  final String selectedModel;
  final String selectedPattern;

  const ArPreviewModelScreen({
    super.key,
    required this.selectedModel,
    required this.selectedPattern,
  });

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
                            color: Colors.grey[200],
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
                            'Pattern #1',
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
                  top: BorderSide(color: const Color(0xFFE7E7E7), width: 2),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Reset Button
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
                          icon: const Icon(Icons.refresh, size: 24),
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
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ModelViewerScreen(
                                    modelName:
                                        '$selectedModel - $selectedPattern',
                                    modelUrl: 'assets/models/T34-85.glb',
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.view_in_ar,
                              size: 20,
                              color: Color(0xFF1A1A1A),
                            ),
                            label: Text(
                              'View 3D Model',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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

                      // Go AR Mode Button
                      SizedBox(
                        width: 110,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Opening AR mode...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.view_in_ar,
                            color: Colors.white,
                            size: 18,
                          ),
                          label: Text(
                            'AR',
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
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Save to Your Model Button (Full Width)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Model saved successfully!',
                              style: GoogleFonts.montserrat(),
                            ),
                            backgroundColor: const Color(0xFF4A7C59),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.bookmark_add_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: Text(
                        'Save to Your Model',
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
            ),
          ],
        ),
      ),
    );
  }
}
