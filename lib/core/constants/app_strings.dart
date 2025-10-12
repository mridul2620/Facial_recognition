class AppStrings {
  AppStrings._();

  // App Info
  static const String appName = 'FaceRecog';
  static const String appVersion = '1.0.0';

  // Splash Screen
  static const String splashTitle = 'Face Recognition';
  static const String splashSubtitle = 'Secure & Fast Authentication';
  static const String splashLoading = 'Initializing...';

  // Home Screen
  static const String homeTitle = 'Face Recognition';
  static const String homeWelcome = 'Welcome Back!';
  
  // Buttons
  static const String btnRegister = 'Register New Face';
  static const String btnRecognize = 'Recognize Face';
  static const String btnGetStarted = 'Get Started';
  static const String btnSubmit = 'Submit';
  static const String btnRetake = 'Retake';
  static const String btnProceed = 'Proceed';
  static const String btnDone = 'Done';

  // Registration
  static const String regTitle = 'Register Face';
  static const String regPersonalInfo = 'Personal Information';
  static const String regCapturedImage = 'Captured Image';
  static const String regSuccess = 'Registration Successful!';
  static const String regSuccessMessage = 'Face has been registered successfully.';

  // Form Labels
  static const String labelName = 'Full Name';
  static const String labelEmail = 'Email Address';
  static const String labelPhone = 'Phone Number';
  static const String labelNotes = 'Additional Notes';

  // Form Hints
  static const String hintName = 'Enter full name';
  static const String hintEmail = 'Enter email address';
  static const String hintPhone = 'Enter phone number (optional)';
  static const String hintNotes = 'Any additional information (optional)';

  // Validation Messages
  static const String valNameRequired = 'Name is required';
  static const String valNameMinLength = 'Name must be at least 2 characters';
  static const String valEmailRequired = 'Email is required';
  static const String valEmailInvalid = 'Enter a valid email address';
  static const String valPhoneMinLength = 'Phone number must be at least 10 digits';

  // Messages
  static const String msgLoading = 'Please wait...';
  static const String msgProcessing = 'Processing...';
  static const String msgCompressing = 'Compressing image...';
  static const String msgSubmitting = 'Submitting registration...';
}