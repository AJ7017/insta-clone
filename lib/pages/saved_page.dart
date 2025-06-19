import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp_two/insta/theme/colors.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List<String> savedPetImages = [];

  @override
  void initState() {
    super.initState();
    fetchSavedPetImages();
  }

  Future<void> fetchSavedPetImages() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('saved_pets')
            .where('ownerId', isEqualTo: uid)
            .get();

        final images =
            snapshot.docs.map((doc) => doc['petImage'] as String).toList();

        setState(() {
          savedPetImages = images;
        });
      }
    } catch (e) {
      print("Error fetching saved pet images: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: white,
      appBar:
          PreferredSize(preferredSize: Size.fromHeight(0), child: getAppBar()),
      body: getBody(size),
    );
  }

  Widget getAppBar() {
    return AppBar(
      backgroundColor: white,
      elevation: 0,
    );
  }

  Widget getBody(Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 25, right: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text("Saved",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            savedPetImages.isEmpty
                ? Center(child: Text("No saved pets yet."))
                : Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: List.generate(savedPetImages.length, (index) {
                      return Container(
                        width: (size.width - 70) / 2,
                        height: (size.width - 70) / 2,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: Offset(0, 1),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                            image: NetworkImage(savedPetImages[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  )
          ],
        ),
      ),
    );
  }
}
