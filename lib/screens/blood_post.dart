import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../helpers/notification_helper.dart';
import '../models/location_model.dart';
import '../models/user_models.dart';

class BloodPost extends StatefulWidget {
  const BloodPost({Key? key}) : super(key: key);

  @override
  State<BloodPost> createState() => _BloodPostState();
}

class _BloodPostState extends State<BloodPost> {
  final TextEditingController _hospitalController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _bloodQuantityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _locationDetailController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedSubDistrict;
  String? _selectedDistrict;

  DateTime? _operationDate;
  DateTime? _lastApplicationDate;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  File? _selectedImage;

  Future<void> addBloodNeedingInfo() async {
    if (_hospitalController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _bloodQuantityController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _locationDetailController.text.isEmpty ||
        _selectedBloodGroup == null ||
        _selectedSubDistrict == null ||
        _selectedDistrict == null ||
        _operationDate == null ||
        _lastApplicationDate == null ||
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all the fields and select an image')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('User not logged in')));
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        throw Exception('User document does not exist');
      }

      String? userName = userDoc['name'];

      // Upload image to Firebase Storage
      String imageUrl = await uploadImageToStorage(_selectedImage!);

      CollectionReference bloodDonation =
      FirebaseFirestore.instance.collection('blood_donation');
      DocumentReference documentReference = await bloodDonation.add({
        'hospital': _hospitalController.text,
        'description': _descriptionController.text,
        'blood_quantity': _bloodQuantityController.text,
        'phone': _phoneController.text,
        'location_details': _locationDetailController.text,
        'blood_group': _selectedBloodGroup,
        'sub_district': _selectedSubDistrict,
        'district': _selectedDistrict,
        'user_id': user.uid,
        'user_name': userName,
        'operation_date': _operationDate,
        'last_application_date': _lastApplicationDate,
        'image_url': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update document with post_id
      await documentReference.update({'post_id': documentReference.id});

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blood post added successfully')));

      // Send notification to matching users
      await _sendNotificationToMatchingUsers(documentReference.id);

      _clearTextFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add blood post: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> uploadImageToStorage(File image) async {
    // Implement your image upload logic to Firebase Storage here
    // Return the URL of the uploaded image
    return 'https://example.com/uploaded_image.jpg';
  }

  Future<void> _sendNotificationToMatchingUsers(String postId) async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('blood_group', isEqualTo: _selectedBloodGroup)
        .where('district', isEqualTo: _selectedDistrict)
        .get();

    NotificationHelper notificationHelper = NotificationHelper();

    for (var doc in usersSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('device_token')) {
        String? token = data['device_token'];
        if (token != null) {
          await notificationHelper.sendPushNotification(
              token,
              'New Blood Post Suggested!',
              'A new blood donation request matching your blood group and district has been posted.'
          );

          // Save notification to Firestore with post_id
          await FirebaseFirestore.instance.collection('notifications').add({
            'user_id': doc.id,
            'title': 'New Blood Post Suggested!',
            'body': 'A new blood donation request matching your blood group has been posted.',
            'timestamp': FieldValue.serverTimestamp(),
            'post_id': postId,
          });
        }
      }
    }
  }

  // Clear all text fields
  void _clearTextFields() {
    _hospitalController.clear();
    _descriptionController.clear();
    _bloodQuantityController.clear();
    _phoneController.clear();
    _locationDetailController.clear();

    setState(() {
      _operationDate = null;
      _lastApplicationDate = null;
      _selectedBloodGroup = null;
      _selectedSubDistrict = null;
      _selectedDistrict = null;
      _selectedImage = null;
    });
  }

  // Select a date
  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  // Pick an image
  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Pick from Gallery'),
                onTap: () async {
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Take a Picture'),
                onTap: () async {
                  final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = File(pickedFile.path);
                    });
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Post', style: appFontStyle(25, texColorLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                TextFormField(
                  controller: _hospitalController,
                  decoration: InputDecoration(
                    hintText: 'Enter Hospital Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please Enter hospital';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Enter Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _bloodQuantityController,
                  decoration: InputDecoration(
                    hintText: 'Enter Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10,),
                TextFormField(
                  controller: _locationDetailController,
                  decoration: InputDecoration(
                    hintText: 'Enter Location Details',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter location';
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
                  dropdownBuilder: (context, selectedItem) {
                    return Text(
                      selectedItem ?? "Please Select District",
                    );
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
                            _operationDate = date;
                          });
                        }),
                        child: Text(_operationDate == null
                            ? 'Select operation date'
                            : DateFormat.yMd().format(_operationDate!),),
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
                            : DateFormat.yMd()
                            .format(_lastApplicationDate!),),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _selectedImage != null
                    ? Image.file(
                  _selectedImage!,
                  height: 150,
                )
                    : TextButton(
                  onPressed: _pickImage,
                  child: Text('Select Patient Photo'),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: (){
                    if (_formKey.currentState!.validate()){
                      addBloodNeedingInfo();
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}