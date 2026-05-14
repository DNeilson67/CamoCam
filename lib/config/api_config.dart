import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Single source of truth for the backend API base URL.
///
/// Loads configuration from `.env` file using flutter_dotenv.
/// Fallback to ngrok URL if environment variable is not set.
///
/// Environment:
/// - `API_BASE_URL`: Backend API base URL (e.g., http://localhost:8000/api)
class ApiConfig {
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url != null && url.isNotEmpty) {
      return url;
    }
    // Fallback URL
    return 'http://10.0.2.2:8000/api';
  }
}
