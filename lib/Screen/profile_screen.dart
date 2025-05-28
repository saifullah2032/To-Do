import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart'; // Add image_picker to your pubspec.yaml
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color creamBackground = const Color(0xFFFFF9F0);
  final Color goldColor = const Color(0xFFD4AF37);
  final Color lightGreen = const Color(0xFF7BC47F);
  final Color lightGold = const Color(0xFFF5E1A4);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  User? user;
  File? _profileImageFile;
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;

    // Load additional user info from Firestore
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          final data = doc.data()!;
          nameController.text = data['name'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          profileImageUrl = data['profileImageUrl'];
          setState(() {});
        }
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
        profileImageUrl = null; // new image picked locally
      });
      // Here, you’d upload the image to Firebase Storage and get the URL
      // For demo, skip upload
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() != true) return;
    if (user == null) return;

    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim()) ?? 0;

    try {
      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': name,
        'age': age,
        'profileImageUrl': profileImageUrl, // Would be your uploaded URL
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  Widget _buildProfileImage() {
    final double size = 120;
    if (_profileImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.file(_profileImageFile!, width: size, height: size, fit: BoxFit.cover),
      );
    } else if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(profileImageUrl!, width: size, height: size, fit: BoxFit.cover),
      );
    } else {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: goldColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: 70, color: goldColor),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        backgroundColor: creamBackground,
        body: Center(
          child: Text('No user logged in.', style: TextStyle(color: goldColor, fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: creamBackground,
      appBar: AppBar(
        backgroundColor: creamBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: goldColor),
        title: Text('Profile', style: TextStyle(color: goldColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    _buildProfileImage(),
                    Container(
                      decoration: BoxDecoration(
                        color: goldColor,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.edit, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: goldColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: goldColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: lightGreen),
                  ),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Please enter your name' : null,
                style: TextStyle(color: goldColor),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: ageController,
                decoration: InputDecoration(
                  labelText: 'Age',
                  labelStyle: TextStyle(color: goldColor),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: goldColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: lightGreen),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter your age';
                  if (int.tryParse(value.trim()) == null) return 'Age must be a number';
                  return null;
                },
                style: TextStyle(color: goldColor),
              ),
              const SizedBox(height: 24),
              // Display UID & Email read-only
              TextFormField(
                initialValue: user!.uid,
                decoration: InputDecoration(
                    labelText: 'User ID',
                    labelStyle: TextStyle(color: goldColor),
                    enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: goldColor),
                          ),
                  focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: lightGreen),
                ),
            ),
          readOnly: true,
            style: TextStyle(color: goldColor),
          ),
                  const SizedBox(height: 16),
                TextFormField(
                  initialValue: user!.email ?? 'No email',
                  decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: goldColor),
                  enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: goldColor),
                ),
              focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: lightGreen),
              ),
                  ),
                readOnly: true,
                style: TextStyle(color: goldColor),
                ),

              const SizedBox(height: 36),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: lightGold, 
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 48),
                    foregroundColor: goldColor, // hex for a green shade
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: _saveProfile,
                child: const Text('Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
