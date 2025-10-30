import 'package:flutter/material.dart';

/// Backward compatibility file - all validators are now in utils.dart

import 'device_font.dart';

class Validators {
  /// Email validation pattern
  static final RegExp emailPattern = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Student ID pattern (e.g., e20220001 or t20220001)
  static final RegExp studentIdPattern = RegExp(r'^[et]\d{8}$');

  /// Password pattern (at least 8 characters)
  static final RegExp passwordPattern = RegExp(r'^.{8,}$');

  /// Phone number pattern
  static final RegExp phonePattern = RegExp(r'^\+?[\d\s-()]{10,}$');

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!emailPattern.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates full name
  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  /// Validates student ID format
  static String? validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Student ID is required';
    }
    if (!studentIdPattern.hasMatch(value.toLowerCase())) {
      return 'Please enter a valid student ID (e.g., e20220001)';
    }
    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates phone number
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!phonePattern.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  /// Validates required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    return null;
  }
}

/// Common loading states
enum LoadingState { idle, loading, success, error }

/// Extension methods for LoadingState
extension LoadingStateExtension on LoadingState {
  bool get isIdle => this == LoadingState.idle;
  bool get isLoading => this == LoadingState.loading;
  bool get isSuccess => this == LoadingState.success;
  bool get isError => this == LoadingState.error;
}

/// Form validation mixin for view models
mixin FormValidationMixin {
  final Map<String, bool> _fieldValidation = {};

  /// Set field validation state
  void setFieldValid(String fieldName, bool isValid) {
    _fieldValidation[fieldName] = isValid;
  }

  /// Check if field is valid
  bool isFieldValid(String fieldName) {
    return _fieldValidation[fieldName] ?? false;
  }

  /// Check if all required fields are valid
  bool areAllFieldsValid(List<String> requiredFields) {
    return requiredFields.every((field) => isFieldValid(field));
  }

  /// Clear all field validations
  void clearFieldValidations() {
    _fieldValidation.clear();
  }
}

/// Reusable form field builders for consistent UI across authentication scenes
class FormFieldBuilders {
  /// Build standard text input field with real-time validation and visual feedback
  static Widget buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required VoidCallback onChanged,
    required bool isValid,
    String? hintText,
    String? successMessage,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    int maxLines = 1,
    DeviceType? deviceType,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        maxLines: maxLines,
        onChanged: (value) {
          onChanged();
        },
        style: TextStyle(
          fontSize: deviceType != null
              ? ResponsiveUtils.responsiveScale(
                  mobile: 16,
                  deviceType: deviceType,
                ).toDouble()
              : 16.0,
        ),
        decoration: _buildInputDecoration(
          context: context,
          label: label,
          hintText: hintText,
          isValid: isValid,
          successMessage: successMessage,
          deviceType: deviceType,
        ),
        validator: validator,
      ),
    );
  }

  /// Build password field with visibility toggle and confirmation validation
  static Widget buildPasswordField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required VoidCallback onChanged,
    required bool isValid,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    String? hintText,
    String? successMessage,
    bool showVisibilityToggle = true,
    DeviceType? deviceType,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500),
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        onChanged: (value) {
          onChanged();
        },
        style: TextStyle(
          fontSize: deviceType != null
              ? ResponsiveUtils.responsiveScale(
                  mobile: 16,
                  deviceType: deviceType,
                ).toDouble()
              : 16.0,
        ),
        decoration: _buildInputDecoration(
          context: context,
          label: label,
          hintText: hintText,
          isValid: isValid,
          successMessage: successMessage,
          deviceType: deviceType,
          suffixIcon: showVisibilityToggle
              ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  /// Build input decoration with consistent styling and validation feedback
  static InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String label,
    String? hintText,
    required bool isValid,
    String? successMessage,
    Widget? suffixIcon,
    DeviceType? deviceType,
  }) {
    final theme = Theme.of(context);
    final fontSize = deviceType != null
        ? ResponsiveUtils.responsiveScale(mobile: 16, deviceType: deviceType)
        : 16;

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      labelStyle: TextStyle(
        fontSize: fontSize.toDouble(),
        color: isValid ? Colors.green[600] : Colors.grey[600],
      ),
      hintStyle: TextStyle(
        fontSize: (fontSize * 0.9).toDouble(),
        color: Colors.grey[500],
      ),
      suffixIcon:
          suffixIcon ??
          (isValid
              ? Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: (fontSize + 4).toDouble(),
                )
              : null),
      helperText: isValid && successMessage != null ? successMessage : null,
      helperStyle: TextStyle(
        color: Colors.green[600],
        fontSize: (fontSize * 0.8).toDouble(),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isValid ? Colors.green[400]! : Colors.grey[400]!,
          width: isValid ? 2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isValid ? Colors.green[600]! : theme.primaryColor,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[400]!, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.red[600]!, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: deviceType != null
            ? ResponsiveUtils.responsiveScale(
                mobile: 16,
                deviceType: deviceType,
              )
            : 16,
        vertical: deviceType != null
            ? ResponsiveUtils.responsiveScale(
                mobile: 16,
                deviceType: deviceType,
              )
            : 16,
      ),
    );
  }

  /// Get validation message based on field type and value
  static String? getValidationMessage(String fieldName, String? value) {
    switch (fieldName.toLowerCase()) {
      case 'id':
      case 'student id':
        return Validators.validateStudentId(value);
      case 'email':
        return Validators.validateEmail(value);
      case 'password':
        return Validators.validatePassword(value);
      case 'confirm password':
        // This needs the original password to compare
        return 'Passwords do not match';
      default:
        return Validators.validateRequired(value, fieldName);
    }
  }
}

/// Enhanced password validation with strength checking
class PasswordValidators {
  /// Check password strength
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;
    if (password.length < 6) return PasswordStrength.weak;
    if (password.length < 8) return PasswordStrength.fair;

    bool hasUpper = password.contains(RegExp(r'[A-Z]'));
    bool hasLower = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'\d'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int criteriaCount = [
      hasUpper,
      hasLower,
      hasDigit,
      hasSpecial,
    ].where((x) => x).length;

    if (criteriaCount >= 3 && password.length >= 10) {
      return PasswordStrength.strong;
    }
    if (criteriaCount >= 2 && password.length >= 8) {
      return PasswordStrength.good;
    }
    return PasswordStrength.fair;
  }

  /// Get password strength message
  static String getPasswordStrengthMessage(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.empty:
        return 'Password is required';
      case PasswordStrength.weak:
        return 'Password is too weak';
      case PasswordStrength.fair:
        return 'Password is fair';
      case PasswordStrength.good:
        return 'Password is good';
      case PasswordStrength.strong:
        return 'Password is strong';
    }
  }

  /// Get password strength color
  static Color getPasswordStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.empty:
        return Colors.grey;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.blue;
      case PasswordStrength.strong:
        return Colors.green;
    }
  }
}

/// Password strength levels
enum PasswordStrength { empty, weak, fair, good, strong }
