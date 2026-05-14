import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/api_config.dart';

class CollectionResponse {
  final int collectionId;
  final String userId;
  final String title;
  final String? patternImageUrl;
  final DateTime createdAt;

  CollectionResponse({
    required this.collectionId,
    required this.userId,
    required this.title,
    this.patternImageUrl,
    required this.createdAt,
  });

  factory CollectionResponse.fromJson(Map<String, dynamic> json) {
    return CollectionResponse(
      collectionId: json['collection_id'] as int,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      patternImageUrl: json['pattern_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class CollectionService {
  static final String _baseUrl = ApiConfig.baseUrl;

  Future<CollectionResponse> createCollection({
    required String title,
    required List<File> images,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      throw Exception('Not authenticated. Please sign in.');
    }
    final token = session.accessToken;

    final uri = Uri.parse('$_baseUrl/collections/');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['title'] = title;

    for (final image in images) {
      final filename = image.path.split('/').last.split('\\').last;
      final mimeStr = _mimeType(filename);
      final parts = mimeStr.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          contentType: MediaType(parts[0], parts[1]),
        ),
      );
    }

    final streamed = await request.send().timeout(const Duration(minutes: 30));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode == 201) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return CollectionResponse.fromJson(json);
    }

    throw Exception(
      'Failed to create collection (${streamed.statusCode}): $body',
    );
  }

  String _mimeType(String filename) {
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
