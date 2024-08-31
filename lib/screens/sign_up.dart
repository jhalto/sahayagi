import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:sahayagi/helpers/helper.dart';
import 'package:sahayagi/models/location_model.dart';
import 'package:sahayagi/screens/sign_in.dart';
import 'package:sahayagi/widget/common_widget.dart';

import '../models/user_models.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? _selectedBloodGroup;
  String? _selectedSubDistrict;
  String? _selectedDistrict;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: texColorLight,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(centerTitle: true, title: const Text("Sahayagi")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Please Enter Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Please Enter Password",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Please Enter Name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Please Enter Phone Number",
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
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Please Enter Age",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter age';
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
                            if (value == null) {
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
                            if (value == null) {
                              return 'Please select a district';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      var email = _emailController.text;
                      var password = _passwordController.text;
                      var name = _nameController.text;
                      var phone = _phoneController.text;
                      var age = _ageController.text;
                      var bloodGroup = _selectedBloodGroup!;
                      var subDistrict = _selectedSubDistrict!;
                      var district = _selectedDistrict!;

                      MyHelper().signUp(email, password, name, phone, age, bloodGroup, subDistrict, district, context);
                    }
                  },
                  child: const Text("Sign Up"),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignIn()));
                  },
                  child: const Text("Already have an account?"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}