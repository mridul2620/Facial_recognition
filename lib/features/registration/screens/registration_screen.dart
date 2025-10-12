import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/registration_provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/image_display_card.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final File imageFile;

  const RegistrationScreen({
    super.key,
    required this.imageFile,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  File? _compressedImage;
  bool _isCompressing = false;
  String? _compressionError;

  @override
  void initState() {
    super.initState();
    _compressImage();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _compressImage() async {
    if (!mounted) return;

    setState(() {
      _isCompressing = true;
      _compressionError = null;
    });

    try {
      debugPrint('Starting image compression...');
      
      // Add timeout to prevent infinite loading
      final compressed = await ref
          .read(registrationProvider.notifier)
          .compressImage(widget.imageFile)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('Compression timed out');
              return null;
            },
          );

      if (!mounted) return;

      if (compressed != null) {
        debugPrint('Compression successful: ${compressed.path}');
        setState(() {
          _compressedImage = compressed;
          _isCompressing = false;
        });
      } else {
        debugPrint('Compression failed, using original image');
        // Use original image if compression fails
        setState(() {
          _compressedImage = widget.imageFile;
          _isCompressing = false;
          _compressionError = 'Using original image (compression skipped)';
        });
      }
    } catch (e) {
      debugPrint('Compression exception: $e');
      if (mounted) {
        setState(() {
          _compressedImage = widget.imageFile;
          _isCompressing = false;
          _compressionError = 'Using original image';
        });
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_compressedImage == null) {
      _showError('Image not ready. Please try again.');
      return;
    }

    // Hide keyboard
    FocusScope.of(context).unfocus();

    // Submit registration
    final success = await ref.read(registrationProvider.notifier).submitRegistration(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          imageFile: _compressedImage!,
        );

    if (success && mounted) {
      _showSuccessDialog();
    } else if (mounted) {
      final error = ref.read(registrationProvider).errorMessage;
      _showError(error ?? 'Registration failed');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Registration Successful!',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Face has been registered successfully.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go to home
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Display
                        if (_isCompressing)
                          _buildCompressionLoader()
                        else if (_compressedImage != null)
                          Column(
                            children: [
                              ImageDisplayCard(
                                imageFile: _compressedImage!,
                                onRetake: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              if (_compressionError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _compressionError!,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppColors.warning,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                            ],
                          )
                        else
                          _buildCompressionError(),

                        const SizedBox(height: 32),

                        // Form Title
                        Text(
                          'Personal Information',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please provide the following details',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),

                        const SizedBox(height: 24),

                        // Name Field (Required)
                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name *',
                          hint: 'Enter full name',
                          icon: Icons.person_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Name is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Email Field (Required)
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email Address *',
                          hint: 'Enter email address',
                          icon: Icons.email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            final emailRegex = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            );
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Phone Field (Optional)
                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter phone number (optional)',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              if (value.trim().length < 10) {
                                return 'Phone number must be at least 10 digits';
                              }
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Notes Field (Optional)
                        CustomTextField(
                          controller: _notesController,
                          label: 'Additional Notes',
                          hint: 'Any additional information (optional)',
                          icon: Icons.notes_rounded,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                        ),

                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (registrationState.isLoading || _isCompressing)
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: registrationState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Register Face'),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Register Face',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCompressionLoader() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Optimizing image...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This may take a few seconds',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressionError() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Image processing failed',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _compressImage();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}