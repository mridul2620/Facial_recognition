import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../api/api_exceptions.dart';
import '../models/api_response.dart';
import '../models/face_recognition_response.dart';

class FaceRecognitionService {
  final ApiClient _apiClient;

  FaceRecognitionService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // Health Check
  Future<HealthCheckResponse> healthCheck() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.health);
      return HealthCheckResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      debugPrint('Health check error: $e');
      rethrow;
    }
  }

  // Register Face
  Future<FaceRegistrationResponse> registerFace({
    required File imageFile,
    required String name,
    required String email,
    String? phone,
    String? notes,
    Function(double)? onUploadProgress,
  }) async {
    try {
      // Create multipart request
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      // Upload with progress
      final response = await _apiClient.uploadMultipart(
        ApiEndpoints.registerFace,
        formData: formData,
        onSendProgress: onUploadProgress != null
            ? (sent, total) {
                final progress = sent / total;
                onUploadProgress(progress);
              }
            : null,
      );

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => FaceRegistrationResponse.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message ?? 'Registration failed',
        );
      }

      return apiResponse.data!;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Registration error: $e');
      throw ApiException(message: 'Failed to register face: $e');
    }
  }

  // Recognize Face
  Future<FaceRecognitionResponse> recognizeFace({
    required File imageFile,
    double threshold = 0.6,
    int topK = 1,
    Function(double)? onUploadProgress,
  }) async {
    try {
      // Create multipart request
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'recognize_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'threshold': threshold,
        'top_k': topK,
      });

      // Upload with progress
      final response = await _apiClient.uploadMultipart(
        ApiEndpoints.recognizeFace,
        formData: formData,
        onSendProgress: onUploadProgress != null
            ? (sent, total) {
                final progress = sent / total;
                onUploadProgress(progress);
              }
            : null,
      );

      // Parse response
      final apiResponse = ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (data) => FaceRecognitionResponse.fromJson(data as Map<String, dynamic>),
      );

      if (!apiResponse.success || apiResponse.data == null) {
        throw ApiException(
          message: apiResponse.message ?? 'Recognition failed',
        );
      }

      return apiResponse.data!;
    } on ApiException {
      rethrow;
    } catch (e) {
      debugPrint('Recognition error: $e');
      throw ApiException(message: 'Failed to recognize face: $e');
    }
  }
}