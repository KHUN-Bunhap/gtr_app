import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Post Service
/// Handles post data storage and retrieval in Firestore
class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Create a new post
  Future<String> createPost({
    required String title,
    required String content,
    List<String>? tags,
    String? category,
    String? postType,
    File? imageFile,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw 'User not authenticated';

      String? imageUrl;

      // Upload image if provided
      if (imageFile != null) {
        imageUrl = await _uploadPostImage(userId, imageFile);
      }

      final postRef = await _firestore.collection('posts').add({
        'userId': userId,
        'title': title,
        'content': content,
        'tags': tags ?? [],
        'category': category,
        'postType': postType ?? 'markdown',
        'imageUrl': imageUrl,
        'likes': 0,
        'likedBy': [],
        'comments': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return postRef.id;
    } catch (e) {
      throw 'Failed to create post: ${e.toString()}';
    }
  }

  // Upload post image to Firebase Storage
  Future<String> _uploadPostImage(String userId, File imageFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${userId}_$timestamp.jpg';
      final storageRef = _storage.ref().child('posts/$userId/$fileName');

      await storageRef.putFile(imageFile);
      final downloadUrl = await storageRef.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: ${e.toString()}';
    }
  }

  // Get posts stream (all posts, ordered by creation date)
  Stream<QuerySnapshot> getPostsStream({int limit = 50}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Get user's posts stream
  Stream<QuerySnapshot> getUserPostsStream(String userId, {int limit = 50}) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // Get single post
  Future<DocumentSnapshot> getPost(String postId) async {
    try {
      return await _firestore.collection('posts').doc(postId).get();
    } catch (e) {
      throw 'Failed to load post';
    }
  }

  // Update post
  Future<void> updatePost({
    required String postId,
    String? title,
    String? content,
    List<String>? tags,
    String? category,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (content != null) updateData['content'] = content;
      if (tags != null) updateData['tags'] = tags;
      if (category != null) updateData['category'] = category;

      await _firestore.collection('posts').doc(postId).update(updateData);
    } catch (e) {
      throw 'Failed to update post';
    }
  }

  // Delete post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw 'Failed to delete post';
    }
  }

  // Like/Unlike post
  Future<void> toggleLike(String postId) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw 'User not authenticated';

      final postRef = _firestore.collection('posts').doc(postId);

      await _firestore.runTransaction((transaction) async {
        final post = await transaction.get(postRef);

        if (!post.exists) throw 'Post not found';

        final likedBy = List<String>.from(post.data()?['likedBy'] ?? []);
        final likes = post.data()?['likes'] ?? 0;

        if (likedBy.contains(userId)) {
          // Unlike
          likedBy.remove(userId);
          transaction.update(postRef, {'likedBy': likedBy, 'likes': likes - 1});
        } else {
          // Like
          likedBy.add(userId);
          transaction.update(postRef, {'likedBy': likedBy, 'likes': likes + 1});
        }
      });
    } catch (e) {
      throw 'Failed to toggle like';
    }
  }

  // Add comment to post
  Future<void> addComment({
    required String postId,
    required String comment,
  }) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw 'User not authenticated';

      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .add({
            'userId': userId,
            'comment': comment,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Increment comment count
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(1),
      });
    } catch (e) {
      throw 'Failed to add comment';
    }
  }

  // Get comments stream
  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Delete comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _firestore
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      // Decrement comment count
      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.increment(-1),
      });
    } catch (e) {
      throw 'Failed to delete comment';
    }
  }
}
