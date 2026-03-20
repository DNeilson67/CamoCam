import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final supabase = Supabase.instance.client;
  
  // Bucket name in Supabase (change this to your bucket name)
  static const String _bucketName = 'camouflage-patterns'; // Update this

  /// Fetch all image URLs from a user's folder in the bucket
  /// Assumes structure: bucket/userId/image.jpg
  Future<List<String>> getUserModelImages(String userId) async {
    try {
      // First, list all folders in the bucket root
      final List<FileObject> allItems = 
          await supabase.storage.from(_bucketName).list();

      print('All items in bucket: ${allItems.map((e) => e.name).toList()}');

      // Find the user's folder (contains userId in the name)
      final userFolder = allItems.firstWhere(
        (item) => item.name.contains(userId),
        orElse: () => throw Exception('User folder not found for userId: $userId'),
      );

      print('Found user folder: ${userFolder.name}');

      // List all files in the user's folder
      final List<FileObject> files = 
          await supabase.storage.from(_bucketName).list(path: userFolder.name);

      print('Files in user folder: ${files.map((e) => e.name).toList()}');

      // Filter for image files and generate public URLs
      List<String> imageUrls = [];
      for (var file in files) {
        // Check if file is an image (add more extensions if needed)
        if (file.name.toLowerCase().endsWith('.jpg') ||
            file.name.toLowerCase().endsWith('.jpeg') ||
            file.name.toLowerCase().endsWith('.png') ||
            file.name.toLowerCase().endsWith('.gif') ||
            file.name.toLowerCase().endsWith('.webp')) {
          final publicUrl = supabase.storage
              .from(_bucketName)
              .getPublicUrl('${userFolder.name}/${file.name}');
          imageUrls.add(publicUrl);
          print('Added image: $publicUrl');
        }
      }

      print('Total images found: ${imageUrls.length}');
      return imageUrls;
    } catch (e) {
      print('Error fetching user model images: $e');
      return [];
    }
  }

  /// Debug: List all items in the bucket
  Future<List<String>> getAllBucketItems() async {
    try {
      final List<FileObject> items = 
          await supabase.storage.from(_bucketName).list();
      return items.map((e) => e.name).toList();
    } catch (e) {
      print('Error listing bucket items: $e');
      return [];
    }
  }

  /// Get a public URL for a specific image
  String getImageUrl(String userId, String fileName) {
    return supabase.storage
        .from(_bucketName)
        .getPublicUrl('$userId/$fileName');
  }

  /// Upload an image to user's folder
  Future<bool> uploadModelImage(
    String userId,
    String filePath,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      await supabase.storage.from(_bucketName).uploadBinary(
            '$userId/$fileName',
            fileBytes,
            fileOptions: const FileOptions(upsert: false),
          );
      return true;
    } catch (e) {
      print('Error uploading image: $e');
      return false;
    }
  }
}
