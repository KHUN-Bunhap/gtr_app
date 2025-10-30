import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../ui_utils/utils.dart';
import '../../ui_utils/button.dart';
import '../../ui_utils/color_size_style.dart';
import '../../ui_utils/navigation.dart';
import '../../ui_utils/validation.dart';
import '../../services/auth_service.dart';
import '../Authentication_Scene/email.dart' as forgot_password;

class View extends StatelessWidget {
  const View({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ViewModel(),
      child: Builder(
        builder: (context) {
          final vm = context.watch<ViewModel>();
          return Scaffold(
            appBar: UIHelpers.gtrAppBar(
              title: 'Change Password',
              context: context,
            ),
            body: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/assets/gtr_logo.png'),
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  opacity: 0.1, // Even more subtle for better readability
                ),
              ),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final deviceType =
                        ResponsiveUtils.getDeviceTypeFromConstraints(
                          constraints,
                        );

                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height > 200
                              ? MediaQuery.of(context).size.height - 200
                              : 400,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Reduced spacing for better landscape layout
                              Container(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: ResponsiveUtils.responsiveScale(
                                    mobile: 40,
                                    deviceType: deviceType,
                                  ),
                                  height: ResponsiveUtils.responsiveScale(
                                    mobile: 40,
                                    deviceType: deviceType,
                                  ),
                                ),
                              ),

                              // Form section
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal:
                                        (deviceType != DeviceType.mobile)
                                        ? 32
                                        : (12),
                                    vertical: 8,
                                  ),
                                  child: Form(
                                    key: vm.formKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Lock icon
                                        Icon(
                                          Icons.lock_reset,
                                          size:
                                              (deviceType != DeviceType.mobile)
                                              ? 80
                                              : (60),
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        SizedBox(height: 15),

                                        // Form fields
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            maxWidth: 500,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                'Change Your Password',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      (deviceType !=
                                                          DeviceType.mobile)
                                                      ? 20
                                                      : (18),
                                                  color: Theme.of(
                                                    context,
                                                  ).primaryColor,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Enter your current password and choose a new one',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize:
                                                      (deviceType !=
                                                          DeviceType.mobile)
                                                      ? 14
                                                      : (12),
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodySmall?.color,
                                                ),
                                              ),
                                              SizedBox(height: 24),

                                              // Current Password
                                              TextFormField(
                                                controller: vm
                                                    .currentPasswordController,
                                                obscureText: !vm
                                                    .isCurrentPasswordVisible,
                                                decoration: InputDecoration(
                                                  labelText: 'Current Password',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 16,
                                                      ),
                                                  prefixIcon: const Icon(
                                                    Icons.lock_outline,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      vm.isCurrentPasswordVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                    ),
                                                    onPressed: vm
                                                        .toggleCurrentPasswordVisibility,
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please enter your current password';
                                                  }
                                                  return null;
                                                },
                                              ),
                                              SizedBox(height: 16),

                                              // New Password
                                              TextFormField(
                                                controller:
                                                    vm.newPasswordController,
                                                obscureText:
                                                    !vm.isNewPasswordVisible,
                                                decoration: InputDecoration(
                                                  labelText: 'New Password',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 16,
                                                      ),
                                                  prefixIcon: const Icon(
                                                    Icons.lock,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      vm.isNewPasswordVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                    ),
                                                    onPressed: vm
                                                        .toggleNewPasswordVisibility,
                                                  ),
                                                ),
                                                validator:
                                                    Validators.validatePassword,
                                              ),
                                              SizedBox(height: 16),

                                              // Confirm New Password
                                              TextFormField(
                                                controller: vm
                                                    .confirmPasswordController,
                                                obscureText: !vm
                                                    .isConfirmPasswordVisible,
                                                decoration: InputDecoration(
                                                  labelText:
                                                      'Confirm New Password',
                                                  border:
                                                      const OutlineInputBorder(),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 16,
                                                      ),
                                                  prefixIcon: const Icon(
                                                    Icons.lock,
                                                  ),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                      vm.isConfirmPasswordVisible
                                                          ? Icons.visibility
                                                          : Icons
                                                                .visibility_off,
                                                    ),
                                                    onPressed: vm
                                                        .toggleConfirmPasswordVisibility,
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value !=
                                                      vm
                                                          .newPasswordController
                                                          .text) {
                                                    return 'Passwords do not match';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Error message display
                                        if (vm.errorMessage != null)
                                          Container(
                                            margin: EdgeInsets.only(top: 16),
                                            padding: EdgeInsets.all(12),
                                            constraints: const BoxConstraints(
                                              maxWidth: 500,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              border: Border.all(
                                                color: Colors.red.shade300,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red.shade700,
                                                  size: 20,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    vm.errorMessage!,
                                                    style: TextStyle(
                                                      color:
                                                          Colors.red.shade700,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                        SizedBox(
                                          height:
                                              ResponsiveUtils.responsiveScale(
                                                mobile: 24,
                                                deviceType: deviceType,
                                              ),
                                        ),

                                        // Change Password button
                                        GTRButton.primary(
                                          text: vm.isLoading
                                              ? "Changing..."
                                              : "Change Password",
                                          onPressed: vm.isLoading
                                              ? null
                                              : () {
                                                  vm.onChangePasswordPressed(
                                                    context,
                                                  );
                                                },
                                          width: 200,
                                          isLoading: vm.isLoading,
                                        ),
                                        SizedBox(height: AppSizes.spacingM),

                                        InkWell(
                                          onTap: () => vm
                                              .onForgotPasswordPressed(context),
                                          child: Text(
                                            'Forgot Password?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(
                                                context,
                                              ).primaryColor,
                                            ),
                                          ),
                                        ),

                                        Spacer(),

                                        GTRButton.primary(
                                          text: "Cancel",
                                          onPressed: () {
                                            vm.onCancelPressed(context);
                                          },
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
            ),
          );
        },
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // Controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // State
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isCurrentPasswordVisible => _isCurrentPasswordVisible;
  bool get isNewPasswordVisible => _isNewPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Toggle visibility methods
  void toggleCurrentPasswordVisibility() {
    _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _isNewPasswordVisible = !_isNewPasswordVisible;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners();
  }

  Future<void> onChangePasswordPressed(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = _authService.currentUser;
      if (user == null || user.email == null) {
        throw 'No user logged in';
      }

      // Re-authenticate user with current password before changing it
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPasswordController.text,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPasswordController.text);

      if (context.mounted) {
        NavigationHelper.showSuccessSnackBar(
          context,
          message: 'Password changed successfully!',
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onForgotPasswordPressed(BuildContext context) {
    NavigationHelper.push(context, forgot_password.View());
  }

  void onCancelPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
