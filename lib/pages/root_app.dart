import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_two/insta/pages/chat_page.dart';
import 'package:fyp_two/insta/pages/home_page.dart';
import 'package:fyp_two/insta/pages/profile_page.dart';
import 'package:fyp_two/insta/pages/saved_page.dart';
import 'package:fyp_two/insta/pages/uploadPage.dart';
import 'package:fyp_two/insta/theme/colors.dart';

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int activeTab = 0;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: getFooter(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: getFloatingButton(),
      body: getBody(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: activeTab,
      children: [
        const HomePage(),
        const ChatPage(),
        UploadScreen(userId: user?.uid ?? 'default_user_id'), // Provide default value
        const SavedPage(),
        ProfilePage(userId: user?.uid ?? 'default_user_id'), // Provide default value
      ],
    );
  }

  Widget getFooter() {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 20,
            offset: const Offset(0, 1),
          )
        ],
        borderRadius: BorderRadius.circular(20),
        color: white,
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 30, right: 30, top: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => activeTab = 0),
                  child: Icon(
                    Icons.home,
                    size: 25,
                    color: activeTab == 0 ? primary : black,
                  ),
                ),
                const SizedBox(width: 55),
                GestureDetector(
                  onTap: () => setState(() => activeTab = 1),
                  child: Icon(
                    Icons.chat_bubble_outline,
                    size: 25,
                    color: activeTab == 1 ? primary : black,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => activeTab = 3),
                  child: Icon(
                    Icons.favorite_border,
                    size: 25,
                    color: activeTab == 3 ? primary : black,
                  ),
                ),
                const SizedBox(width: 55),
                GestureDetector(
                  onTap: () {
                    if (user != null) {
                      setState(() => activeTab = 4);
                    } else {
                      // Show login dialog or navigate to login page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please login to view profile'),
                        ),
                      );
                    }
                  },
                  child: Icon(
                    Icons.account_circle,
                    size: 28,
                    color: activeTab == 4 ? primary : black,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget getFloatingButton() {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          setState(() => activeTab = 2);
        } else {
          // Show login dialog or navigate to login page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please login to upload content'),
            ),
          );
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 15,
              offset: const Offset(0, 1),
            ),
          ],
          color: black,
          borderRadius: BorderRadius.circular(23),
        ),
        child: Center(
          child: Icon(
            Icons.add_circle_outline,
            color: white,
            size: 26,
          ),
        ),
      ),
    );
  }
}