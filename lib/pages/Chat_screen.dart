import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final QueryDocumentSnapshot peerUser;
  const ChatScreen({super.key, required this.peerUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(peerUser['name'])),
      body: Center(child: Text("Chat with ${peerUser['name']}")),
    );
  }
}
