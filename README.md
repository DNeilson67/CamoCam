# CamoCam - Frontend

An AI-powered camouflage pattern generator with AR visualization built with Flutter. Apply dynamic camouflage patterns to 3D items and see realistic previews in real-time.

## Features

- **Pattern Generation**: Upload environment images to generate unique camouflage patterns using AI
- **AR Visualization**: View 3D models with applied patterns in augmented reality
- **Pattern Collections**: Save and manage multiple camouflage pattern collections
- **Secure Authentication**: Google Sign-in integration with Supabase
- **Image & Model Handling**: Optimized image and 3D model processing

## Prerequisites

- **Flutter**: 3.10.4 or higher
- **Dart**: 3.10.4 or higher
- **Android**: API 21+ (for Android builds)
- **iOS**: iOS 12+ (for iOS builds)
- **Backend API**: CamoCam-BE running and accessible

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/camocam.git
cd camocam
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Endpoint

Update the API configuration in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Local development
  static const String baseUrl = 'http://localhost:8000/api';
  
  // Or remote (e.g., ngrok tunnel or deployed backend)
  // static const String baseUrl = 'https://your-backend-url/api';
}
```

### 4. Configure Firebase (Optional, if using Firebase features)

If using Firebase features:

```bash
flutter pub global activate flutterfire_cli
flutterfire configure
```

### 5. Run the App

**Android:**
```bash
flutter run -d android
```

**iOS:**
```bash
flutter run -d ios
```

## Project Structure

```
lib/
├── config/              # API and app configuration
├── core/
│   ├── constants/       # App colors, dimensions, text styles
│   └── utils/           # Utilities and helpers
├── models/              # Data models
├── screens/             # UI screens
│   ├── home/            # Home screen
│   ├── pattern_generator/    # Pattern generation workflow
│   ├── ar/              # AR visualization screens
│   ├── profile/         # User profile
│   └── onboarding/      # Onboarding flow
├── services/            # Business logic and API calls
│   ├── ar_service.dart  # AR API
│   ├── collection_service.dart  # Pattern collection API
│   └── storage_service.dart     # Image storage
├── widgets/             # Reusable widgets
├── firebase_options.dart    # Firebase configuration
└── main.dart            # App entry point
```

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `supabase_flutter` | ^2.12.0 | Backend & authentication |
| `image_picker` | ^1.0.7 | Image selection from gallery/camera |
| `model_viewer_plus` | ^1.8.0 | 3D model viewing |
| `cached_network_image` | ^3.4.1 | Image caching |
| `google_sign_in` | ^7.2.0 | Google authentication |
| `http` | ^1.2.0 | HTTP requests |
| `carousel_slider` | ^5.0.0 | Image carousels |
| `google_fonts` | ^6.2.1 | Custom fonts |

## Usage

### 1. Onboarding & Authentication

- First-time users see the onboarding flow
- Google Sign-in for secure authentication
- Supabase handles user session management

### 2. Pattern Generation

1. Navigate to **Pattern Generator**
2. Capture/upload 1-9 environment images
3. AI generates a unique camouflage pattern (~2 minutes)
4. Pattern is saved to your collection

### 3. AR Visualization

1. Select a pattern and 3D model
2. View the textured model in augmented reality
3. Rotate and inspect from all angles

## API Integration

The app communicates with the backend API at:
- **Base URL**: Configured in `lib/config/api_config.dart`
- **Timeout**: 30 minutes for long-running operations (pattern generation)

### Key Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/collections` | POST | Create pattern collection |
| `/api/collections/me` | GET | Get user's collections |
| `/api/apply-pattern-and-save` | POST | Apply pattern to 3D model |
| `/items` | GET | Get available 3D models |

## Development

### Running Debug Application

```bash
flutter run
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.


## Related

- [CamoCam Backend](../CamoCam-BE) - FastAPI backend with AI pattern generation
