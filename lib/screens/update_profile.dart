import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../models/location_model.dart';
import '../models/user_models.dart';

class UpdateUserProfile extends StatefulWidget {
  const UpdateUserProfile({Key? key}) : super(key: key);

  @override
  State<UpdateUserProfile> createState() => _UpdateUserProfileState();
}

class _UpdateUserProfileState extends State<UpdateUserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  List<String> _selectedSkills = [];
  String? _selectedBloodGroup;
  String? _selectedSubDistrict;
  String? _selectedDistrict;

  File? _image;
  String? _imageUrl;
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
              _selectedSkills = List<String>.from(data['skills'] ?? []);
              _selectedBloodGroup = data['blood_group'] ?? '';
              _selectedSubDistrict = data['sub_district'] ?? '';
              _selectedDistrict = data['district'] ?? '';
              _imageUrl = data['imageUrl'] ?? '';
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
          'skills': _selectedSkills,
          'blood_group': _selectedBloodGroup,
          'sub_district': _selectedSubDistrict,
          'district': _selectedDistrict,
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
                  : _imageUrl != null && _imageUrl!.isNotEmpty
                  ? CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(_imageUrl!),
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
              MultiSelectDialogField<String>(
                items: skills.map((skill) => MultiSelectItem<String>(skill, skill)).toList(),
                title: Text("Skills"),
                searchable: true,  // Enable search
                selectedColor: Colors.blue,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                buttonIcon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                buttonText: Text(
                  "Select Skills",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                onConfirm: (List<String> selectedValues) {
                  setState(() {
                    _selectedSkills = selectedValues;
                  });
                },
                initialValue: _selectedSkills,
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                items: bloodGroups,
                selectedItem: _selectedBloodGroup,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Please Select Blood Group",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBloodGroup = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a blood Group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                items: subDistricts,
                selectedItem: _selectedSubDistrict,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Please Select Sub-District",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSubDistrict = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a Sub-District';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                items: districts,
                selectedItem: _selectedDistrict,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Please Select District",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  showSearchBox: true,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDistrict = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select District';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
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