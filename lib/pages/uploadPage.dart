// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fyp_two/services/CloudinaryService.dart';
// import 'package:fyp_two/insta/pages/home_page.dart';
//
// class UploadScreen extends StatefulWidget {
//   const UploadScreen({Key? key, required String userId}) : super(key: key);
//
//   @override
//   State<UploadScreen> createState() => _UploadScreenState();
// }
//
// class _UploadScreenState extends State<UploadScreen> {
//   File? _imageFile;
//   bool _isUploading = false;
//   bool _uploadSuccess = false;
//
//   final TextEditingController _captionController = TextEditingController();
//
//   Future<void> _pickImage() async {
//     final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _imageFile = File(pickedFile.path);
//         _uploadSuccess = false;
//       });
//     }
//   }
//
//   Future<void> _uploadImageToFirestore() async {
//     if (_imageFile == null) return;
//
//     setState(() {
//       _isUploading = true;
//     });
//
//     try {
//       // Upload image to Cloudinary
//       final imageUrl = await CloudinaryService.uploadPetImage(_imageFile!);
//
//       // Get current user info
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw Exception("User not logged in");
//
//       // Create post document in Firestore
//       await FirebaseFirestore.instance.collection('posts').add({
//         'imageUrl': imageUrl,
//         'caption': _captionController.text.trim(),
//         'userId': user.uid,
//         'timestamp': FieldValue.serverTimestamp(),
//         'likes': [],
//         'comments': [],
//       });
//
//       setState(() {
//         _uploadSuccess = true;
//         _isUploading = false;
//         _captionController.clear();
//         _imageFile = null;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Image uploaded successfully!')),
//       );
//     } catch (e) {
//       setState(() {
//         _isUploading = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Upload failed: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Upload New Post")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _imageFile != null
//                 ? Image.file(_imageFile!, height: 200)
//                 : const Text("No image selected."),
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: const Text("Pick Image"),
//             ),
//
//             const SizedBox(height: 20),
//
//             TextField(
//               controller: _captionController,
//               decoration: const InputDecoration(
//                 labelText: 'Write a caption...',
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 2,
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               onPressed: _isUploading ? null : _uploadImageToFirestore,
//               child: _isUploading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Text("Upload"),
//             ),
//
//             const SizedBox(height: 20),
//
//             if (_uploadSuccess)
//               Column(
//                 children: [
//                   const Text("Upload successful!", style: TextStyle(color: Colors.green)),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const HomePage()),
//                       );
//                     },
//                     child: const Text("Next"),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// upload_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyp_two/services/CloudinaryService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key, required String userId}) : super(key: key);

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _imageFile;
  bool _isUploading = false;
  final TextEditingController _captionController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPost() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    try {
      setState(() => _isUploading = true);

      // 1. Upload to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(_imageFile!);

      // 2. Save to Firestore
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'caption': _captionController.text.trim(),
        'userId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'comments': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully!')),
      );

      // Clear form
      _captionController.clear();
      setState(() => _imageFile = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _imageFile != null
                ? Image.file(_imageFile!, height: 200)
                : Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: Text("No image selected")),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Select Image"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadPost,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload Post"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }
}
