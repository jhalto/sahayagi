import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:sahayagi/helpers/notification_helper.dart';  // Make sure to import the NotificationHelper
import 'package:sahayagi/models/events_model.dart';
import 'package:sahayagi/models/location_model.dart';
import 'package:sahayagi/models/user_models.dart';
import 'package:sahayagi/widget/common_widget.dart';

class EventPost extends StatefulWidget {
  const EventPost({Key? key}) : super(key: key);

  @override
  State<EventPost> createState() => _EventPostState();
}

class _EventPostState extends State<EventPost> {
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

  Future<void> addEvent() async {
    if (!_formKey.currentState!.validate()) {
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

      CollectionReference events = FirebaseFirestore.instance.collection('events');
      DocumentReference documentReference = await events.add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'required_day': _requiredDayController.text,
        'location_details': _locationDetailController.text,
        'skills': _selectedSkills,
        'event_type': _selectedType,
        'sub_district': _selectedSubDistrict,
        'district': _selectedDistrict,
        'user_id': user.uid,
        'user_name': userName,
        'event_date': _eventDate,
        'last_application_date': _lastApplicationDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Event added successfully')));

      // Send notification to matching users
      await _sendNotificationToMatchingUsers(documentReference.id);

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

  Future<void> _sendNotificationToMatchingUsers(String eventId) async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('skills', arrayContainsAny: _selectedSkills)
        .get();

    NotificationHelper notificationHelper = NotificationHelper();

    for (var doc in usersSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('device_token')) {
        String? token = data['device_token'];
        if (token != null) {
          await notificationHelper.sendPushNotification(
              token,
              'New Event Suggested!',
              'A new event matching your skills.'
          );

          // Save notification to Firestore
          await FirebaseFirestore.instance.collection('notifications').add({
            'user_id': doc.id,
            'title': 'New Event Suggested!',
            'body': 'A new event matching your skills.',
            'timestamp': FieldValue.serverTimestamp(),
            'event_id': eventId,
          });
        }
      }
    }
  }

  void _clearTextFields() {
    _titleController.clear();
    _descriptionController.clear();
    _requiredDayController.clear();
    _locationDetailController.clear();
    _selectedSkills.clear();
    _selectedType = null;
    _selectedSubDistrict = null;
    _selectedDistrict = null;

    setState(() {
      _selectedType = null;
      _selectedSubDistrict = null;
      _selectedDistrict = null;
      _eventDate = null;
      _lastApplicationDate = null;
    });
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
        title: Text('Event Post', style: appFontStyle(25, texColorLight)),
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
                    hintStyle: TextStyle(color: Colors.white,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
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
                    hintStyle: TextStyle(color: Colors.white,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
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
                    hintStyle: TextStyle(color: Colors.white,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
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
                    hintStyle: TextStyle(color: Colors.white,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
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
                  selectedColor: texColorDark,
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
                      color: Colors.white,
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
                      hintStyle: TextStyle(color: Colors.white,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    baseStyle: TextStyle(color: Colors.white),
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
                      hintStyle: TextStyle(color: Colors.white,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    baseStyle: TextStyle(color: Colors.white),
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
                      hintStyle: TextStyle(color: Colors.white,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    baseStyle: TextStyle(color: Colors.white), // Set the selected text color to white
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
                      style: TextStyle(color: Colors.white),
                    );
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
                            : DateFormat.yMd().format(_eventDate!),style: TextStyle(color: Colors.white,),),
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
                            : DateFormat.yMd().format(_lastApplicationDate!),style: TextStyle(color: Colors.white,),),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      addEvent();
                    }
                  },
                  child: const Text('Submit',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}