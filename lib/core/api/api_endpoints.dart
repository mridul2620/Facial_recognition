class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - CHANGE THIS TO YOUR BACKEND URL
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:8000'; // iOS Simulator
  // static const String baseUrl = 'http://192.168.1.x:8000'; // Real Device (use your PC's IP)

  // API Version
  static const String apiVersion = '/api/v1';

  // Full Base URL
  static String get apiBaseUrl => '$baseUrl$apiVersion';

  // Endpoints
  static const String health = '/health';
  static const String registerFace = '/faces/register';
  static const String recognizeFace = '/faces/recognize';
  static const String getAllUsers = '/users';
  static const String getUserById = '/users/{id}';
  static const String deleteUser = '/users/{id}';
  static const String updateUser = '/users/{id}';

  // Helper methods
  static String getUserByIdUrl(String userId) => '/users/$userId';
  static String deleteUserUrl(String userId) => '/users/$userId';
  static String updateUserUrl(String userId) => '/users/$userId';
}