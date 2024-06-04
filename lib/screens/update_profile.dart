import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sahayagi/widget/covex_bar.dart';

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({Key? key}) : super(key: key);

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
          if (data != null) {
            setState(() {
              _nameController.text = data['name'] ?? '';
              _phoneController.text = data['phone'] ?? '';
              _ageController.text = data['age'] ?? '';
              _skillController.text = data['skill'] ?? '';
              _postOfficeController.text = data['postOffice'] ?? '';
              _subDistrictController.text = data['subDistrict'] ?? '';
              _districtController.text = data['district'] ?? '';
            });
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')));
    }
  }

  Future<void> updateUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image to Firebase Storage if an image is selected
        String? imageUrl;
        if (_image != null) {
          imageUrl = await uploadImageToFirebaseStorage(_image!);
        }

        // Update user profile data in Firestore
        var updateData = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'age': _ageController.text,
          'skill': _skillController.text,
          'postOffice': _postOfficeController.text,
          'subDistrict': _subDistrictController.text,
          'district': _districtController.text,
        };

        // Only add imageUrl if an image was uploaded
        if (imageUrl != null) {
          updateData['imageUrl'] = imageUrl;
        }

        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updateData);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User updated successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user is currently signed in')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to update user: $e')));
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('user_images/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Volunteer User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              _image != null
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: FileImage(_image!),
              )
                  : CircleAvatar(
                radius: 50,
                child: Icon(Icons.person),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: Text('Choose Image'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    child: Text('Take Photo'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  hintText: 'Enter Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _skillController,
                decoration: InputDecoration(
                  hintText: 'Enter Skill',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _postOfficeController,
                decoration: InputDecoration(
                  hintText: 'Enter Post Office',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _subDistrictController,
                decoration: InputDecoration(
                  hintText: 'Enter Sub District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  hintText: 'Enter District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUser,
                child: Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}