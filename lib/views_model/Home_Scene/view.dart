// Flutter imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'dart:async';

// App utilities
import '../../ui_utils/utils.dart';
import '../Post_Scene/view.dart' as postscene;
import '../Post_Scene/view.dart' show PostType, Post;

// Services
import '../../services/post_service.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

// Home scene - social feed interface
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
          // Responsive layout detection
          return LayoutBuilder(
            builder: (context, constraints) {
              final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                constraints,
              );
              return Scaffold(
                body: Column(
                  children: [
                    // Posts feed
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          vm.refreshPosts();
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: deviceType == DeviceType.mobile
                                ? 0
                                : ResponsiveUtils.scaledIconSize(
                                    mobile: 24,
                                    deviceType: deviceType,
                                  ),
                          ),
                          itemCount: vm.filteredPosts.length,
                          itemBuilder: (context, index) {
                            final post = vm.filteredPosts[index];
                            return PostCard(post: post);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // Create post button
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _navigateToPostScene(context),
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: ResponsiveUtils.scaledIconSize(
                      mobile: 24,
                      deviceType: deviceType,
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

  // Navigate to Post Scene for creating posts
  void _navigateToPostScene(BuildContext context) async {
    final vm = context.read<ViewModel>();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const postscene.View()),
    );

    // If a post was created, add it to the home feed
    if (result != null && result is Post) {
      vm.addPost(result);
    }
  }
}

// Individual post card widget
class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

/// PostCard State - Manages local state for post interactions
/// Handles like animation, comment display, and user interactions
class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  // Local state variables for post interactions
  late bool isLiked; // Track if user has liked the post
  late int likeCount; // Current number of likes
  late AnimationController
  _animationController; // Controls like button animation
  late Animation<double> _scaleAnimation; // Scale animation for like button

  @override
  void initState() {
    super.initState();
    // Initialize state
    isLiked = widget.post.isLiked;
    likeCount = widget.post.likes;

    // Animation setup
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'announcement':
        return Colors.red;
      case 'assignment':
        return Colors.blue;
      case 'lecture':
        return Colors.green;
      case 'q&a':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Toggle like with animation and Firebase update
  void _toggleLike() {
    // Update local state for immediate feedback
    setState(() {
      if (isLiked) {
        likeCount--;
        isLiked = false;
      } else {
        likeCount++;
        isLiked = true;
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }
    });

    // Update Firebase through ViewModel
    final vm = context.read<ViewModel>();
    vm.togglePostLike(widget.post.id);

    // Show feedback
    UIHelpers.showSnackBar(
      context,
      isLiked ? 'Post liked!' : 'Like removed',
      duration: const Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
          constraints,
        );
        final isTablet = deviceType != DeviceType.mobile;

        return Card(
          margin: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 8,
            vertical: 8,
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post header
                Row(
                  children: [
                    // Author avatar
                    CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: isTablet ? 24 : 20,
                      child: Text(
                        widget.post.author[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 18 : 14,
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 16 : 12),
                    // Author info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Author Name
                              Text(
                                widget.post.author,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isTablet ? 18 : 16,
                                ),
                              ),
                              SizedBox(width: isTablet ? 12 : 8),
                              // Category Badge - Colored container showing post category
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet ? 12 : 8,
                                  vertical: isTablet ? 4 : 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    widget.post.category,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.post.category,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Posted ${_formatTimeAgo(widget.post.createdAt)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isTablet ? 14 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Delete button - shown for admin/teachers or post owner
                    Builder(
                      builder: (builderContext) {
                        return FutureBuilder<bool>(
                          future: Provider.of<ViewModel>(
                            builderContext,
                            listen: false,
                          ).canDeletePost(widget.post.userId),
                          builder: (context, snapshot) {
                            if (snapshot.data == true) {
                              return IconButton(
                                icon: const Icon(Icons.delete_outline),
                                color: Colors.red,
                                onPressed: () =>
                                    _showDeleteConfirmDialog(builderContext),
                                tooltip: 'Delete post',
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
                // Post title
                Text(
                  widget.post.title,
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                // Post content - Dynamic rendering based on type
                if (widget.post.type == PostType.math)
                  // Math content rendering
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 16 : 12),
                    decoration: BoxDecoration(
                      // color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).primaryColor),
                    ),
                    child: Math.tex(
                      widget.post.content,
                      textStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                    ),
                  )
                else
                  // Regular text content with Markdown support
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: isTablet ? 300 : 200,
                    ),
                    child: SingleChildScrollView(
                      child: MarkdownBody(
                        data: widget.post.content,
                        styleSheet: MarkdownStyleSheet(
                          p: TextStyle(fontSize: isTablet ? 16 : 14),
                        ),
                      ),
                    ),
                  ),
                // Display image if available
                if (widget.post.imageUrl != null) ...[
                  SizedBox(height: isTablet ? 16 : 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      widget.post.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 48),
                        );
                      },
                    ),
                  ),
                ],
                SizedBox(height: isTablet ? 20 : 16),
                // Post actions
                Row(
                  children: [
                    // Like button with animation
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: IconButton(
                        onPressed: _toggleLike,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey[600],
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                    ),
                    Text(
                      '$likeCount',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: isTablet ? 24 : 16),
                    // Comments button
                    IconButton(
                      onPressed: () => _showCommentsDialog(context),
                      icon: Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.grey[600],
                        size: isTablet ? 28 : 24,
                      ),
                    ),
                    Text(
                      '${widget.post.comments}',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Format time ago helper
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmDialog(BuildContext context) {
    final viewModel = Provider.of<ViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await viewModel.deletePost(widget.post.id);
                  if (context.mounted) {
                    UIHelpers.showSnackBar(
                      context,
                      'Post deleted successfully',
                      duration: const Duration(seconds: 2),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    UIHelpers.showSnackBar(
                      context,
                      'Failed to delete post: ${e.toString()}',
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Show comments dialog
  void _showCommentsDialog(BuildContext context) {
    final vm = context.read<ViewModel>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
                constraints,
              );
              return Container(
                width: deviceType == DeviceType.mobile
                    ? double.infinity
                    : ResponsiveUtils.scaledIconSize(
                        mobile: 500,
                        deviceType: deviceType,
                        tabletScale: 1.0,
                        computerScale: 1.2,
                      ),
                height: ResponsiveUtils.scaledIconSize(
                  mobile: 400,
                  deviceType: deviceType,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.responsiveScale(
                          mobile: 20,
                          deviceType: deviceType,
                        ),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder(
                        stream: vm.getCommentsStream(widget.post.id),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('No comments yet'));
                          }

                          return ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              final commentDoc = snapshot.data!.docs[index];
                              final commentData =
                                  commentDoc.data() as Map<String, dynamic>;
                              return _buildCommentTile(
                                context,
                                commentDoc.id,
                                commentData['userId'] ?? '',
                                commentData['comment'] ?? '',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Build comment tile widget with delete button
  Widget _buildCommentTile(
    BuildContext context,
    String commentId,
    String commentUserId,
    String comment,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceTypeFromConstraints(
          constraints,
        );
        final isTablet = deviceType != DeviceType.mobile;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: isTablet ? 20 : 16,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.7),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  comment,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              // Delete button for comments
              Builder(
                builder: (builderContext) {
                  final viewModel = Provider.of<ViewModel>(
                    builderContext,
                    listen: false,
                  );
                  return FutureBuilder<bool>(
                    future: viewModel.canDeleteComment(commentUserId),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return IconButton(
                          icon: const Icon(Icons.delete_outline),
                          iconSize: isTablet ? 20 : 16,
                          color: Colors.red,
                          onPressed: () => _showDeleteCommentDialog(
                            builderContext,
                            commentId,
                            viewModel,
                          ),
                          tooltip: 'Delete comment',
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show delete comment confirmation dialog
  void _showDeleteCommentDialog(
    BuildContext context,
    String commentId,
    ViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Comment'),
          content: const Text('Are you sure you want to delete this comment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                try {
                  await viewModel.deleteComment(widget.post.id, commentId);
                  if (context.mounted) {
                    UIHelpers.showSnackBar(
                      context,
                      'Comment deleted successfully',
                      duration: const Duration(seconds: 2),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    UIHelpers.showSnackBar(
                      context,
                      'Failed to delete comment',
                      duration: const Duration(seconds: 3),
                    );
                  }
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

/// ViewModel for Home Scene
/// Manages posts data, search functionality, and state management
class ViewModel extends ChangeNotifier {
  // Services
  final PostService _postService = PostService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();

  // Posts data
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];

  // Map to cache user data (userId -> username)
  final Map<String, String> _userCache = {};

  // UI state
  bool _isLoading = true;
  String? _errorMessage;

  // Search and filtering
  final TextEditingController searchController = TextEditingController();
  Set<String> activeFilters = {};

  // Stream subscription
  StreamSubscription? _postsSubscription;

  // Getters for UI
  List<Post> get filteredPosts => _filteredPosts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor - load posts from Firebase
  ViewModel() {
    _loadPostsFromFirebase();
  }

  // Load posts from Firebase with real-time updates
  void _loadPostsFromFirebase() {
    _postsSubscription = _postService
        .getPostsStream(limit: 100)
        .listen(
          (snapshot) async {
            final posts = <Post>[];

            for (var doc in snapshot.docs) {
              try {
                final data = doc.data() as Map<String, dynamic>;
                final userId = data['userId'] as String;

                String fullName = _userCache[userId] ?? 'Anonymous';

                // Get name from cache or fetch from Firebase
                if (!_userCache.containsKey(userId)) {
                  try {
                    final userData = await _userService.getUserData(userId);
                    if (userData != null) {
                      // Prefer stored fullName, then studentId, then username
                      fullName =
                          userData['fullName'] ??
                          userData['studentId'] ??
                          userData['username'] ??
                          'Anonymous';
                      _userCache[userId] = fullName;
                    }
                  } catch (e) {
                    fullName = 'Anonymous';
                  }
                }

                final post = Post(
                  id: doc.id,
                  title: data['title'] ?? '',
                  content: data['content'] ?? '',
                  author: fullName,
                  userId: userId,
                  category: data['category'] ?? 'General',
                  createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
                  type: PostType.values.firstWhere(
                    (type) =>
                        type.toString().split('.').last ==
                        (data['postType'] ?? 'markdown'),
                    orElse: () => PostType.markdown,
                  ),
                  likes: data['likes'] ?? 0,
                  comments: data['comments'] ?? 0,
                  isLiked:
                      (data['likedBy'] as List?)?.contains(
                        _authService.currentUser?.uid,
                      ) ??
                      false,
                  imageUrl: data['imageUrl'],
                );

                posts.add(post);
              } catch (e) {
                // Skip posts with errors
                continue;
              }
            }

            _posts = posts;
            _filteredPosts = List.from(_posts);
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _setError('Failed to load posts: ${error.toString()}');
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // Search functionality
  void toggleSearch() {
    if (searchController.text.isEmpty) {
      _filteredPosts = List.from(_posts);
    } else {
      searchPosts(searchController.text);
    }
    notifyListeners();
  }

  void searchPosts(String query) {
    if (query.isEmpty) {
      _filteredPosts = List.from(_posts);
    } else {
      _filteredPosts = _posts
          .where(
            (post) =>
                post.title.toLowerCase().contains(query.toLowerCase()) ||
                post.content.toLowerCase().contains(query.toLowerCase()) ||
                post.author.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  // Add new post (called when returning from Post Scene)
  void addPost(Post post) {
    // Post will be automatically added by Firebase stream
    // This method kept for compatibility
  }

  // Refresh posts
  Future<void> refreshPosts() async {
    try {
      _clearError();
      // Posts are already updating in real-time via stream
      // Just provide feedback to user
      await Future.delayed(const Duration(milliseconds: 500));
      notifyListeners();
    } catch (e) {
      _setError('Failed to refresh posts: ${e.toString()}');
    }
  }

  // Toggle post like with Firebase
  Future<void> togglePostLike(String postId) async {
    try {
      // Optimistically update UI
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final newLikes = post.isLiked ? post.likes - 1 : post.likes + 1;
        final updatedPost = Post(
          id: post.id,
          title: post.title,
          content: post.content,
          author: post.author,
          userId: post.userId,
          category: post.category,
          createdAt: post.createdAt,
          type: post.type,
          likes: newLikes,
          comments: post.comments,
          isLiked: !post.isLiked,
          imageUrl: post.imageUrl,
        );

        _posts[postIndex] = updatedPost;
        final filteredIndex = _filteredPosts.indexWhere((p) => p.id == postId);
        if (filteredIndex != -1) {
          _filteredPosts[filteredIndex] = updatedPost;
        }
        notifyListeners();
      }

      // Update Firebase
      await _postService.toggleLike(postId);
    } catch (e) {
      _setError('Failed to update like: ${e.toString()}');
    }
  }

  // Add comment with Firebase
  Future<void> addComment(String postId, String comment) async {
    try {
      await _postService.addComment(postId: postId, comment: comment);
      // Comment count will be updated automatically by Firebase stream
    } catch (e) {
      _setError('Failed to add comment: ${e.toString()}');
    }
  }

  // Check if current user can delete a post
  // Admin/Teachers can delete any post, students can only delete their own
  Future<bool> canDeletePost(String postUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    // Check if user is admin or teacher
    final canEdit = await _authService.canEditSchedule();
    if (canEdit) return true; // Admin or teacher can delete any post

    // Students can only delete their own posts
    return currentUser.uid == postUserId;
  }

  // Delete post with Firebase
  Future<void> deletePost(String postId) async {
    try {
      await _postService.deletePost(postId);
      // Post will be automatically removed by Firebase stream
    } catch (e) {
      _setError('Failed to delete post: ${e.toString()}');
      rethrow;
    }
  }

  // Get comments stream for a post
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _postService.getCommentsStream(postId);
  }

  // Check if current user can delete a comment
  Future<bool> canDeleteComment(String commentUserId) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return false;

    // Check if user is admin or teacher
    final canEdit = await _authService.canEditSchedule();
    if (canEdit) return true; // Admin or teacher can delete any comment

    // Students can only delete their own comments
    return currentUser.uid == commentUserId;
  }

  // Delete comment with Firebase
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await _postService.deleteComment(postId: postId, commentId: commentId);
    } catch (e) {
      _setError('Failed to delete comment: ${e.toString()}');
      rethrow;
    }
  }

  // Private helper methods
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
