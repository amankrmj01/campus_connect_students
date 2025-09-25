// lib/data/services/api_config.dart
class ApiConfig {
  // TODO: Set this to false when real API is ready
  static const bool USE_MOCK_DATA = true;

  // Real API Configuration
  static const String baseUrl = 'https://api.pconnect.com/v1';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Mock API Configuration
  static const bool simulateNetworkDelay = true;
  static const int minDelayMs = 500;
  static const int maxDelayMs = 1500;
}
