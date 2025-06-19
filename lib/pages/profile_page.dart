import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fyp_two/insta/data/database.dart';
import 'package:fyp_two/insta/pages/profile_tab.dart';
import 'package:fyp_two/insta/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseService _database = DatabaseService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  int _currentTab = 0;
  bool _isFollowing = false;
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  int _postCount = 0;
  int _followerCount = 0;
  int _followingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data();
          _postCount = _userData?['postCount'] ?? 0;
          _followerCount = _userData?['followerCount'] ?? 0;
          _followingCount = _userData?['followingCount'] ?? 0;

          if (_currentUser != null) {
            _isFollowing = (_userData?['followers'] as List?)?.contains(_currentUser!.uid) ?? false;
          }
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    if (_currentUser == null || widget.userId == _currentUser!.uid) return;

    setState(() => _isLoading = true);

    try {
      if (_isFollowing) {
        await _database.unfollowUser(_currentUser!.uid, widget.userId);
      } else {
        await _database.followUser(_currentUser!.uid, widget.userId);
      }

      setState(() {
        _isFollowing = !_isFollowing;
        _followerCount = _isFollowing ? _followerCount + 1 : _followerCount - 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _userData?['profileImage'] != null &&
                    _userData!['profileImage'].isNotEmpty
                    ? CachedNetworkImageProvider(_userData!['profileImage'])
                    : const AssetImage('assets/default_pet.png') as ImageProvider,
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(_postCount, 'Posts'),
                    _buildStatColumn(_followerCount, 'Followers'),
                    _buildStatColumn(_followingCount, 'Following'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _userData?['petName'] ?? 'Loading...',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              _userData?['petType'] ?? '',
              style: TextStyle(
                color: grey,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (_currentUser != null && widget.userId != _currentUser!.uid)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? Colors.grey[200] : primary,
                  foregroundColor: _isFollowing ? black : white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(_isFollowing ? 'Following' : 'Follow'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _userData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          title: Text(
            _userData?['petName'] ?? 'Profile',
            style: const TextStyle(color: black),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: black),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            onTap: (index) => setState(() => _currentTab = index),
            indicatorColor: black,
            labelColor: black,
            unselectedLabelColor: grey,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.bookmark_border)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Posts Tab
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildProfileHeader()),
                _currentTab == 0
                    ? ProfileTab(
                  userId: widget.userId,
                  collection: 'userPosts',
                )
                    : ProfileTab(
                  userId: widget.userId,
                  collection: 'savedPosts',
                ),
              ],
            ),
            // Saved Tab
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildProfileHeader()),
                _currentTab == 0
                    ? ProfileTab(
                  userId: widget.userId,
                  collection: 'userPosts',
                )
                    : ProfileTab(
                  userId: widget.userId,
                  collection: 'savedPosts',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}