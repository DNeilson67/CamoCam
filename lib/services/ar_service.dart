import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ItemResponse {
  final int itemId;
  final String itemType;
  final String item3dModelUrl;
  final String? thumbnailUrl;

  ItemResponse({
    required this.itemId,
    required this.itemType,
    required this.item3dModelUrl,
    this.thumbnailUrl,
  });

  factory ItemResponse.fromJson(Map<String, dynamic> json) {
    return ItemResponse(
      itemId: json['item_id'] as int,
      itemType: json['item_type'] as String,
      item3dModelUrl: json['item_3d_model_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
    );
  }
}

class BaseImageResponse {
  final int imageId;
  final int collectionId;
  final String imageUrl;
  final int uploadOrder;
  final DateTime uploadedAt;

  BaseImageResponse({
    required this.imageId,
    required this.collectionId,
    required this.imageUrl,
    required this.uploadOrder,
    required this.uploadedAt,
  });

  factory BaseImageResponse.fromJson(Map<String, dynamic> json) {
    return BaseImageResponse(
      imageId: json['image_id'] as int,
      collectionId: json['collection_id'] as int,
      imageUrl: json['image_url'] as String,
      uploadOrder: json['upload_order'] as int,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
    );
  }
}

class CollectionDetailResponse {
  final int collectionId;
  final String userId;
  final String title;
  final String? patternImageUrl;
  final DateTime createdAt;
  final List<BaseImageResponse> baseImages;

  CollectionDetailResponse({
    required this.collectionId,
    required this.userId,
    required this.title,
    this.patternImageUrl,
    required this.createdAt,
    required this.baseImages,
  });

  factory CollectionDetailResponse.fromJson(Map<String, dynamic> json) {
    final baseImagesJson = json['base_images'] as List<dynamic>? ?? [];
    return CollectionDetailResponse(
      collectionId: json['collection_id'] as int,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      patternImageUrl: json['pattern_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      baseImages: baseImagesJson
          .cast<Map<String, dynamic>>()
          .map((img) => BaseImageResponse.fromJson(img))
          .toList(),
    );
  }
}

class AppliedPatternResponse {
  final int appliedId;
  final String userId;
  final int collectionId;
  final int? itemId;
  final String appliedModelUrl;
  final String? thumbnailUrl;
  final String? title;
  final DateTime createdAt;

  AppliedPatternResponse({
    required this.appliedId,
    required this.userId,
    required this.collectionId,
    this.itemId,
    required this.appliedModelUrl,
    this.thumbnailUrl,
    this.title,
    required this.createdAt,
  });

  factory AppliedPatternResponse.fromJson(Map<String, dynamic> json) {
    return AppliedPatternResponse(
      appliedId: json['applied_id'] as int,
      userId: json['user_id'] as String,
      collectionId: json['collection_id'] as int,
      itemId: json['item_id'] as int?,
      appliedModelUrl: json['applied_model_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      title: json['title'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ArService {
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

  /// Get all available AR items (3D models)
  Future<List<ItemResponse>> getItems() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items/'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .cast<Map<String, dynamic>>()
            .map((item) => ItemResponse.fromJson(item))
            .toList();
      }

      throw Exception('Failed to fetch items (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching items: $e');
    }
  }

  /// Get a specific item by ID
  Future<ItemResponse> getItem(int itemId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/items/$itemId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return ItemResponse.fromJson(json);
      }

      throw Exception('Failed to fetch item (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching item: $e');
    }
  }

  /// Get all collections for the current user
  Future<List<CollectionDetailResponse>> getUserCollections() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated. Please sign in.');
    }
    final token = session.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/collections/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .cast<Map<String, dynamic>>()
            .map((col) => CollectionDetailResponse.fromJson(col))
            .toList();
      }

      throw Exception('Failed to fetch collections (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching collections: $e');
    }
  }

  /// Get a specific collection by ID
  Future<CollectionDetailResponse> getCollection(int collectionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/collections/$collectionId'),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return CollectionDetailResponse.fromJson(json);
      }

      throw Exception('Failed to fetch collection (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching collection: $e');
    }
  }

  /// Apply a pattern to a 3D model and save the result
  /// Returns the applied pattern response with the saved model URL
  Future<AppliedPatternResponse> applyPatternAndSave({
    required File modelFile,
    required int collectionId,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated. Please sign in.');
    }
    final token = session.accessToken;

    final uri = Uri.parse('$_baseUrl/apply-pattern-and-save');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['collection_id'] = collectionId.toString();

    // Add model file
    request.files.add(
      await http.MultipartFile.fromPath(
        'model',
        modelFile.path,
        contentType: MediaType('model', 'gltf-binary'),
      ),
    );

    try {
      final streamed = await request.send().timeout(const Duration(minutes: 5));
      final body = await streamed.stream.bytesToString();

      if (streamed.statusCode == 201) {
        final json = jsonDecode(body) as Map<String, dynamic>;
        return AppliedPatternResponse.fromJson(json);
      }

      throw Exception('Failed to apply pattern (${streamed.statusCode}): $body');
    } catch (e) {
      throw Exception('Error applying pattern: $e');
    }
  }

  /// Get all applied patterns for the current user
  Future<List<AppliedPatternResponse>> getUserAppliedPatterns() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated. Please sign in.');
    }
    final token = session.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/applied-patterns/'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .cast<Map<String, dynamic>>()
            .map((pattern) => AppliedPatternResponse.fromJson(pattern))
            .toList();
      }

      throw Exception('Failed to fetch applied patterns (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching applied patterns: $e');
    }
  }

  /// Get applied patterns for a specific collection
  Future<List<AppliedPatternResponse>> getCollectionAppliedPatterns(
      int collectionId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated. Please sign in.');
    }
    final token = session.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/applied-patterns/collection/$collectionId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as List<dynamic>;
        return json
            .cast<Map<String, dynamic>>()
            .map((pattern) => AppliedPatternResponse.fromJson(pattern))
            .toList();
      }

      throw Exception('Failed to fetch applied patterns (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching applied patterns: $e');
    }
  }

  /// Get a specific applied pattern
  Future<AppliedPatternResponse> getAppliedPattern(int appliedId) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated. Please sign in.');
    }
    final token = session.accessToken;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/applied-patterns/$appliedId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return AppliedPatternResponse.fromJson(json);
      }

      throw Exception('Failed to fetch applied pattern (${response.statusCode}): ${response.body}');
    } catch (e) {
      throw Exception('Error fetching applied pattern: $e');
    }
  }

  String _getMimeType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
