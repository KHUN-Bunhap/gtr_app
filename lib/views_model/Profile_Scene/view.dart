// Flutter imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// App utilities
import '../../ui_utils/utils.dart';
import '../../ui_utils/button.dart';

// Services
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

// Profile scene - user profile management
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
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive design
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Stack(
                      children: [
                        // Background image section
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Stack(
                            children: [
                              // Background container
                              Container(
                                height: (deviceType != DeviceType.mobile)
                                    ? 175
                                    : (200),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: vm.backgroundImage != null
                                      ? DecorationImage(
                                          image: FileImage(vm.backgroundImage!),
                                          fit: BoxFit.cover,
                                        )
                                      : const DecorationImage(
                                          image: AssetImage(
                                            'lib/assets/itc_logo.png',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                // Gradient overlay
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(
                                          0.3,
                                        ), // Subtle dark overlay at bottom
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Background Image Change Button - positioned over background
                              Positioned(
                                bottom: ResponsiveUtils.responsiveScale(
                                  mobile: 12.0,
                                  deviceType: deviceType,
                                ),
                                right: ResponsiveUtils.responsiveScale(
                                  mobile: 12.0,
                                  deviceType: deviceType,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    onPressed: () =>
                                        vm.changeBackgroundPicture(context),
                                    icon: Icon(
                                      Icons.photo_camera,
                                      color: Colors.white,
                                      size: ResponsiveUtils.scaledIconSize(
                                        mobile: 18,
                                        deviceType: deviceType,
                                      ),
                                    ),
                                    tooltip: 'Change Background',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Floating Action Button - Main edit profile button
                        Positioned(
                          bottom: ResponsiveUtils.responsiveScale(
                            mobile: 20.0,
                            deviceType: deviceType,
                          ),
                          right: ResponsiveUtils.responsiveScale(
                            mobile: 20.0,
                            deviceType: deviceType,
                          ),
                          child: FloatingActionButton(
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () => _showEditDialog(
                              context,
                              vm,
                              (deviceType != DeviceType.mobile),
                            ),
                            tooltip: 'Edit Profile Info',
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                        // Main Profile Content - User information and profile picture
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.all(
                              ResponsiveUtils.responsiveScale(
                                mobile: 16.0,
                                deviceType: deviceType,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 75), // Space below background
                                // Profile Avatar Section - with camera button for image changes
                                Stack(
                                  children: [
                                    // Profile Picture with Border - responsive sizing based on device and orientation
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).primaryColor,
                                          width: 4.0, // Border thickness
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            spreadRadius: 2,
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius:
                                            (deviceType != DeviceType.mobile)
                                            ? (85) // Tablet: larger avatar
                                            : (70), // Phone: smaller avatar
                                        backgroundImage: vm.profileImage != null
                                            ? FileImage(
                                                vm.profileImage!,
                                              ) // User's custom profile image
                                            : const AssetImage(
                                                'lib/assets/gtr_logo.png',
                                              ), // Default GTR logo
                                      ),
                                    ),
                                    // Profile Image Change Button - positioned over avatar
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: IconButton(
                                          onPressed: () =>
                                              vm.changeProfilePicture(context),
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size:
                                                ResponsiveUtils.responsiveScale(
                                                  mobile: 18,
                                                  deviceType: deviceType,
                                                ),
                                          ),
                                          tooltip: 'Change Profile Picture',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: (deviceType != DeviceType.mobile)
                                      ? (18)
                                      : (14),
                                ),

                                // User Information Display Section - responsive typography
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Full Name Display - primary user identifier
                                    Text(
                                      vm.fullName.isNotEmpty
                                          ? vm.fullName
                                          : 'Full Name',
                                      style: TextStyle(
                                        fontSize:
                                            (deviceType != DeviceType.mobile)
                                            ? (28) // Tablet: larger text
                                            : (24), // Phone: moderate text
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),

                                    // Username Display - secondary identifier with @ symbol
                                    Text(
                                      '@${vm.username.isNotEmpty ? vm.username : 'username'}',
                                      style: TextStyle(
                                        fontSize:
                                            (deviceType != DeviceType.mobile)
                                            ? (20)
                                            : (18),
                                        fontWeight: FontWeight.w500,
                                        color: Colors
                                            .grey[700], // Muted color for username
                                      ),
                                    ),

                                    SizedBox(
                                      height: ResponsiveUtils.responsiveScale(
                                        mobile: 6,
                                        deviceType: deviceType,
                                      ),
                                    ),

                                    // Bio Display - user description with fallback text
                                    Text(
                                      vm.bio.isNotEmpty
                                          ? vm.bio
                                          : 'No bio available',
                                      style: TextStyle(
                                        fontSize:
                                            (deviceType != DeviceType.mobile)
                                            ? (18)
                                            : (16),
                                        fontWeight: FontWeight.normal,
                                        height:
                                            1.4, // Line height for readability
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),

                                    SizedBox(
                                      height: ResponsiveUtils.responsiveScale(
                                        mobile: 20,
                                        deviceType: deviceType,
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
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, ViewModel user, bool isLandscape) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return _EditProfileDialog(
          user: user,
          validateUsername: validateUsername,
          validateFullName: validateFullName,
          validateBio: validateBio,
        );
      },
    );
  } // Validation methods

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain lowercase letters, numbers, and underscores';
    }
    return null;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }
    if (value.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? validateBio(String? value) {
    if (value != null && value.length > 100) {
      return 'Bio must be 100 characters or less';
    }
    return null;
  }
}

class _EditProfileDialog extends StatefulWidget {
  final ViewModel user;
  final String? Function(String?)? validateUsername;
  final String? Function(String?)? validateFullName;
  final String? Function(String?)? validateBio;

  const _EditProfileDialog({
    required this.user,
    required this.validateUsername,
    required this.validateFullName,
    required this.validateBio,
  });

  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final formKey = GlobalKey<FormState>();
  late DeviceType deviceType;

  @override
  void initState() {
    super.initState();
    // Add listener to update character count
    widget.user.bioController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceType = ResponsiveUtils.getDeviceTypeFromContext(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: (deviceType != DeviceType.mobile) ? 600 : double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsiveScale(
                  mobile: 16,
                  deviceType: deviceType,
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.responsiveScale(
                        mobile: 18,
                        deviceType: deviceType,
                      ),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content with Form
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  ResponsiveUtils.responsiveScale(
                    mobile: 16,
                    deviceType: deviceType,
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.responsiveScale(
                            mobile: 16,
                            deviceType: deviceType,
                          ),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 16,
                          deviceType: deviceType,
                        ),
                      ),

                      // Full Name field with validation
                      _buildEditTextField(
                        controller: widget.user.fullNameController,
                        label: 'Full Name',
                        icon: Icons.badge_outlined,
                        validator: widget.validateFullName,
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 12,
                          deviceType: deviceType,
                        ),
                      ),
                      // Username field with validation
                      _buildEditTextField(
                        controller: widget.user.usernameController,
                        label: 'Username',
                        icon: Icons.person_outline,
                        validator: widget.validateUsername,
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 12,
                          deviceType: deviceType,
                        ),
                      ),
                      // Bio field with character count
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditTextField(
                            controller: widget.user.bioController,
                            label: 'Bio',
                            icon: Icons.info_outline,
                            maxLines: 3,
                            validator: widget.validateBio,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${widget.user.bioController.text.length}/100',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.responsiveScale(
                                  mobile: 10,
                                  deviceType: deviceType,
                                ),
                                color:
                                    widget.user.bioController.text.length > 100
                                    ? AppColors.error
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(
                ResponsiveUtils.responsiveScale(
                  mobile: 16,
                  deviceType: deviceType,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveScale(
                          mobile: 14,
                          deviceType: deviceType,
                        ),
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GTRButton.primary(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        widget.user.updateProfileInfo(
                          widget.user.fullNameController.text,
                          widget.user.usernameController.text,
                          widget.user.bioController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    text: 'Save Changes',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: TextStyle(
        fontSize: ResponsiveUtils.responsiveScale(
          mobile: 14,
          deviceType: deviceType,
        ),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: ResponsiveUtils.responsiveScale(
            mobile: 14,
            deviceType: deviceType,
          ),
        ),
      ),
    );
  }
}

class ViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  // Core state management
  bool _isLoading = false;
  String? _errorMessage;

  // Text controllers for form inputs
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final bioController = TextEditingController();

  // Image properties for profile customization
  File? _backgroundImage;
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // User data properties with default values
  String _fullName = 'Full Name';
  String _username = 'username';
  String _bio = 'This user is too lazy to write a bio';
  String? _email;
  String? _phoneNumber;
  String? _profileImageUrl;
  String? _coverImageUrl;

  // Getters for accessing state
  File? get backgroundImage => _backgroundImage;
  File? get profileImage => _profileImage;
  String get fullName => _fullName;
  String get username => _username;
  String get bio => _bio;
  String? get email => _email;
  String? get phoneNumber => _phoneNumber;
  String? get profileImageUrl => _profileImageUrl;
  String? get coverImageUrl => _coverImageUrl;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ViewModel() {
    // Load user profile from Firebase
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      _setLoading(true);
      _clearError();

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        _setError('User not logged in');
        return;
      }

      // Stream user data from Firebase
      _userService.getUserStream(userId).listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;

          _fullName = data['fullName'] ?? 'Full Name';
          // Prefer stored 'username' (generated at sign-up). Fall back to studentId for legacy accounts.
          _username = data['username'] ?? data['studentId'] ?? 'username';
          _bio = data['bio'] ?? 'This user is too lazy to write a bio';
          _email = data['email'];
          _phoneNumber = data['phoneNumber'];
          _profileImageUrl = data['profileImageUrl'];
          _coverImageUrl = data['coverImageUrl'];

          // Update controllers
          fullNameController.text = _fullName;
          usernameController.text = _username;
          bioController.text = _bio;

          notifyListeners();
        }
      });
    } catch (e) {
      _setError('Failed to load profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Image handling methods - Connect to picker functionality with context for dialogs
  void changeBackgroundPicture(BuildContext context) async {
    await pickImage(false, context); // false = background image
  }

  void changeProfilePicture(BuildContext context) async {
    await pickImage(true, context); // true = profile image
  }

  Future<void> updateProfileInfo(
    String fullName,
    String username,
    String bio,
  ) async {
    try {
      _setLoading(true);
      _clearError();

      final userId = _authService.currentUser?.uid;
      if (userId == null) throw 'User not logged in';

      // Update in Firebase
      // Persist username as well to the user document for future reads
      await _userService.updateUserProfile(
        userId: userId,
        fullName: fullName,
        bio: bio,
        username: username,
      );

      // Update local state
      _fullName = fullName;
      _username = username;
      _bio = bio;

      // Update controllers
      fullNameController.text = fullName;
      usernameController.text = username;
      bioController.text = bio;

      notifyListeners();
    } catch (e) {
      _setError('Failed to update profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods for state management
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  Future<void> pickImage(bool isProfile, BuildContext context) async {
    try {
      // Check if image uploads are enabled
      final prefs = await SharedPreferences.getInstance();
      final isImageUploadEnabled = prefs.getBool('imageUploadEnabled') ?? true;

      if (!isImageUploadEnabled) {
        // Show message that uploads are disabled
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Image uploads are currently disabled by administrator',
              ),
              backgroundColor: Colors.orange[700],
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }
        return; // Exit without allowing upload
      }

      _setLoading(true);
      _clearError();

      // Show source selection dialog (Gallery or Camera)
      final ImageSource? source = await _showImageSourceDialog(context);

      if (source != null) {
        final pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: isProfile ? 512 : 1024, // Optimize for upload size
          maxHeight: isProfile ? 512 : 1024,
          imageQuality: 85, // Balance quality and file size
        );

        if (pickedFile != null) {
          final selectedFile = File(pickedFile.path);

          // Update local state immediately for UI feedback
          if (isProfile) {
            _profileImage = selectedFile;
          } else {
            _backgroundImage = selectedFile;
          }
          notifyListeners();

          // Upload to Firebase Storage
          final userId = _authService.currentUser?.uid;
          if (userId != null) {
            String imageUrl;
            if (isProfile) {
              imageUrl = await _userService.uploadProfileImage(
                userId,
                selectedFile,
              );
              _profileImageUrl = imageUrl;
            } else {
              imageUrl = await _userService.uploadCoverImage(
                userId,
                selectedFile,
              );
              _coverImageUrl = imageUrl;
            }
          }

          // Show success feedback
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isProfile
                      ? 'Profile picture updated!'
                      : 'Cover image updated!',
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      }
    } catch (e) {
      _setError('Failed to update image: ${e.toString()}');

      // Show error feedback to user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  /// Show dialog to select image source (Camera or Gallery)
  /// @param context - BuildContext for dialog display
  /// Returns the selected ImageSource or null if cancelled
  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Text(
                  'Select Image Source',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Camera option
                ListTile(
                  leading: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  title: const Text('Camera'),
                  subtitle: const Text('Take a new photo'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),

                // Gallery option
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).primaryColor,
                    size: 28,
                  ),
                  title: const Text('Gallery'),
                  subtitle: const Text('Choose from existing photos'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    bioController.dispose();
    super.dispose();
  }
}
