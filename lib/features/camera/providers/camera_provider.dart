import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Camera State Model
class CameraState {
  final CameraController? controller;
  final bool isInitialized;
  final bool isLoading;
  final String? error;
  final bool hasPermission;
  final List<CameraDescription> cameras;
  final bool isCapturing;

  const CameraState({
    this.controller,
    this.isInitialized = false,
    this.isLoading = false,
    this.error,
    this.hasPermission = false,
    this.cameras = const [],
    this.isCapturing = false,
  });

  CameraState copyWith({
    CameraController? controller,
    bool? isInitialized,
    bool? isLoading,
    String? error,
    bool? hasPermission,
    List<CameraDescription>? cameras,
    bool? isCapturing,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasPermission: hasPermission ?? this.hasPermission,
      cameras: cameras ?? this.cameras,
      isCapturing: isCapturing ?? this.isCapturing,
    );
  }
}

// Camera Notifier with Riverpod 3.x
class CameraNotifier extends Notifier<CameraState> {
  @override
  CameraState build() {
    // Cleanup when provider is disposed
    ref.onDispose(() {
      _disposeController();
    });
    
    return const CameraState();
  }

  // Initialize Camera
  Future<void> initializeCamera({
    CameraLensDirection direction = CameraLensDirection.front,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'No cameras found on this device',
          cameras: cameras,
          hasPermission: false,
        );
        return;
      }

      state = state.copyWith(cameras: cameras, hasPermission: true);

      // Select camera based on direction
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == direction,
        orElse: () => cameras.first,
      );

      // Create controller with proper configuration
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      // Initialize controller
      await controller.initialize();

      state = state.copyWith(
        controller: controller,
        isInitialized: true,
        isLoading: false,
      );
    } on CameraException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'CameraAccessDenied':
          errorMessage = 'Camera permission denied. Please enable camera access in settings.';
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          errorMessage = 'Camera permission permanently denied. Please enable in device settings.';
          break;
        case 'CameraAccessRestricted':
          errorMessage = 'Camera access is restricted on this device.';
          break;
        case 'AudioAccessDenied':
          errorMessage = 'Microphone permission denied.';
          break;
        default:
          errorMessage = 'Camera error: ${e.description ?? e.code}';
      }
      
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        hasPermission: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize camera: ${e.toString()}',
        hasPermission: false,
      );
    }
  }

  // Request Permission
  Future<void> requestPermission() async {
    await initializeCamera();
  }

  // Switch Camera
  Future<void> switchCamera() async {
    if (state.cameras.length < 2 || state.isCapturing) return;

    try {
      final currentDirection = state.controller?.description.lensDirection;
      final newDirection = currentDirection == CameraLensDirection.front
          ? CameraLensDirection.back
          : CameraLensDirection.front;

      // Properly dispose current controller
      await _disposeController();

      // Initialize with new direction
      await initializeCamera(direction: newDirection);
    } catch (e) {
      state = state.copyWith(error: 'Failed to switch camera: ${e.toString()}');
    }
  }

  // Capture Image - FIXED VERSION
  Future<File?> captureImage() async {
    // Prevent multiple simultaneous captures
    if (state.isCapturing) {
      debugPrint('Already capturing, ignoring request');
      return null;
    }

    if (state.controller == null || !state.isInitialized) {
      state = state.copyWith(error: 'Camera not initialized');
      return null;
    }

    try {
      // Set capturing flag
      state = state.copyWith(isCapturing: true);

      // Small delay to ensure camera is ready
      await Future.delayed(const Duration(milliseconds: 100));

      // Check if controller is still valid
      if (!state.controller!.value.isInitialized) {
        throw CameraException('Camera not ready', 'Controller not initialized');
      }

      // Capture image
      final XFile image = await state.controller!.takePicture();

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final imagePath = path.join(
        directory.path,
        'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Copy to temp directory
      final File imageFile = File(image.path);
      
      // Verify file exists
      if (!await imageFile.exists()) {
        throw Exception('Captured image file not found');
      }

      final File savedImage = await imageFile.copy(imagePath);

      // Delete original file to free resources
      try {
        await imageFile.delete();
      } catch (e) {
        debugPrint('Failed to delete original image: $e');
      }

      // Reset capturing flag
      state = state.copyWith(isCapturing: false);

      return savedImage;
    } catch (e) {
      debugPrint('Capture error: $e');
      state = state.copyWith(
        error: 'Failed to capture image: ${e.toString()}',
        isCapturing: false,
      );
      return null;
    }
  }

  // Set Flash Mode
  Future<void> setFlashMode(FlashMode mode) async {
    try {
      await state.controller?.setFlashMode(mode);
    } catch (e) {
      state = state.copyWith(error: 'Failed to set flash mode: ${e.toString()}');
    }
  }

  // Properly dispose controller
  Future<void> _disposeController() async {
    try {
      final controller = state.controller;
      if (controller != null) {
        // Stop image stream if active
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        
        // Dispose controller
        await controller.dispose();
      }
    } catch (e) {
      debugPrint('Error disposing controller: $e');
    }
  }

  // Dispose Camera - PUBLIC method
  Future<void> disposeCamera() async {
    await _disposeController();
    state = const CameraState();
  }

  // Pause Camera (for lifecycle management)
  Future<void> pauseCamera() async {
    try {
      if (state.controller != null && state.controller!.value.isInitialized) {
        debugPrint('Camera paused');
      }
    } catch (e) {
      debugPrint('Error pausing camera: $e');
    }
  }

  // Resume Camera
  Future<void> resumeCamera() async {
    try {
      if (state.controller == null || !state.controller!.value.isInitialized) {
        await initializeCamera();
      }
    } catch (e) {
      debugPrint('Error resuming camera: $e');
    }
  }

  // Clear Error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider Definition - Riverpod 3.x style
final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(() {
  return CameraNotifier();
});