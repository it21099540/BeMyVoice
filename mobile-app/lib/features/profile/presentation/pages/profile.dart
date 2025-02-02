import 'dart:io';

import 'package:bemyvoice/features/auth/presentation/pages/login_page.dart';
import 'package:bemyvoice/features/profile/presentation/widgets/avatar_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show ImagePicker, ImageSource;
import 'package:bemyvoice/core/common/entities/user.dart' as currentUser;
import 'package:bemyvoice/core/common/widgets/custom_button.dart';
import 'package:bemyvoice/features/profile/presentation/widgets/profile_card.dart';
import 'package:bemyvoice/core/common/widgets/custom_app_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class ProfileScreen extends StatefulWidget {
  final currentUser.User user;

  const ProfileScreen({super.key, required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _picker = ImagePicker();

  Future<void> _updateProfile(String field, String value) async {
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(widget.user.id);

    await userRef.update({
      field: value,
    });
  }

  Future<void> _updateImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    // Upload image to Firebase Storage
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('profile_images/${widget.user.id}');
    final uploadTask = storageRef.putFile(File(pickedFile.path));

    final snapshot = await uploadTask.whenComplete(() => null);
    final imageUrl = await snapshot.ref.getDownloadURL();

    // Update Firestore with the image URL
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.id)
        .update({
      'profileImage': imageUrl,
    });

    setState(() {
      widget.user.profileImage = imageUrl;
    });
  }

  void _showEditDialog(String field, String initialValue) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $field'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateProfile(field, controller.text);
                setState(() {
                  switch (field) {
                    case 'name':
                      widget.user.displayName = controller.text;
                      break;
                    case 'age':
                      widget.user.age = int.tryParse(controller.text);
                      break;
                    case 'gender':
                      widget.user.gender = controller.text;
                      break;
                    case 'address':
                      widget.user.address = controller.text;
                      break;
                  }
                });
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the LoginPage and clear all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profile',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            ProfileImageWidget(
              imageUrl: widget.user.profileImage ?? '',
              onTap: _updateImage,
            ),
            const SizedBox(height: 20),
            ProfileCardWidget(
              title: 'Name : ',
              value: widget.user.displayName.isNotEmpty
                  ? widget.user.displayName
                  : 'Enter your name',
              icon: Icons.person,
              onTap: () => _showEditDialog('name', widget.user.displayName),
            ),
            const SizedBox(height: 20),
            ProfileCardWidget(
              title: 'Email : ',
              value: widget.user.email,
              icon: Icons.email,
            ),
            const SizedBox(height: 20),
            ProfileCardWidget(
              title: 'Age : ',
              value: widget.user.age != null
                  ? widget.user.age.toString()
                  : 'Enter your age',
              icon: Icons.cake,
              onTap: () =>
                  _showEditDialog('age', widget.user.age?.toString() ?? ''),
            ),
            const SizedBox(height: 20),
            ProfileCardWidget(
              title: 'Gender : ',
              value: widget.user.gender?.isNotEmpty == true
                  ? widget.user.gender!
                  : 'Enter your gender',
              icon: Icons.transgender,
              onTap: () => _showEditDialog('gender', widget.user.gender ?? ''),
            ),
            const SizedBox(height: 20),
            ProfileCardWidget(
              title: 'Address : ',
              value: widget.user.address?.isNotEmpty == true
                  ? widget.user.address!
                  : 'Enter your address',
              icon: Icons.home,
              onTap: () =>
                  _showEditDialog('address', widget.user.address ?? ''),
            ),
            const SizedBox(height: 20),
            CustomButton(
              icon: Icons.logout,
              buttonText: 'Sign Out',
              onPressed: _signOut,
            ),
          ],
        ),
      ),
    );
  }
}
