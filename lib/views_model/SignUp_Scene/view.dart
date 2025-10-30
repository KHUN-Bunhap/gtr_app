// Flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// App utilities
import '../../ui_utils/validation.dart';
import '../../ui_utils/button.dart';
import '../../ui_utils/color_size_style.dart';
import '../../ui_utils/device_font.dart';
import '../../ui_utils/ui_helpers.dart';

// Services
import '../../services/auth_service.dart';

// SignUp scene - user registration interface
class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider setup
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return Scaffold(
            // App bar
            appBar: UIHelpers.gtrAppBar(
              title: 'Creating a New Account',
              context: context,
            ),
            body: Container(
              // Background with logo
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/gtr_logo.png'),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  opacity: 0.1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Use ResponsiveUtils for consistent responsive design
                  final deviceType =
                      ResponsiveUtils.getDeviceTypeFromConstraints(constraints);

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      // Ensure minimum height for proper form layout on different screens
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height > 200
                            ? MediaQuery.of(context).size.height - 200
                            : 400,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Top spacing container - reduced for landscape orientation
                            Container(
                              alignment: Alignment.center,
                              child: SizedBox(width: 40, height: 40),
                            ),

                            SizedBox(height: 15),

                            // Main signup form section with responsive padding
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ResponsiveUtils.responsiveScale(
                                    mobile: 12.0,
                                    deviceType: deviceType,
                                    tabletScale: 2.7, // 12 * 2.7 = 32.4 ≈ 32
                                    computerScale: 3.3, // 12 * 3.3 = 39.6 ≈ 40
                                  ),
                                  vertical: ResponsiveUtils.responsiveScale(
                                    mobile: 8.0,
                                    deviceType: deviceType,
                                    tabletScale: 1.5, // 8 * 1.5 = 12
                                    computerScale: 2.0, // 8 * 2.0 = 16
                                  ),
                                ),
                                child: Form(
                                  key: vm.formKey, // Form validation key
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // Account icon - responsive sizing based on device and orientation
                                      Icon(
                                        Icons.account_circle,
                                        size: ResponsiveUtils.scaledIconSize(
                                          mobile: 80,
                                          deviceType: deviceType,
                                        ),
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ), // Responsive spacing
                                      // Full Name Input Field
                                      FormFieldBuilders.buildTextField(
                                        context: context,
                                        label: 'Full Name',
                                        controller: vm.fullNameController,
                                        validator: Validators.validateFullName,
                                        onChanged: () {
                                          vm.validateFullName(
                                            vm.fullNameController.text,
                                          );
                                          vm.generateUsername(
                                            vm.fullNameController.text,
                                          );
                                        },
                                        isValid: vm.isFullNameValid,
                                        successMessage: '✓ Valid Name',
                                        keyboardType: TextInputType.name,
                                      ),
                                      SizedBox(height: 20),

                                      // ID Input Field - student ID with format validation
                                      FormFieldBuilders.buildTextField(
                                        context: context,
                                        label: 'ID (e.g., e2022****)',
                                        controller: vm.idController,
                                        validator: Validators.validateStudentId,
                                        onChanged: () =>
                                            vm.validateId(vm.idController.text),
                                        isValid: vm.isIdValid,
                                        successMessage: '✓ Valid ID Format',
                                        keyboardType: TextInputType.text,
                                      ),
                                      SizedBox(height: 20),

                                      // Email Input Field - email address with format validation
                                      FormFieldBuilders.buildTextField(
                                        context: context,
                                        label: 'Email',
                                        controller: vm.emailController,
                                        validator: Validators.validateEmail,
                                        onChanged: () => vm.validateEmail(
                                          vm.emailController.text,
                                        ),
                                        isValid: vm.isEmailValid,
                                        successMessage: '✓ Valid Email Address',
                                        keyboardType:
                                            TextInputType.emailAddress,
                                      ),
                                      SizedBox(height: 20),

                                      // Password Input Field - with show/hide eye icon toggle and strength validation
                                      FormFieldBuilders.buildPasswordField(
                                        context: context,
                                        label: 'Password',
                                        controller: vm.passwordController,
                                        validator: Validators.validatePassword,
                                        onChanged: () => vm.validatePassword(
                                          vm.passwordController.text,
                                        ),
                                        isValid: vm.isPasswordValid,
                                        isVisible: vm.isPasswordVisible,
                                        onVisibilityToggle: () =>
                                            vm.togglePasswordVisibility(),
                                        successMessage: '✓ Valid Password',
                                        showVisibilityToggle:
                                            true, // Show eye icon
                                      ),
                                      SizedBox(height: 20),

                                      // Confirm Password Field - password matching validation (always hidden as dots)
                                      FormFieldBuilders.buildPasswordField(
                                        context: context,
                                        label: 'Confirm Password',
                                        controller:
                                            vm.confirmPasswordController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Please confirm your password';
                                          if (value !=
                                              vm.passwordController.text)
                                            return 'Passwords do not match';
                                          return null;
                                        },
                                        onChanged: () =>
                                            vm.validateConfirmPassword(
                                              vm.confirmPasswordController.text,
                                            ),
                                        isValid: vm.isConfirmPasswordValid,
                                        isVisible: false,
                                        onVisibilityToggle: () {},
                                        successMessage: '✓ Password Matched',
                                        showVisibilityToggle:
                                            false, // No icon - always hidden as dots
                                      ),

                                      SizedBox(height: AppSizes.spacingXl * 2),

                                      // Sign Up Button - using GTRButton with theme-aware primary color
                                      GTRButton.primary(
                                        text: "Sign Up",
                                        onPressed: vm.isLoading
                                            ? null
                                            : () => vm.onSignUpPressed(context),
                                        isLoading: vm.isLoading,
                                        width: 200,
                                      ),

                                      SizedBox(height: AppSizes.spacingM),

                                      // Login Navigation Link - for existing users
                                      InkWell(
                                        onTap: () {
                                          //
                                        },
                                        child: Text(
                                          "Already have an account? Login",
                                          style: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).primaryColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
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
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  dynamic _IDdata = '';
  dynamic get IDdata => _IDdata;
  set IDdata(dynamic value) {
    _IDdata = value;
    notifyListeners();
  }

  dynamic _emailData = '';
  dynamic get emailData => _emailData;
  set emailData(dynamic value) {
    _emailData = value;
    notifyListeners();
  }

  dynamic _passwordData = '';
  dynamic get passwordData => _passwordData;
  set passwordData(dynamic value) {
    _passwordData = value;
    notifyListeners();
  }

  dynamic _confirmPasswordData = '';
  dynamic get confirmPasswordData => _confirmPasswordData;
  set confirmPasswordData(dynamic value) {
    _confirmPasswordData = value;
    notifyListeners();
  }

  // Controllers for text fields
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final idController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Validation states for green styling
  bool isFullNameValid = false;
  bool isIdValid = false;
  bool isEmailValid = false;
  bool isPasswordValid = false;
  bool isConfirmPasswordValid = false;

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    idController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    notifyListeners();
  }

  // Generate username from full name
  void generateUsername(String fullName) {
    if (fullName.isEmpty) {
      usernameController.text = '';
      notifyListeners();
      return;
    }

    // Convert to lowercase, remove special characters, and remove spaces
    String username = fullName
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '') // Remove special characters
        .split(RegExp(r'\s+'))
        .join(''); // Remove spaces by concatenation

    usernameController.text = username;
    notifyListeners();
  }

  // Real-time validation methods
  void validateFullName(dynamic value) {
    bool wasValid = isFullNameValid;
    isFullNameValid = value.isNotEmpty && value.length >= 2;

    // If field becomes valid after being invalid, trigger form validation
    if (!wasValid && isFullNameValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }

    notifyListeners();
  }

  void validateId(dynamic value) {
    bool wasValid = isIdValid;
    isIdValid = value.isNotEmpty && RegExp(r'^e\d{8}$').hasMatch(value);

    // If field becomes valid after being invalid, trigger form validation
    if (!wasValid && isIdValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }

    notifyListeners();
  }

  void validateEmail(dynamic value) {
    bool wasValid = isEmailValid;
    isEmailValid =
        value.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

    // If field becomes valid after being invalid, trigger form validation
    if (!wasValid && isEmailValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }

    notifyListeners();
  }

  void validatePassword(dynamic value) {
    bool wasValid = isPasswordValid;
    isPasswordValid = value.isNotEmpty && value.length >= 6;

    // If field becomes valid after being invalid, trigger form validation
    if (!wasValid && isPasswordValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }

    notifyListeners();
  }

  void validateConfirmPassword(dynamic value) {
    bool wasValid = isConfirmPasswordValid;
    isConfirmPasswordValid =
        value.isNotEmpty &&
        value.length >= 6 &&
        value == passwordController.text;

    // If field becomes valid after being invalid, trigger form validation
    if (!wasValid && isConfirmPasswordValid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        formKey.currentState?.validate();
      });
    }

    notifyListeners();
  }

  bool validateForm() {
    // Update all visual validation states when form is validated
    validateFullName(fullNameController.text);
    validateId(idController.text);
    validateEmail(emailController.text);
    validatePassword(passwordController.text);
    validateConfirmPassword(confirmPasswordController.text);

    return formKey.currentState?.validate() ?? false;
  }

  Future<void> onSignUpPressed(BuildContext context) async {
    if (!validateForm()) {
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      final fullName = fullNameController.text;
      IDdata = idController.text;
      emailData = emailController.text;
      passwordData = passwordController.text;
      confirmPasswordData = confirmPasswordController.text;

      // Sign up with Firebase
      await _authService.signUpWithEmail(
        email: emailData,
        password: passwordData,
        fullName: fullName, // Use actual full name
        studentId: IDdata,
        username: usernameController.text,
      );

      if (context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate back to login
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
