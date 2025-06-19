// lib/insta/services/database.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Users Collection
  Future<void> createUserData({
    required String uid,
    required String petName,
    required String petType,
    String? profileImageUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'petName': petName,
      'petType': petType,
      'profileImage': profileImageUrl ?? '',
      'followers': [],
      'following': [],
      'postCount': 0,
      'followerCount': 0,
      'followingCount': 0,
    });
  }

  // Posts Collection
  Future<void> createPost({
    required String userId,
    required String imageUrl,
    String? caption,
  }) async {
    final postRef = await _firestore.collection('posts').add({
      'userId': userId,
      'imageUrl': imageUrl,
      'caption': caption ?? '',
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
      'likeCount': 0,
      'commentCount': 0,
    });

    // Update user's post count
    await _firestore.collection('users').doc(userId).update({
      'postCount': FieldValue.increment(1),
    });

    // Add to user's posts subcollection
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('userPosts')
        .doc(postRef.id)
        .set({
      'postId': postRef.id,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Comments Collection
  Future<void> addComment({
    required String postId,
    required String userId,
    required String text,
  }) async {
    await _firestore.collection('posts').doc(postId).collection('comments').add({
      'userId': userId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update comment count
    await _firestore.collection('posts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  // Follow/Unfollow
  Future<void> followUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Add to current user's following
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'following': FieldValue.arrayUnion([targetUserId]),
      'followingCount': FieldValue.increment(1),
    });

    // Add to target user's followers
    batch.update(_firestore.collection('users').doc(targetUserId), {
      'followers': FieldValue.arrayUnion([currentUserId]),
      'followerCount': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollowUser(String currentUserId, String targetUserId) async {
    final batch = _firestore.batch();

    // Remove from current user's following
    batch.update(_firestore.collection('users').doc(currentUserId), {
      'following': FieldValue.arrayRemove([targetUserId]),
      'followingCount': FieldValue.increment(-1),
    });

    // Remove from target user's followers
    batch.update(_firestore.collection('users').doc(targetUserId), {
      'followers': FieldValue.arrayRemove([currentUserId]),
      'followerCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  // Like/Unlike
  Future<void> likePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayUnion([userId]),
      'likeCount': FieldValue.increment(1),
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.arrayRemove([userId]),
      'likeCount': FieldValue.increment(-1),
    });
  }

  // Save/Unsave Post
  Future<void> savePost(String userId, String postId) async {
    await _firestore.collection('users').doc(userId).collection('savedPosts').doc(postId).set({
      'postId': postId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> unsavePost(String userId, String postId) async {
    await _firestore.collection('users').doc(userId).collection('savedPosts').doc(postId).delete();
  }
}