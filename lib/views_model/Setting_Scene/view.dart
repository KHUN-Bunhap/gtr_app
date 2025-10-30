// Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App utilities
import '../../ui_utils/utils.dart';
import '../../ui_utils/navigation.dart';

// Services
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

// Scene imports
import '../ChangePassword_Scene/view.dart' as change_password;
import '../Login_Scene/view.dart' as login_scene;

// Settings scene - app configuration interface
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

          // Show loading while checking role
          if (vm.isLoadingRole) {
            return Scaffold(
              appBar: UIHelpers.gtrAppBar(title: 'Settings', context: context),
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            // App bar with save action
            appBar: UIHelpers.gtrAppBar(
              title: 'Settings',
              context: context,
              actions: [
                // Save button
                TextButton(
                  onPressed: () => vm.saveChanges(context),
                  child: Text('Save', style: ThemeTextStyles.button(context)),
                ),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Use ResponsiveUtils for consistent responsive design
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 16,
                  ),
                  child: Container(
                    // Responsive padding using ResponsiveUtils with overflow protection
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveUtils.responsiveScale(
                        mobile: constraints.maxWidth < 400
                            ? 12.0
                            : 16.0, // Reduce padding on very small screens
                        deviceType: deviceType,
                        tabletScale: 2.0, // 16 * 2 = 32
                        computerScale: 2.5, // 16 * 2.5 = 40
                      ),
                      vertical: ResponsiveUtils.responsiveScale(
                        mobile: 12.0, // Reduced vertical padding
                        deviceType: deviceType,
                        tabletScale: 1.5, // 12 * 1.5 = 18
                        computerScale: 2.0, // 12 * 2.0 = 24
                      ),
                    ),
                    child: Form(
                      key: vm.formKey, // Form validation key
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contact Information Section - User contact details
                          _buildSectionHeader(
                            context,
                            'Contact Information',
                            deviceType,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 12
                                  : 16, // Adaptive spacing
                              deviceType: deviceType,
                            ),
                          ),

                          // Email Input Field - with validation and responsive design
                          _buildTextField(
                            context: context,
                            controller: vm.emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: vm.validateEmail,
                            deviceType: deviceType,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 12
                                  : 16, // Adaptive spacing
                              deviceType: deviceType,
                            ),
                          ),

                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 20
                                  : 32, // Adaptive spacing
                              deviceType: deviceType,
                            ),
                          ),

                          // Account Actions Section - Security and session management
                          _buildSectionHeader(context, 'Account', deviceType),
                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 12
                                  : 16, // Adaptive spacing
                              deviceType: deviceType,
                            ),
                          ),

                          // Change Password Button
                          _buildActionTile(
                            context: context,
                            title: 'Change Password',
                            subtitle: 'Update your account password',
                            icon: Icons.lock_outline,
                            onTap: () => vm.changePassword(context),
                            deviceType: deviceType,
                          ),

                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 12
                                  : 16, // Adaptive spacing
                              deviceType: deviceType,
                            ),
                          ),

                          // Logout Button
                          _buildActionTile(
                            context: context,
                            title: 'Logout',
                            subtitle: 'Sign out of your account',
                            icon: Icons.logout,
                            onTap: () => vm.logout(context),
                            deviceType: deviceType,
                            isDestructive: true,
                          ),
                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 20
                                  : 32, // Adaptive spacing
                              deviceType: deviceType,
                            ),
                          ),
                          if (vm.isDeveloper) ...[
                            SizedBox(
                              height: ResponsiveUtils.responsiveScale(
                                mobile: constraints.maxHeight < 600
                                    ? 20
                                    : 32, // Adaptive spacing
                                deviceType: deviceType,
                              ),
                            ),
                            _buildSectionHeader(
                              context,
                              'Developer Settings',
                              deviceType,
                            ),
                            SizedBox(
                              height: ResponsiveUtils.responsiveScale(
                                mobile: constraints.maxHeight < 600 ? 12 : 16,
                                deviceType: deviceType,
                              ),
                            ),
                            // Image Upload Toggle
                            _buildSwitchTile(
                              context: context,
                              title: 'Enable Image Uploads',
                              subtitle: vm.isImageUploadEnabled
                                  ? 'Users can upload images'
                                  : 'Image uploads are disabled',
                              value: vm.isImageUploadEnabled,
                              onChanged: (value) =>
                                  vm.toggleImageUpload(context, value),
                              deviceType: deviceType,
                            ),
                            SizedBox(
                              height: ResponsiveUtils.responsiveScale(
                                mobile: constraints.maxHeight < 600 ? 12 : 16,
                                deviceType: deviceType,
                              ),
                            ),
                          ],

                          // Bottom spacing for better visual balance
                          SizedBox(
                            height: ResponsiveUtils.responsiveScale(
                              mobile: constraints.maxHeight < 600
                                  ? 16
                                  : 24, // Reduced spacing to prevent overflow
                              deviceType: deviceType,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Build section header widget
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    DeviceType deviceType,
  ) {
    return Text(
      title,
      style: TextStyle(
        fontSize: ResponsiveUtils.responsiveScale(
          mobile: 20,
          deviceType: deviceType,
        ),
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  // Build switch tile widget
  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required DeviceType deviceType,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveScale(
          mobile: 12,
          deviceType: deviceType,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveScale(
            mobile: 16,
            deviceType: deviceType,
          ),
          vertical: ResponsiveUtils.responsiveScale(
            mobile: 4,
            deviceType: deviceType,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveScale(
              mobile: 16,
              deviceType: deviceType,
            ),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveScale(
              mobile: 14,
              deviceType: deviceType,
            ),
            color: Colors.grey[600],
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        secondary: Icon(
          Icons.image_outlined,
          color: value ? Theme.of(context).primaryColor : Colors.grey[600],
          size: ResponsiveUtils.scaledIconSize(
            mobile: 24,
            deviceType: deviceType,
          ),
        ),
      ),
    );
  }

  // Build text field widget
  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required DeviceType deviceType,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      inputFormatters: inputFormatters,
      style: TextStyle(
        fontSize: ResponsiveUtils.responsiveScale(
          mobile: 15,
          deviceType: deviceType,
        ),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          fontSize: ResponsiveUtils.responsiveScale(
            mobile: 15,
            deviceType: deviceType,
          ),
        ),
        prefixIcon: Padding(
          padding: EdgeInsetsDirectional.only(
            start: ResponsiveUtils.responsiveScale(
              mobile: 8,
              deviceType: deviceType,
            ),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: ResponsiveUtils.scaledIconSize(
              mobile: 22,
              deviceType: deviceType,
            ),
          ),
        ),
        prefixIconConstraints: BoxConstraints(
          minWidth: ResponsiveUtils.responsiveScale(
            mobile: 44,
            deviceType: deviceType,
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveScale(
            mobile: 12, // Reduced padding to prevent overflow
            deviceType: deviceType,
          ),
          vertical: ResponsiveUtils.responsiveScale(
            mobile: 12, // Reduced padding to prevent overflow
            deviceType: deviceType,
          ),
        ),
      ),
    );
  }

  // Build action tile widget
  Widget _buildActionTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required DeviceType deviceType,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(
        bottom: ResponsiveUtils.responsiveScale(
          mobile: 12,
          deviceType: deviceType,
        ),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.responsiveScale(
            mobile: 16,
            deviceType: deviceType,
          ),
          vertical: ResponsiveUtils.responsiveScale(
            mobile: 8,
            deviceType: deviceType,
          ),
        ),
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Theme.of(context).primaryColor,
          size: ResponsiveUtils.scaledIconSize(
            mobile: 24,
            deviceType: deviceType,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveScale(
              mobile: 16,
              deviceType: deviceType,
            ),
            fontWeight: FontWeight.w600,

            color: isDestructive ? Colors.red : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: ResponsiveUtils.responsiveScale(
              mobile: 14,
              deviceType: deviceType,
            ),
            color: Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).primaryColor,
          size: ResponsiveUtils.scaledIconSize(
            mobile: 20,
            deviceType: deviceType,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

/// ViewModel for Settings Scene
/// Manages user settings, form validation, and theme management
class ViewModel extends ChangeNotifier {
  // Form key for validation
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Services
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Controllers for form fields
  final TextEditingController emailController = TextEditingController();

  // State variables
  bool _isDarkTheme = false;
  bool isLoadingRole = true;
  bool isDeveloper = false;
  bool isImageUploadEnabled = true; // Default enabled

  // Getters
  bool get isDarkTheme => _isDarkTheme;

  // Setter for dark theme with theme manager integration
  set isDarkTheme(bool value) {
    _isDarkTheme = value;
    ThemeManager().setTheme(value);
    notifyListeners();
  }

  ViewModel() {
    _loadUserData();
    _checkUserRole();
    _loadImageUploadSetting();
    // Sync with theme manager
    _isDarkTheme = ThemeManager().isDarkTheme;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Load existing user data, prefer the email stored in Firestore (signup) and
  // fall back to FirebaseAuth currentUser.email
  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      // Try to read user doc from Firestore to prefer persisted email
      try {
        final data = await _userService.getUserData(user.uid);
        final firestoreEmail = data?['email'] as String?;
        emailController.text = firestoreEmail ?? user.email ?? '';
      } catch (_) {
        // If Firestore read fails for any reason, fall back to auth email
        emailController.text = user.email ?? '';
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  // Check if user is admin or developer
  Future<void> _checkUserRole() async {
    try {
      final role = await _authService.getUserRole();
      isDeveloper = (role == 'developer');
      isLoadingRole = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking user role: $e');
      isLoadingRole = false;
      isDeveloper = false;
      notifyListeners();
    }
  }

  // Load image upload setting from SharedPreferences
  Future<void> _loadImageUploadSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isImageUploadEnabled = prefs.getBool('imageUploadEnabled') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading image upload setting: $e');
      isImageUploadEnabled = true;
      notifyListeners();
    }
  }

  // Validation methods
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Action methods
  void saveChanges(BuildContext context) async {
    if (formKey.currentState?.validate() ?? false) {
      // TODO: Save contact data to database/API

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact information saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void changePassword(BuildContext context) {
    NavigationHelper.push(context, change_password.View());
  }

  // Toggle image upload setting
  Future<void> toggleImageUpload(BuildContext context, bool value) async {
    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('imageUploadEnabled', value);

      // Update state
      isImageUploadEnabled = value;
      notifyListeners();

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Image uploads enabled for all users'
                  : 'Image uploads disabled for all users',
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error toggling image upload: $e');
      if (context.mounted) {
        NavigationHelper.showErrorSnackBar(
          context,
          message: 'Failed to update image upload setting',
        );
      }
    }
  }

  void logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        // Sign out from Firebase
        await _authService.signOut();

        if (context.mounted) {
          // Show success message
          NavigationHelper.showSuccessSnackBar(
            context,
            message: 'Logged out successfully',
          );

          // Navigate to login screen and remove all previous routes
          NavigationHelper.pushAndRemoveUntil(context, login_scene.View());
        }
      } catch (e) {
        if (context.mounted) {
          NavigationHelper.showErrorSnackBar(
            context,
            message: 'Failed to logout: ${e.toString()}',
          );
        }
      }
    }
  }
}
