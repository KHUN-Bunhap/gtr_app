import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../ui_utils/device_font.dart';
import '../../services/auth_service.dart';

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return LayoutBuilder(
            builder: (context, constraints) {
              final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                constraints,
              );

              return Scaffold(
                appBar: AppBar(
                  foregroundColor: Colors.white,
                  title: Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveScale(
                        mobile: 20,
                        deviceType: deviceType,
                      ),
                    ),
                  ),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                body: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: deviceType == DeviceType.mobile
                            ? double.infinity
                            : ResponsiveUtils.responsiveScale(
                                mobile: 600.0,
                                deviceType: deviceType,
                              ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(
                          ResponsiveUtils.responsiveScale(
                            mobile: 16.0,
                            deviceType: deviceType,
                          ),
                        ),
                        child: Form(
                          key: vm.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Fixed recipient display
                              Container(
                                padding: EdgeInsets.all(
                                  ResponsiveUtils.responsiveScale(
                                    mobile: 16,
                                    deviceType: deviceType,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).primaryColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.lock_reset,
                                      color: Theme.of(context).primaryColor,
                                      size: ResponsiveUtils.responsiveScale(
                                        mobile: 24,
                                        deviceType: deviceType,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Password Reset Request',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.responsiveScale(
                                                  mobile: 12,

                                                  deviceType: deviceType,
                                                ),
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodySmall?.color,
                                          ),
                                        ),
                                        Text(
                                          'Enter your Student ID below',
                                          style: TextStyle(
                                            fontSize:
                                                ResponsiveUtils.responsiveScale(
                                                  mobile: 14,

                                                  deviceType: deviceType,
                                                ),
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.responsiveScale(
                                  mobile: 16,
                                  deviceType: deviceType,
                                ),
                              ),
                              TextFormField(
                                controller: vm.studentIdController,
                                style: TextStyle(
                                  fontSize: ResponsiveUtils.responsiveScale(
                                    mobile: 16,

                                    deviceType: deviceType,
                                  ),
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Student ID',
                                  hintText: 'Enter your student ID',
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.badge,
                                    size: ResponsiveUtils.responsiveScale(
                                      mobile: 24,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                  labelStyle: TextStyle(
                                    fontSize: ResponsiveUtils.responsiveScale(
                                      mobile: 14,

                                      deviceType: deviceType,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your student ID';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: ResponsiveUtils.responsiveScale(
                                  mobile: 24,
                                  deviceType: deviceType,
                                ),
                              ),
                              // Info message
                              Container(
                                padding: EdgeInsets.all(
                                  ResponsiveUtils.responsiveScale(
                                    mobile: 12,
                                    deviceType: deviceType,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: ResponsiveUtils.responsiveScale(
                                        mobile: 20,
                                        deviceType: deviceType,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'A password reset link will be sent to your registered email address. Click the link to set your new password.',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize:
                                              ResponsiveUtils.responsiveScale(
                                                mobile: 13,
                                                deviceType: deviceType,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.responsiveScale(
                                  mobile: 16,
                                  deviceType: deviceType,
                                ),
                              ),
                              // Error message display
                              if (vm.errorMessage != null)
                                Container(
                                  margin: EdgeInsets.only(
                                    bottom: ResponsiveUtils.responsiveScale(
                                      mobile: 16,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                  padding: EdgeInsets.all(
                                    ResponsiveUtils.responsiveScale(
                                      mobile: 12,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                        size: ResponsiveUtils.responsiveScale(
                                          mobile: 20,
                                          deviceType: deviceType,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          vm.errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize:
                                                ResponsiveUtils.responsiveScale(
                                                  mobile: 14,
                                                  deviceType: deviceType,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ElevatedButton.icon(
                                onPressed: vm.isLoading
                                    ? null
                                    : () => vm.sendEmail(context),
                                icon: vm.isLoading
                                    ? SizedBox(
                                        width: ResponsiveUtils.responsiveScale(
                                          mobile: 20,
                                          deviceType: deviceType,
                                        ),
                                        height: ResponsiveUtils.responsiveScale(
                                          mobile: 20,
                                          deviceType: deviceType,
                                        ),
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        color: Colors.white,
                                        Icons.send,
                                        size: ResponsiveUtils.responsiveScale(
                                          mobile: 20,
                                          deviceType: deviceType,
                                        ),
                                      ),
                                label: Text(
                                  vm.isLoading ? 'Submitting...' : 'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: ResponsiveUtils.responsiveScale(
                                      mobile: 16,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).primaryColor,
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveUtils.responsiveScale(
                                      mobile: 16,
                                      deviceType: deviceType,
                                    ),
                                    horizontal: ResponsiveUtils.responsiveScale(
                                      mobile: 24,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.responsiveScale(
                                        mobile: 8,
                                        deviceType: deviceType,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: ResponsiveUtils.responsiveScale(
                                  mobile: 12,
                                  deviceType: deviceType,
                                ),
                              ),
                              // Clear form button
                              OutlinedButton.icon(
                                onPressed: vm.isLoading ? null : vm.clearForm,
                                icon: Icon(
                                  Icons.clear,
                                  size: ResponsiveUtils.responsiveScale(
                                    mobile: 18,
                                    deviceType: deviceType,
                                  ),
                                ),
                                label: Text(
                                  'Clear Form',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.responsiveScale(
                                      mobile: 14,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    vertical: ResponsiveUtils.responsiveScale(
                                      mobile: 12,
                                      deviceType: deviceType,
                                    ),
                                    horizontal: ResponsiveUtils.responsiveScale(
                                      mobile: 20,
                                      deviceType: deviceType,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      ResponsiveUtils.responsiveScale(
                                        mobile: 8,
                                        deviceType: deviceType,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  // Form validation key
  final formKey = GlobalKey<FormState>();

  // Authentication service
  final AuthService _authService = AuthService();

  // Email state management
  bool _isLoading = false;
  String? _errorMessage;

  // Text editing controllers for form
  final TextEditingController studentIdController = TextEditingController();

  // Getters for accessing state
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // User input data (for validation and processing)
  String get studentId => studentIdController.text.trim();

  /// Handle password reset request - submit to backend
  /// @param context - Build context for navigation and feedback
  Future<void> sendEmail(BuildContext context) async {
    // Validate form inputs
    if (!formKey.currentState!.validate()) {
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      // Send password reset email via Firebase Auth
      // This looks up the user by student ID and sends reset link to their email
      await _authService.resetPasswordByStudentId(studentId);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ Password reset email sent!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Check your email inbox (and spam folder) for the reset link.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Clear form and go back to login
        clearForm();
        Navigator.of(context).pop();
      }
    } catch (e) {
      _errorMessage = e.toString();

      // Also show snackbar for better visibility
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all form fields
  void clearForm() {
    studentIdController.clear();
    _clearError();
    notifyListeners();
  }

  // Private helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    studentIdController.dispose();
    super.dispose();
  }
}
