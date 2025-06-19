import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp_two/insta/theme/colors.dart';

class ProfileTab extends StatelessWidget {
  final String userId;
  final String collection;

  const ProfileTab({
    super.key,
    required this.userId,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection(collection)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, userPostsSnapshot) {
        if (!userPostsSnapshot.hasData) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final postIds = userPostsSnapshot.data!.docs
            .map((doc) => doc['postId'] as String)
            .toList();

        if (postIds.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No posts yet')),
          );
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .where(FieldPath.documentId, whereIn: postIds)
              .snapshots(),
          builder: (context, postsSnapshot) {
            if (!postsSnapshot.hasData) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final post = postsSnapshot.data!.docs[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to post detail
                    },
                    child: CachedNetworkImage(
                      imageUrl: post['imageUrl'],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey[200]),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
                  );
                },
                childCount: postsSnapshot.data!.docs.length,
              ),
            );
          },
        );
      },
    );
  }
}