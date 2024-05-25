import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventPost extends StatefulWidget {
  const EventPost({super.key});

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

  Future<void> addEvent() async {
    try {
      CollectionReference events = FirebaseFirestore.instance.collection('events');
      await events.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'event_type': _eventTypeController.text,
        'skill':_skillController.text,
        'post_office': _postOfficeController.text,
        'sub_district': _subDistrictController.text,
        'district': _districtController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Events added successfully')));

      // Clear the text fields and refresh the UI
      setState(() {
        _titleController.clear();
        _descriptionController.clear();
        _eventTypeController.clear();
        _skillController.clear();
        _postOfficeController.clear();
        _subDistrictController.clear();
        _districtController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add events: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),
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
              TextField(
                controller: _skillController,
                decoration: InputDecoration(
                  hintText: 'Enter Needed Skill',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _postOfficeController,
                decoration: InputDecoration(
                  hintText: 'Enter Event Location Post Office',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _subDistrictController,
                decoration: InputDecoration(
                  hintText: 'Enter Event Location Sub District',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _districtController,
                decoration: InputDecoration(
                  hintText: 'Enter Event Location ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
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
