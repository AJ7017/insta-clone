import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Like/Unlike post
  static Future<void> likePost(String userId, String postId) async {
    final postRef = _firestore.collection('posts').doc(postId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);

      if (!snapshot.exists) {
        throw Exception("Post does not exist");
      }

      List<String> likes = List<String>.from(snapshot['likes'] ?? []);

      if (likes.contains(userId)) {
        // Unlike the post
        likes.remove(userId);
      } else {
        // Like the post
        likes.add(userId);
      }

      transaction.update(postRef, {'likes': likes});
    });
  }

  // Add comment
  static Future<void> addComment(String userId, String postId, String comment) async {
    final postRef = _firestore.collection('posts').doc(postId);

    await postRef.update({
      'comments': FieldValue.arrayUnion([comment])
    });
  }
}
