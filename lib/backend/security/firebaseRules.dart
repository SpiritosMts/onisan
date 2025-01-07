import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRulesPanel extends StatefulWidget {
  @override
  _FirestoreRulesPanelState createState() => _FirestoreRulesPanelState();
}

class _FirestoreRulesPanelState extends State<FirestoreRulesPanel> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userId = "testUser123"; // Set your test user ID
  String postId = "testPost123"; // Set your test post ID
  String result = "";

  Future<void> createDocument() async {
    try {
      await firestore.collection('users').doc(userId).set({
        "name": "Test User",
        "email": "test@example.com",
      });
      setState(() {
        result = "Document created successfully!";
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> readDocument() async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        setState(() {
          result = "Document Data: ${doc.data()}";
        });
      } else {
        setState(() {
          result = "Document does not exist.";
        });
      }
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> updateDocument() async {
    try {
      await firestore.collection('users').doc(userId).update({
        "name": "Updated Test User",
      });
      setState(() {
        result = "Document updated successfully!";
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> deleteDocument() async {
    try {
      await firestore.collection('users').doc(userId).delete();
      setState(() {
        result = "Document deleted successfully!";
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  Future<void> updatePostFields() async {
    try {
      await firestore.collection('posts').doc(postId).update({
        "likeCount": FieldValue.increment(1),
        "shareCount": FieldValue.increment(1),
      });
      setState(() {
        result = "Post fields updated successfully!";
      });
    } catch (e) {
      setState(() {
        result = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firestore Rules Test Panel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: createDocument,
              child: Text("Create User Document"),
            ),
            ElevatedButton(
              onPressed: readDocument,
              child: Text("Read User Document"),
            ),
            ElevatedButton(
              onPressed: updateDocument,
              child: Text("Update User Document"),
            ),
            ElevatedButton(
              onPressed: deleteDocument,
              child: Text("Delete User Document"),
            ),
            ElevatedButton(
              onPressed: updatePostFields,
              child: Text("Update Post Fields"),
            ),
            SizedBox(height: 20),
            Text(
              result,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
