// ignore_for_file: deprecated_member_use

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/camera_provider.dart';
import '../widgets/camera_controls.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/permission_widget.dart';
import 'image_preview_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final String mode;

  const CameraScreen({
    super.key,
    required this.mode,
  });

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        ref.read(cameraProvider.notifier).initializeCamera();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    
    // Properly dispose camera
    Future.microtask(() {
      ref.read(cameraProvider.notifier).disposeCamera();
    });
    
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    final cameraNotifier = ref.read(cameraProvider.notifier);

    switch (state) {
      case AppLifecycleState.paused:
        cameraNotifier.pauseCamera();
        break;
      case AppLifecycleState.resumed:
        cameraNotifier.resumeCamera();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        cameraNotifier.disposeCamera();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Future<void> _handleCapture() async {
    if (_isDisposed) return;

    final cameraState = ref.read(cameraProvider);
    
    // Prevent capture if already capturing
    if (cameraState.isCapturing) {
      debugPrint('Already capturing, ignoring tap');
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final capturedImage = await ref.read(cameraProvider.notifier).captureImage();

      // Dismiss loading
      if (mounted && !_isDisposed) {
        Navigator.of(context).pop();
      }

      if (capturedImage != null && mounted && !_isDisposed) {
        // Navigate to preview screen
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImagePreviewScreen(
              imageFile: capturedImage,
              mode: widget.mode,
            ),
          ),
        );
      } else if (mounted && !_isDisposed) {
        _showError('Failed to capture image');
      }
    } catch (e) {
      // Dismiss loading
      if (mounted && !_isDisposed) {
        Navigator.of(context).pop();
        _showError('Error capturing image: $e');
      }
    }
  }

  void _showError(String message) {
    if (!mounted || _isDisposed) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          // Ensure camera is disposed when back button is pressed
          await ref.read(cameraProvider.notifier).disposeCamera();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Camera Preview or Loading
            if (cameraState.isLoading)
              _buildLoadingState()
            else if (!cameraState.hasPermission)
              const PermissionWidget()
            else if (cameraState.error != null)
              _buildErrorState(cameraState.error!)
            else if (cameraState.isInitialized && cameraState.controller != null)
              _buildCameraPreview(cameraState.controller!)
            else
              _buildLoadingState(),

            // Overlay and Controls (only show when camera is ready)
            if (cameraState.isInitialized && 
                cameraState.controller != null && 
                !cameraState.isCapturing) ...[
              // Camera Overlay
              const Positioned.fill(
                child: CameraOverlay(),
              ),

              // Instructions
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 0,
                right: 0,
                child: _buildInstructions(),
              ),

              // Controls at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: CameraControls(
                  onCapture: _handleCapture,
                ),
              ),
            ],

            // Capturing indicator
            if (cameraState.isCapturing)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(CameraController controller) {
    final size = MediaQuery.of(context).size;
    final scale = size.aspectRatio * controller.value.aspectRatio;

    return Transform.scale(
      scale: scale < 1 ? 1 / scale : scale,
      child: Center(
        child: CameraPreview(controller),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 24),
            Text(
              'Initializing camera...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 80,
                color: AppColors.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Camera Error',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(cameraProvider.notifier).initializeCamera();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    final title = widget.mode == 'register' 
        ? 'Register New Face' 
        : 'Recognize Face';
    
    final subtitle = widget.mode == 'register'
        ? 'Position your face in the oval'
        : 'Look at the camera to identify';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}