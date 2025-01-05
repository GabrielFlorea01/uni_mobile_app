import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _profilePictureUrl;
  String? _userName;
  String? _userEmail;
  String? _createdAt;

  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      setState(() {
        _profilePictureUrl = userData?['profilePic'] ?? '';
        _userName = userData?['name'];
        _userEmail = user.email;
        _createdAt = _formatDate(userData?['createdAt']);
        _nameController.text = _userName ?? '';
      });
    }
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "Unknown";
    DateTime date = timestamp.toDate();
    return DateFormat('dd-MM-yyyy').format(date);
  }

  Future<void> _uploadProfilePicture() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File file = File(pickedFile.path);
        User? user = _auth.currentUser;
        if (user != null) {
          final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
          await ref.putFile(file);
          final url = await ref.getDownloadURL();
          await _firestore.collection('users').doc(user.uid).update({
            'profilePic': url,
          });

          setState(() {
            _profilePictureUrl = url;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile picture updated!")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile picture: $e")),
      );
    }
  }

  Future<void> _deleteProfilePicture() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final ref = _storage.ref().child('profile_pictures/${user.uid}.jpg');
        await ref.delete();

        await _firestore.collection('users').doc(user.uid).update({
          'profilePic': '',
        });

        setState(() {
          _profilePictureUrl = '';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile picture deleted!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting profile picture: $e")),
      );
    }
  }

  Future<void> _updateUserName() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': _nameController.text,
        });

        setState(() {
          _userName = _nameController.text;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Name updated!")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating name: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: constraints.maxWidth > 600 ? 500 : double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _profilePictureUrl != null && _profilePictureUrl!.isNotEmpty
                                  ? NetworkImage(_profilePictureUrl!)
                                  : AssetImage('assets/placeholder.png') as ImageProvider,
                              backgroundColor: Colors.grey[200],
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: IconButton(
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  onPressed: _uploadProfilePicture,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                      if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty)
                        ElevatedButton(
                          onPressed: _deleteProfilePicture,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: Text("Remove Profile Picture"),
                        ),
                      SizedBox(height: 20),
                      Text(
                        _userName ?? "Loading...",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 15),
                      Text(
                        _userEmail ?? "Loading...",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Account Created On: ${_createdAt ?? "Unknown"}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 80),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Update Name",
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _updateUserName,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          textStyle: TextStyle(fontSize: 16),
                        ),
                        child: Text("Update Name"),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}