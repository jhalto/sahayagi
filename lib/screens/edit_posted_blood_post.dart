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

class EditPostedBloodPost extends StatefulWidget {
  final String documentId;

  const EditPostedBloodPost({required this.documentId, Key? key}) : super(key: key);

  @override
  State<EditPostedBloodPost> createState() => _EditPostedBloodPostState();
}

class _EditPostedBloodPostState extends State<EditPostedBloodPost> {
  final _formKey = GlobalKey<FormState>();
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



  @override
  void initState() {
    super.initState();
    _loadBloodData();
  }

  Future<void> _loadBloodData() async {
    try {
      DocumentSnapshot bloodDoc = await FirebaseFirestore.instance
          .collection('blood_donation')
          .doc(widget.documentId)
          .get();
      if (bloodDoc.exists) {
        Map<String, dynamic>? data = bloodDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          setState(() {
            _hospitalController.text = data['hospital'] ?? '';
            _descriptionController.text = data['description'] ?? '';
            _bloodQuantityController.text = data['blood_quantity'] ?? '';
            _phoneController.text = data['phone'] ?? '';
            _locationDetailController.text = data['location_details'] ?? '';
            _selectedBloodGroup = data['blood_group'];

            _selectedSubDistrict = data['sub_district'];
            _selectedDistrict = data['district'];
            _operationDate = (data['operation_date'] as Timestamp).toDate();
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

  Future<void> updateBloodPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('blood_donation').doc(widget.documentId).update({
        'hospital': _hospitalController.text,
        'description': _descriptionController.text,
        'blood_quantity': _bloodQuantityController.text,
        'phone': _phoneController.text,
        'location_details': _locationDetailController.text,
        'blood_group': _selectedBloodGroup,
        'sub_district': _selectedSubDistrict,
        'district': _selectedDistrict,
        'operation_date': _operationDate,
        'last_application_date': _lastApplicationDate,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Blood Post updated successfully')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update Blood Post: $e')));
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
        title: Text('Edit Blood Post', style: appFontStyle(25, texColorLight)),
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
                  controller: _hospitalController,
                  decoration: InputDecoration(
                    hintText: 'Enter Hospital Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Hospital Name';
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
                  controller: _bloodQuantityController,
                  decoration: InputDecoration(
                    hintText: 'Enter Blood Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter blood Quantity';
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
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
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
                const SizedBox(height: 10),

                DropdownSearch<String>(
                  items: bloodGroups,
                  selectedItem: _selectedBloodGroup,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: "Please Select blood Group",
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
                    if (value == null || value.isEmpty) {
                      return 'Please select a blood group';
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
                            _operationDate = date;
                          });
                        }),
                        child: Text(_operationDate == null
                            ? 'Select Operation Date'
                            : DateFormat.yMd().format(_operationDate!)),
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
                  onPressed: updateBloodPost,
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