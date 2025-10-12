import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../registration/screens/registration_screen.dart';

class ImagePreviewScreen extends StatelessWidget {
  final File imageFile;
  final String mode;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
    required this.mode,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image Preview
          Center(
            child: Image.file(
              imageFile,
              fit: BoxFit.contain,
            ),
          ),

          // Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 8,
                right: 8,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Text(
                    mode == 'register' ? 'Register Face' : 'Recognize Face',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info Text
                  Text(
                    mode == 'register'
                        ? 'Looks good? Proceed to fill in details'
                        : 'Ready to recognize this face?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Retake Button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.camera_alt_rounded),
                          label: const Text('Retake'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Proceed Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _handleProceed(context),
                          icon: const Icon(Icons.check_circle_rounded),
label: const Text('Proceed'),
style: ElevatedButton.styleFrom(
padding: const EdgeInsets.symmetric(vertical: 16),
),
),
),
],
),
],
),
),
),
],
),
);
}
void _handleProceed(BuildContext context) {
if (mode == 'register') {
// Navigate to registration screen
Navigator.of(context).push(
MaterialPageRoute(
builder: (context) => RegistrationScreen(
imageFile: imageFile,
),
),
);
} else {
// Navigate to recognition process (coming in next step)
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text('Recognition process - Coming in next step'),
backgroundColor: AppColors.success,
behavior: SnackBarBehavior.floating,
),
);
Navigator.of(context).popUntil((route) => route.isFirst);
}
}
}