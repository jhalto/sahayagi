import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VolunteerUserProfile extends StatefulWidget {
  const VolunteerUserProfile({super.key});

  @override
  State<VolunteerUserProfile> createState() => _VolunteerUserProfileState();
}

class _VolunteerUserProfileState extends State<VolunteerUserProfile> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  Future<void> addUser() async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      await users.add({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'age': _ageController.text,
        'skill':_skillController.text,
        'post_office': _postOfficeController.text,
        'sub_district': _subDistrictController.text,
        'district': _districtController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User added successfully')));

      // Clear the text fields and refresh the UI
      setState(() {
        _nameController.clear();
        _phoneController.clear();
        _ageController.clear();
        _skillController.clear();
        _postOfficeController.clear();
        _subDistrictController.clear();
        _districtController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add user: $e')));
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
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  hintText: 'Enter Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(
                  hintText: 'Enter Age',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _skillController,
                decoration: InputDecoration(
                  hintText: 'Enter Skill',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _postOfficeController,
                decoration: InputDecoration(
                  hintText: 'Enter Post Office',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subDistrictController,
                decoration: InputDecoration(
                  hintText: 'Enter Sub District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  hintText: 'Enter District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: addUser,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
