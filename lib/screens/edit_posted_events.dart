import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sahayagi/widget/common_widget.dart';
import '../models/events_model.dart';
import '../models/location_model.dart';
import '../models/user_models.dart';

class EditPostedEvent extends StatefulWidget {
  final String documentId;

  const EditPostedEvent({required this.documentId, Key? key}) : super(key: key);

  @override
  State<EditPostedEvent> createState() => _EditPostedEventState();
}

class _EditPostedEventState extends State<EditPostedEvent> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requiredDayController = TextEditingController();
  final TextEditingController _locationDetailController = TextEditingController();
  List<String> _selectedSkills = [];
  String? _selectedType;
  String? _selectedSubDistrict;
  String? _selectedDistrict;
  DateTime? _eventDate;
  DateTime? _lastApplicationDate;
  bool _isLoading = false;



  @override
  void initState() {
    super.initState();
    _loadEventData();
  }

  Future<void> _loadEventData() async {
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
            _requiredDayController.text = data['required_day'] ?? '';
            _locationDetailController.text = data['location_details'] ?? '';
            _selectedSkills = List<String>.from(data['skills'] ?? []);
            _selectedType = data['event_type'];
            _selectedSubDistrict = data['sub_district'];
            _selectedDistrict = data['district'];
            _eventDate = (data['event_date'] as Timestamp).toDate();
            _lastApplicationDate = (data['last_application_date'] as Timestamp).toDate();
          });
        }
      } else {
        print('No event found for the given document ID.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load event data: $e')));
    }
  }

  Future<void> updateEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('events').doc(widget.documentId).update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'required_day': _requiredDayController.text,
        'location_details': _locationDetailController.text,
        'skills': _selectedSkills,
        'event_type': _selectedType,
        'sub_district': _selectedSubDistrict,
        'district': _selectedDistrict,
        'event_date': _eventDate,
        'last_application_date': _lastApplicationDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Event updated successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update event: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
        title: Text('Edit Event', style: appFontStyle(25, texColorLight)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Enter title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
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
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _requiredDayController,
                  decoration: InputDecoration(
                    hintText: 'Enter Required Days',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the required days';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
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
                      return 'Please enter location details';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                MultiSelectDialogField<String>(
                  items: skills.map((skill) => MultiSelectItem<String>(skill, skill)).toList(),
                  title: Text("Skills"),
                  searchable: true,
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
                  items: eventType,
                  selectedItem: _selectedType,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Please Select Event Type",
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
                      _selectedType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select an event type';
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
                    if (value == null || value.isEmpty) {
                      return 'Please select a sub-district';
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
                    if (value == null || value.isEmpty) {
                      return 'Please select a district';
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
                  onPressed: updateEvent,
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