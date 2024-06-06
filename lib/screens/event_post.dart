import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';  // Add this for date formatting
import 'package:sahayagi/widget/common_widget.dart';

import '../models/location_model.dart';
import '../models/user_models.dart';

class EventPost extends StatefulWidget {
  const EventPost({Key? key}) : super(key: key);

  @override
  State<EventPost> createState() => _EventPostState();
}

class _EventPostState extends State<EventPost> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _eventTypeController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  String? _selectedSkill;

  String? _selectedBloodGroup;
  String? _selectedSubDistrict;
  String? _selectedDistrict;

  DateTime? _eventDate;
  DateTime? _lastApplicationDate;

  File? _image;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> addEvent() async {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _eventTypeController.text.isEmpty ||
        _skillController.text.isEmpty ||
        _postOfficeController.text.isEmpty ||
        _subDistrictController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _eventDate == null ||
        _lastApplicationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all the fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not logged in')));
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      String? userName = userDoc['name'];

      if (userName == null || userName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please set your name in your profile')));
        return;
      }

      // Upload image to Firebase Storage if an image is selected
      String? imageUrl;
      if (_image != null) {
        imageUrl = await _uploadImageToFirebaseStorage(_image!);
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
        'imageUrl': imageUrl, // Add imageUrl to the event data
        'event_date': _eventDate,
        'last_application_date': _lastApplicationDate,
        'timestamp': FieldValue.serverTimestamp(),  // Add timestamp here
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event added successfully')));

      _clearTextFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add event: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
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

  // Clear all text fields
  void _clearTextFields() {
    _titleController.clear();
    _descriptionController.clear();
    _eventTypeController.clear();
    _skillController.clear();
    _postOfficeController.clear();
    _subDistrictController.clear();
    _districtController.clear();
    setState(() {
      _image = null;
      _eventDate = null;
      _lastApplicationDate = null;
    });
  }

  // Select a date
  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Post', style: appFontStyle(25, texColorLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
              _image != null
                  ? Container(
                height: 200,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_image!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20),
                ),
                height: 200,
                width: double.infinity,
                child: Icon(Icons.photo),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.gallery),
                    child: Text('Choose Image'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => _getImage(ImageSource.camera),
                    child: Text('Take Photo'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _eventTypeController,
                decoration: InputDecoration(
                  hintText: 'Enter Event Type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                items: skills,
                selectedItem: _selectedSkill,
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    hintText: "Please Select skill",
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
                    _selectedSkill = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a Skill';
                  }
                  return null;
                },
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, (date) {
                        setState(() {
                          _eventDate = date;
                        });
                      }),
                      child: Text(_eventDate == null
                          ? 'Select Event Date'
                          : DateFormat.yMd().format(_eventDate!)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, (date) {
                        setState(() {
                          _lastApplicationDate = date;
                        });
                      }),
                      child: Text(_lastApplicationDate == null
                          ? 'Select Last Application Date'
                          : DateFormat.yMd().format(_lastApplicationDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: addEvent,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}