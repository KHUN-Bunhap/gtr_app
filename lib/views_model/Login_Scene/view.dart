// Flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// App utilities
import '../../ui_utils/validation.dart';
import '../../ui_utils/base_view_model.dart';
import '../../ui_utils/button.dart';
import '../../ui_utils/navigation.dart';
import '../../ui_utils/color_size_style.dart';
import '../../ui_utils/device_font.dart';
import '../../ui_utils/ui_helpers.dart';

// Services
import '../../services/auth_service.dart';

// Scene imports
import '../Main_Scene/main.dart' as mainscene;
import '../SignUp_Scene/view.dart' as signup_scene;
import '../Authentication_Scene/email.dart' as forgot_password;

/// Modern Login Scene using the new UI components and patterns
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Consumer<ViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: UIHelpers.gtrAppBar(title: 'Login', context: context),
            body: Stack(
              children: [
                // Background image layer
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('lib/assets/gtr_logo.png'),
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      opacity: 0.1,
                    ),
                  ),
                ),
                // Content layer
                Center(
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Form(
                          key: vm.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // GTR Logo/Icon with responsive sizing
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final deviceType =
                                      ResponsiveUtils.getDeviceTypeFromConstraints(
                                        constraints,
                                      );

                                  return Icon(
                                    Icons.account_circle,
                                    size: ResponsiveUtils.scaledIconSize(
                                      mobile: 80,
                                      deviceType: deviceType,
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  );
                                },
                              ),
                              UIHelpers.verticalSpace(AppSizes.spacingM),

                              // Student ID Field - Using Centralized FormFieldBuilders
                              FormFieldBuilders.buildTextField(
                                context: context,
                                label: 'ID (e.g., e2022****)',
                                controller: vm.idController,
                                validator: Validators.validateStudentId,
                                onChanged: () =>
                                    vm.validateIdField(vm.idController.text),
                                isValid: vm.isFieldValid('id'),
                                successMessage: 'Valid student ID format',
                                keyboardType: TextInputType.text,
                              ),
                              UIHelpers.verticalSpace(AppSizes.spacingM),

                              // Email Field - Using Centralized FormFieldBuilders
                              FormFieldBuilders.buildTextField(
                                context: context,
                                label: 'Email',
                                controller: vm.emailController,
                                validator: Validators.validateEmail,
                                onChanged: () => vm.validateEmailField(
                                  vm.emailController.text,
                                ),
                                isValid: vm.isFieldValid('email'),
                                successMessage: 'Valid email format',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              UIHelpers.verticalSpace(AppSizes.spacingM),

                              // Password Field with show/hide toggle - Using Centralized FormFieldBuilders
                              FormFieldBuilders.buildPasswordField(
                                context: context,
                                label: 'Password',
                                controller: vm.passwordController,
                                validator: Validators.validatePassword,
                                onChanged: () => vm.validatePasswordField(
                                  vm.passwordController.text,
                                ),
                                isValid: vm.isFieldValid('password'),
                                isVisible: vm.isPasswordVisible,
                                onVisibilityToggle: vm.togglePasswordVisibility,
                                successMessage: 'Password strength: Good',
                                showVisibilityToggle: true,
                              ),

                              // Additional login options
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    width: 500,
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          vm.forgotPassword(context),
                                      style: AppButtonStyles.text,
                                      child: const Text('Forgot Password?'),
                                    ),
                                  );
                                },
                              ),

                              UIHelpers.verticalSpace(AppSizes.spacingXl),

                              UIHelpers.verticalSpace(AppSizes.spacingL),

                              // Login Button with loading state
                              GTRButton.primary(
                                text: 'Login',
                                onPressed: vm.isLoading
                                    ? null
                                    : () => vm.onLoginPressed(context),
                                isLoading: vm.isLoading,
                                width: 200,
                              ),

                              // Error Message Display
                              if (vm.errorMessage != null) ...[
                                UIHelpers.verticalSpace(AppSizes.spacingM),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                  ),
                                  padding: EdgeInsets.all(AppSizes.spacingM),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusM,
                                    ),
                                    border: Border.all(
                                      color: AppColors.error.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      UIHelpers.horizontalSpace(
                                        AppSizes.spacingS,
                                      ),
                                      Expanded(
                                        child: Text(
                                          vm.errorMessage!,
                                          style: ThemeTextStyles.body2(
                                            context,
                                          ).copyWith(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              UIHelpers.verticalSpace(AppSizes.spacingL),

                              // Sign Up Link - matching original design
                              TextButton(
                                onPressed: () => NavigationHelper.push(
                                  context,
                                  signup_scene.View(),
                                ),
                                style: AppButtonStyles.text,
                                child: Text(
                                  "New to GTR App? Sign Up",
                                  style: ThemeTextStyles.body2(context)
                                      .copyWith(
                                        color: Theme.of(context).primaryColor,
                                      ),
                                ),
                              ),
                            ],
                          ), // <-- Add this closing parenthesis for Column
                        ), // <-- Add this closing parenthesis for Form
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Modern ViewModel using BaseViewModel and FormValidationMixin
class ViewModel extends BaseViewModel with FormValidationMixin {
  final AuthService _authService = AuthService();

  // Text controllers
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // UI State
  bool _isPasswordVisible = false;

  // Getters for compatibility with original design
  bool get isPasswordVisible => _isPasswordVisible;
  bool get checkboxValue => _isPasswordVisible; // For backward compatibility
  bool get canSubmit => areAllFieldsValid(['id', 'email', 'password']);

  // Legacy getters for existing UI code compatibility
  TextEditingController get ID_input => idController;
  TextEditingController get email_input => emailController;
  TextEditingController get password_input => passwordController;

  // User input data (for validation and processing)
  String get idData => idController.text.trim();
  String get emailData => emailController.text.trim();
  String get passwordData => passwordController.text;

  // Field validation methods
  void validateIdField(String value) {
    final isValid = Validators.validateStudentId(value) == null;
    setFieldValid('id', isValid);
    notifyListeners();
  }

  void validateEmailField(String value) {
    final isValid = Validators.validateEmail(value) == null;
    setFieldValid('email', isValid);
    notifyListeners();
  }

  void validatePasswordField(String value) {
    final isValid = Validators.validatePassword(value) == null;
    setFieldValid('password', isValid);
    notifyListeners();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners();
  }

  /// Legacy method for backward compatibility
  void toggleCheckbox(bool value) {
    _isPasswordVisible = value;
    notifyListeners();
  }

  /// Handle login with Firebase authentication
  Future<void> onLoginPressed(BuildContext context) async {
    try {
      // Validate form inputs
      if (!_validateInputs()) {
        setError('Please fill in all required fields');
        return;
      }

      await executeWithLoading(() async {
        try {
          // Sign in with Firebase
          await _authService.signInWithEmail(
            email: emailData,
            password: passwordData,
          );

          if (context.mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Login successful!'),
                backgroundColor: AppColors.success,
              ),
            );

            // Navigate to main scene
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => mainscene.View()),
              );
            });
          }
        } catch (e) {
          // Show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      });
    } catch (error) {
      setError('Login failed: ${error.toString()}');
    }
  }

  /// Validate user inputs before sending to backend - same logic as original
  bool _validateInputs() {
    if (idData.isEmpty || emailData.isEmpty || passwordData.isEmpty) {
      return false;
    }
    return true;
  }

  /// Forgot password functionality - navigate to forgot password scene
  void forgotPassword(BuildContext context) {
    NavigationHelper.push(context, forgot_password.View());
  }

  @override
  void dispose() {
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
