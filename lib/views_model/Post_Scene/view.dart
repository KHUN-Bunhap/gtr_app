import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../ui_utils/button.dart';
import '../../ui_utils/utils.dart';
import '../../services/post_service.dart';
import 'ui.dart';

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
            appBar: UIHelpers.gtrAppBar(title: 'Create Post', context: context),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                  constraints,
                );

                return SingleChildScrollView(
                  padding: EdgeInsets.all(
                    ResponsiveUtils.responsiveScale(
                      mobile: 16.0,
                      deviceType: deviceType,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Selection
                      DropdownButtonFormField<String>(
                        initialValue: vm.selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(
                            fontSize: PostSceneUI.getBodyFontSize(deviceType),
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: PostSceneUI.getResponsivePadding(
                              deviceType,
                            ),
                            vertical: PostSceneUI.getResponsivePadding(
                              deviceType,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: PostSceneUI.getBodyFontSize(deviceType),
                          color: Colors.black,
                        ),
                        dropdownColor:
                            Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                        items: vm.categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: PostSceneUI.getBodyFontSize(
                                      deviceType,
                                    ),
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: vm.setSelectedCategory,
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 16,
                          deviceType: deviceType,
                        ),
                      ),

                      // Post Type Selection
                      Text(
                        'Post Type',
                        style: TextStyle(
                          fontSize: PostSceneUI.getLargeFontSize(deviceType),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 8,
                          deviceType: deviceType,
                        ),
                      ),

                      SegmentedButton<PostType>(
                        segments: [
                          ButtonSegment(
                            value: PostType.markdown,
                            label: Text(
                              'Text',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: PostSceneUI.getSmallFontSize(
                                  deviceType,
                                ),
                              ),
                            ),
                            icon: Icon(
                              color: Theme.of(context).primaryColor,
                              Icons.code,
                              size: PostSceneUI.getResponsiveIconSize(
                                deviceType,
                              ),
                            ),
                          ),
                          ButtonSegment(
                            value: PostType.math,
                            label: Text(
                              'Math',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: PostSceneUI.getSmallFontSize(
                                  deviceType,
                                ),
                              ),
                            ),
                            icon: Icon(
                              Icons.functions,
                              color: Theme.of(context).primaryColor,
                              size: PostSceneUI.getResponsiveIconSize(
                                deviceType,
                              ),
                            ),
                          ),
                        ],
                        selected: {vm.selectedType},
                        onSelectionChanged: vm.setSelectedType,
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 12,
                          deviceType: deviceType,
                        ),
                      ),

                      // Title Input
                      TextField(
                        controller: vm.titleController,
                        decoration: InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(
                            fontSize: PostSceneUI.getSmallFontSize(deviceType),
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: PostSceneUI.getResponsivePadding(
                              deviceType,
                            ),
                            vertical: PostSceneUI.getResponsivePadding(
                              deviceType,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: PostSceneUI.getBodyFontSize(deviceType),
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 20,
                          deviceType: deviceType,
                        ),
                      ),

                      // Content Input
                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 200,
                          deviceType: deviceType,
                        ),
                        child: TextField(
                          controller: vm.contentController,
                          onChanged: vm.onContentChanged,
                          decoration: InputDecoration(
                            labelText: vm.getContentLabel(),
                            labelStyle: TextStyle(
                              fontSize: PostSceneUI.getBodyFontSize(deviceType),
                            ),
                            border: const OutlineInputBorder(),
                            hintText: vm.getContentHint(),
                            hintStyle: TextStyle(
                              fontSize: PostSceneUI.getSmallFontSize(
                                deviceType,
                              ),
                            ),
                            contentPadding: EdgeInsets.all(
                              PostSceneUI.getResponsivePadding(deviceType),
                            ),
                            helperText: vm.getHelperText(),
                            helperStyle: TextStyle(
                              fontSize: PostSceneUI.getHelperFontSize(
                                deviceType,
                              ),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: TextStyle(
                            fontSize: PostSceneUI.getBodyFontSize(deviceType),
                            fontFamily: vm.selectedType == PostType.math
                                ? 'monospace'
                                : null,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 16,
                          deviceType: deviceType,
                        ),
                      ),

                      // Image Picker Button
                      OutlinedButton.icon(
                        onPressed: () => vm.pickImage(context),
                        icon: Icon(
                          Icons.image,
                          size: PostSceneUI.getResponsiveIconSize(deviceType),
                        ),
                        label: Text(
                          vm.selectedImage == null
                              ? 'Add Image (Optional)'
                              : 'Change Image',
                          style: TextStyle(
                            fontSize: PostSceneUI.getBodyFontSize(deviceType),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.all(
                            PostSceneUI.getResponsivePadding(deviceType),
                          ),
                        ),
                      ),

                      // Image Preview
                      if (vm.selectedImage != null)
                        Column(
                          children: [
                            SizedBox(
                              height: ResponsiveUtils.responsiveScale(
                                mobile: 12,
                                deviceType: deviceType,
                              ),
                            ),
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(
                                          vm.selectedImage!.path,
                                          height:
                                              ResponsiveUtils.responsiveScale(
                                                mobile: 200,
                                                deviceType: deviceType,
                                              ),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          vm.selectedImage!,
                                          height:
                                              ResponsiveUtils.responsiveScale(
                                                mobile: 200,
                                                deviceType: deviceType,
                                              ),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: vm.removeImage,
                                    icon: const Icon(Icons.close),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                      // Markdown Preview Section
                      if (vm.selectedType == PostType.markdown &&
                          vm.contentController.text.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: ResponsiveUtils.responsiveScale(
                                mobile: 16,
                                deviceType: deviceType,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxHeight: ResponsiveUtils.responsiveScale(
                                  mobile: 300,
                                  deviceType: deviceType,
                                ),
                              ),
                              padding: EdgeInsets.all(
                                PostSceneUI.getResponsivePadding(deviceType),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preview:',
                                    style: TextStyle(
                                      fontSize: PostSceneUI.getBodyFontSize(
                                        deviceType,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: PostSceneUI.getResponsiveSpacing(
                                      deviceType,
                                    ),
                                  ),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Markdown(
                                        data: vm.contentController.text,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        styleSheet: MarkdownStyleSheet(
                                          p: TextStyle(
                                            fontSize:
                                                PostSceneUI.getBodyFontSize(
                                                  deviceType,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      // Math Preview Section
                      if (vm.selectedType == PostType.math &&
                          vm.contentController.text.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: ResponsiveUtils.responsiveScale(
                                mobile: 16,
                                deviceType: deviceType,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(
                                PostSceneUI.getResponsivePadding(deviceType),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Preview:',
                                    style: TextStyle(
                                      fontSize: PostSceneUI.getBodyFontSize(
                                        deviceType,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  SizedBox(
                                    height: PostSceneUI.getResponsiveSpacing(
                                      deviceType,
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: PostSceneUI.buildMathPreview(
                                      vm.contentController.text,
                                      deviceType,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      SizedBox(
                        height: ResponsiveUtils.responsiveScale(
                          mobile: 32,
                          deviceType: deviceType,
                        ),
                      ),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: PostSceneUI.getBodyFontSize(
                                  deviceType,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: PostSceneUI.getResponsiveSpacing(deviceType),
                          ),
                          GTRButton.primary(
                            onPressed: vm.canPost
                                ? () async => await vm.createPost(context)
                                : null,
                            text: 'Post',
                            height: 50,
                            isLoading: vm.isLoading,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Post types enum
enum PostType { markdown, math }

class Post {
  final String id;
  final String title;
  final String content;
  final String author;
  final String userId; // Add userId to track post owner
  final String category;
  final DateTime createdAt;
  final PostType type;
  final int likes;
  final int comments;
  final bool isLiked;
  final String? imageUrl;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.userId,
    required this.category,
    required this.createdAt,
    this.type = PostType.markdown,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
    this.imageUrl,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class ViewModel extends ChangeNotifier {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final PostService _postService = PostService();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory;
  PostType _selectedType = PostType.markdown;
  File? _selectedImage;
  bool _isLoading = false;

  final List<String> categories = [
    'Announcement',
    'Assignment',
    'Lecture',
    'Q&A',
  ];

  String? get selectedCategory => _selectedCategory;
  PostType get selectedType => _selectedType;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;

  bool get canPost =>
      titleController.text.trim().isNotEmpty &&
      contentController.text.trim().isNotEmpty &&
      !_isLoading;

  void setSelectedCategory(String? category) {
    if (category != null) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  void setSelectedType(Set<PostType> types) {
    if (types.isNotEmpty) {
      _selectedType = types.first;
      notifyListeners();
    }
  }

  void onContentChanged(String value) {
    notifyListeners(); // Trigger rebuild for preview
  }

  String getContentLabel() {
    switch (_selectedType) {
      case PostType.markdown:
        return 'Content (Markdown supported)';
      case PostType.math:
        return 'Mathematical Expression (LaTeX)';
    }
  }

  String getContentHint() {
    switch (_selectedType) {
      case PostType.markdown:
        return '## Heading\n**Bold text**\n- List item\n![Image](url)';
      case PostType.math:
        return r'\frac{d}{dx}\left( \int_{0}^{x} f(u) \, du\right) = f(x)';
    }
  }

  String? getHelperText() {
    switch (_selectedType) {
      case PostType.math:
        return 'Use LaTeX syntax for mathematical expressions';
      default:
        return null;
    }
  }

  // Image picker methods
  Future<void> pickImage(BuildContext context) async {
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

      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return;

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  void removeImage() {
    _selectedImage = null;
    notifyListeners();
  }

  Future<void> createPost(BuildContext context) async {
    if (!canPost) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _postService.createPost(
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        category: selectedCategory ?? 'General',
        postType: selectedType == PostType.markdown ? 'markdown' : 'math',
        imageFile: _selectedImage,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Clear form
        titleController.clear();
        contentController.clear();
        _selectedImage = null;
        _selectedCategory = null;
        _selectedType = PostType.markdown;

        // Navigate back
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}
