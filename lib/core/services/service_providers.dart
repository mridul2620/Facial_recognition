import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import 'face_recognition_service.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Face Recognition Service Provider
final faceRecognitionServiceProvider = Provider<FaceRecognitionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FaceRecognitionService(apiClient: apiClient);
});