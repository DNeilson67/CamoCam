/// Single source of truth for the backend API base URL.
///
/// `10.0.2.2` is the Android emulator's alias for the host machine's localhost.
/// For a physical device on the same Wi-Fi, swap this for your PC's LAN IP,
/// e.g. `http://192.168.1.50:8000/api`.
class ApiConfig {
  static const String baseUrl = 'https://17ab-203-10-91-94.ngrok-free.app/api';
}
