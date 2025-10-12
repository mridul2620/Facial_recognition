import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/registration_data.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/api/api_exceptions.dart';

// Registration State
enum RegistrationStatus {
  initial,
  compressing,
  submitting,
  success,
  error,
}

class RegistrationState {
  final RegistrationStatus status;
  final String? errorMessage;
  final RegistrationData? data;
  final double? compressionProgress;

  const RegistrationState({
    this.status = RegistrationStatus.initial,
    this.errorMessage,
    this.data,
    this.compressionProgress,
  });

  RegistrationState copyWith({
    RegistrationStatus? status,
    String? errorMessage,
    RegistrationData? data,
    double? compressionProgress,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      data: data ?? this.data,
      compressionProgress: compressionProgress ?? this.compressionProgress,
    );
  }

  bool get isLoading =>
      status == RegistrationStatus.compressing ||
      status == RegistrationStatus.submitting;
}

// Registration Notifier
class RegistrationNotifier extends Notifier<RegistrationState> {
  @override
  RegistrationState build() {
    return const RegistrationState();
  }

  // Compress Image - IMPROVED VERSION
  Future<File?> compressImage(File imageFile) async {
    try {
      debugPrint('Starting compression...');
      state = state.copyWith(
        status: RegistrationStatus.compressing,
        compressionProgress: 0.0,
      );

      // Check if file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      final originalSize = await imageFile.length();
      debugPrint('Original image size: $originalSize bytes');

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final targetPath = path.join(
        directory.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      debugPrint('Target path: $targetPath');

      // Compress image
      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: 800,
        minHeight: 800,
        format: CompressFormat.jpeg,
      );

      debugPrint('Compression result: ${result?.path}');

      if (result == null) {
        throw Exception('Compression returned null');
      }

      final compressedFile = File(result.path);

      // Verify compressed file exists
      if (!await compressedFile.exists()) {
        throw Exception('Compressed file was not created');
      }

      final compressedSize = await compressedFile.length();
      final ratio = (compressedSize / originalSize * 100).toStringAsFixed(1);
      
      debugPrint('Compressed image size: $compressedSize bytes');
      debugPrint('Compression ratio: $ratio%');

      // Update state to success
      state = state.copyWith(
        status: RegistrationStatus.initial,
        compressionProgress: 1.0,
        errorMessage: null,
      );

      return compressedFile;
    } catch (e, stackTrace) {
      debugPrint('Compression error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: 'Compression failed: $e',
      );
      
      return null;
    }
  }

  // Submit Registration
  Future<bool> submitRegistration({
    required String name,
    required String email,
    String? phone,
    String? notes,
    required File imageFile,
  }) async {
    try {
      state = state.copyWith(status: RegistrationStatus.submitting);

      // Get the service
      final service = ref.read(faceRecognitionServiceProvider);

      // Call API
      final response = await service.registerFace(
        imageFile: imageFile,
        name: name,
        email: email,
        phone: phone,
        notes: notes,
        onUploadProgress: (progress) {
          debugPrint('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
        },
      );

      debugPrint('Registration successful:');
      debugPrint('User ID: ${response.userId}');
      debugPrint('FAISS Index ID: ${response.faissIndexId}');
      debugPrint('Quality Score: ${response.qualityScore}');

      // Create registration data
      final registrationData = RegistrationData(
        name: name,
        email: email,
        phone: phone,
        notes: notes,
        imageFile: imageFile,
      );

      state = state.copyWith(
        status: RegistrationStatus.success,
        data: registrationData,
      );

      return true;
    } on ApiException catch (e) {
      debugPrint('API error: ${e.message}');
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      debugPrint('Registration error: $e');
      state = state.copyWith(
        status: RegistrationStatus.error,
        errorMessage: 'Failed to register: $e',
      );
      return false;
    }
  }

  // Reset state
  void reset() {
    state = const RegistrationState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(
      status: RegistrationStatus.initial,
      errorMessage: null,
    );
  }
}

// Provider Definition
final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(() {
  return RegistrationNotifier();
});