
class Validators {
  // Email validation
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Password validation (min 6 chars, at least 1 letter and 1 number)
  static bool isValidPassword(String password) {
    if (password.length < 6) return false;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    return hasLetter && hasNumber;
  }

  // Phone validation (Egypt)
  static bool isValidEgyptPhone(String phone) {
    final phoneRegex = RegExp(r'^01[0-2,5]{1}[0-9]{8}$');
    return phoneRegex.hasMatch(phone);
  }

  // Name validation (min 2 chars, only letters and spaces)
  static bool isValidName(String name) {
    if (name.length < 2) return false;
    final validChars = RegExp(r'^[a-zA-Z\s؀-ۿ]+$');
    return validChars.hasMatch(name);
  }

  // Arabic text validation
  static bool isValidArabicText(String text) {
    final arabicRegex = RegExp(r'^[؀-ۿ\sݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]+$');
    return arabicRegex.hasMatch(text);
  }

  // URL validation
  static bool isValidUrl(String url) {
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/.*)?$',
    );
    return urlRegex.hasMatch(url);
  }

  // Not empty validation
  static bool isNotEmpty(String value) {
    return value.trim().isNotEmpty;
  }

  // Min length validation
  static bool hasMinLength(String value, int minLength) {
    return value.length >= minLength;
  }

  // Max length validation
  static bool hasMaxLength(String value, int maxLength) {
    return value.length <= maxLength;
  }

  // Number validation
  static bool isValidNumber(String value) {
    return num.tryParse(value) != null;
  }

  // Positive number validation
  static bool isPositiveNumber(String value) {
    final number = num.tryParse(value);
    return number != null && number > 0;
  }

  // Get validation error message
  static String? getEmailError(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Invalid email format';
    return null;
  }

  static String? getPasswordError(String password) {
    if (password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (!RegExp(r'[a-zA-Z]').hasMatch(password)) return 'Password must contain at least one letter';
    if (!RegExp(r'[0-9]').hasMatch(password)) return 'Password must contain at least one number';
    return null;
  }

  static String? getNameError(String name) {
    if (name.isEmpty) return 'Name is required';
    if (name.length < 2) return 'Name must be at least 2 characters';
    if (!isValidName(name)) return 'Name contains invalid characters';
    return null;
  }

  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return 'Phone is required';
    if (!isValidEgyptPhone(phone)) return 'Invalid Egyptian phone number';
    return null;
  }
}
