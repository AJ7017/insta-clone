import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp_two/insta/theme/colors.dart';

class StoryWidget extends StatelessWidget {
  final String userId;
  final String petName;
  final String profileImage;

  const StoryWidget({
    super.key,
    required this.userId,
    required this.petName,
    required this.profileImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primary,secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: white,
              child: CircleAvatar(
                radius: 30,
                backgroundImage: profileImage.isNotEmpty
                    ? CachedNetworkImageProvider(profileImage)
                    : const AssetImage('assets/default_pet.png') as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            petName,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}