import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widget/covex_bar.dart';

class EditPostedEvent extends StatefulWidget {
  final String documentId; // Ensure documentId is passed

  const EditPostedEvent({required this.documentId, super.key});

  @override
  State<EditPostedEvent> createState() => _EditPostedEventState();
}

class _EditPostedEventState extends State<EditPostedEvent> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadEventsData();
  }

  // Load existing event data
  Future<void> _loadEventsData() async {
    try {
      DocumentSnapshot eventDoc = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.documentId)
          .get();
      if (eventDoc.exists) {
        Map<String, dynamic>? data = eventDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _titleController.text = data['title'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            _eventTypeController.text = data['event_type'] ?? '';
            _skillController.text = data['skill'] ?? '';
            _postOfficeController.text = data['post_office'] ?? '';
            _subDistrictController.text = data['sub_district'] ?? '';
            _districtController.text = data['district'] ?? '';
          });
        }
      } else {
        print('No event found for the current user.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events data: $e')));
    }
  }

  // Update event details
  Future<void> updateEvent() async {
    try {
      // Upload image to Firebase Storage if an image is selected
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToFirebaseStorage(_image!);
      }

      // Update event data in Firestore
      await FirebaseFirestore.instance.collection('events').doc(widget.documentId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'event_type': _eventTypeController.text,
        'skill': _skillController.text,
        'post_office': _postOfficeController.text,
        'sub_district': _subDistrictController.text,
        'district': _districtController.text,
        'imageUrl': imageUrl, // Add imageUrl to the event data
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event updated successfully')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ConvexBarDemo()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e')));
    }
  }

  // Pick an image from the gallery or camera
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

  // Upload image to Firebase Storage and get the download URL
  Future<String> _uploadImageToFirebaseStorage(File imageFile) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('event_images/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Firebase Storage: $e');
    }
  }

  // Add event function
  Future<void> addEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _eventTypeController.text.isEmpty ||
        _skillController.text.isEmpty ||
        _postOfficeController.text.isEmpty ||
        _subDistrictController.text.isEmpty ||
        _districtController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all the fields')));
      return;
    }

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')));
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      String? userName = userDoc['name'];

      if (userName == null || userName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please set your name in your profile')));
        return;
      }

      CollectionReference events = FirebaseFirestore.instance.collection('events');
      await events.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'event_type': _eventTypeController.text,
        'skill': _skillController.text,
        'post_office': _postOfficeController.text,
        'sub_district': _subDistrictController.text,
        'district': _districtController.text,
        'user_id': user.uid,
        'user_name': userName,
        'timestamp': FieldValue.serverTimestamp(),  // Add timestamp here
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event added successfully')));

      _clearTextFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')));
    }
  }

  // Clear all text fields
  void _clearTextFields() {
    _titleController.clear();
    _descriptionController.clear();
    _eventTypeController.clear();
    _skillController.clear();
    _postOfficeController.clear();
    _subDistrictController.clear();
    _districtController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              _image != null
                  ? Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(image: FileImage(_image!)),
                ),
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
              _buildTextField(_titleController, 'Enter title'),
              SizedBox(height: 10),
              _buildTextField(_eventTypeController, 'Enter Event Type'),
              SizedBox(height: 10),
              _buildTextField(_descriptionController, 'Enter Description'),
              SizedBox(height: 10),
              _buildTextField(_skillController, 'Enter Needed Skill'),
              SizedBox(height: 10),
              _buildTextField(_postOfficeController, 'Enter Event Location Post Office'),
              SizedBox(height: 10),
              _buildTextField(_subDistrictController, 'Enter Event Location Sub District'),
              SizedBox(height: 10),
              _buildTextField(_districtController, 'Enter Event Location District'),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: updateEvent,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text fields
  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}