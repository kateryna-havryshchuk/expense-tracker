abstract class AppStrings {
  const AppStrings._();

  // General
  static const String appName = 'SmartExpense';
  static const String appTagline = 'Track your expenses smartly';
  static const String welcome = 'Welcome!';
  static const String welcomeBack = 'Welcome back!';
  
  // Input fields
  static const String fullNameHint = 'Full name';
  static const String emailHint = 'Email address';
  static const String passwordHint = 'Password';
  
  // Buttons
  static const String signUpButton = 'Sign Up';
  static const String signInButton = 'Sign In';
  static const String googleButton = 'G';
  
  // Navigation
  static const String orContinueWith = 'or continue with';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";

  // Validation
  static const String nameEmptyError = 'Please enter your name';
  static const String emailEmptyError = 'Please enter your email';
  static const String emailInvalidError = 'Please enter a valid email';
  static const String passwordEmptyError = 'Please enter your password';
  static const String passwordLengthError = 'Password must be at least 6 characters long';

  // Sign-up errors
  static const String errorDefault = 'An error occurred. Please try again.';
  static const String errorWeakPassword = 'The password is too weak.';
  static const String errorEmailInUse = 'This email is already registered.';
  
  // Sign-in errors
  static const String errorUserNotFound = 'User not found.';
  static const String errorWrongPassword = 'Incorrect password.';
  static const String errorInvalidCredential = 'Invalid login credentials.';
  static const String errorInvalidEmail = 'Invalid email format.';
  
  // Other errors
  static const String errorUnknown = 'An unknown error occurred.';
  static const String errorGoogleSignIn = 'Google sign-in failed.';
}
