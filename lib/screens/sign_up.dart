import 'package:flutter/material.dart';
import 'package:sahayagi/helpers/helper.dart';
import 'package:sahayagi/screens/sign_in.dart';
import 'package:sahayagi/widget/common_widget.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _postOfficeController = TextEditingController();
  final TextEditingController _subDistrictController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(centerTitle: true, backgroundColor: appColorLight, title: const Text("Sahayagi")),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                    hintText: "Please Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: "Please Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                    hintText: "Please Enter Name",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _numberController,
                decoration: InputDecoration(
                    hintText: "Please give number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _postOfficeController,
                decoration: InputDecoration(
                    hintText: "Please give postOffice",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _subDistrictController,
                decoration: InputDecoration(
                    hintText: "Please give SubDistrict",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _districtController,
                decoration: InputDecoration(
                    hintText: "Please give District",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  var email = _emailController.text;
                  var password = _passwordController.text;
                  var name = _nameController.text;
                  var number = _numberController.text;
                  var postOffice = _postOfficeController.text;
                  var subDistrict = _subDistrictController.text;
                  var district = _districtController.text;
                  MyHelper().signUp(email, password, name, number, postOffice,subDistrict, district, context);
                },
                child: const Text("Sign Up"),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
                },
                child: const Text("Already have an account?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}