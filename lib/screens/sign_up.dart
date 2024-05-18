
import 'package:flutter/material.dart';

import 'package:sahayagi/screens/sign_in.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'package:sahayagi/widget/helper.dart';
class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController= TextEditingController();
  final TextEditingController _passwordController= TextEditingController();
//  final TextEditingController _numberController= TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(centerTitle: true,backgroundColor: appColorLight,
          title: const Text("Sahayagi",),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                    hintText: "Please Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
              ),
              const SizedBox(height: 10,),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                    hintText: "Please Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                ),
              ),

              // TextField(
              //   controller: _numberController,
              //   decoration: InputDecoration(
              //       hintText: "Please Enter Number",
              //        border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(10),
              //       )
              //   ),
              // ),
              // const SizedBox(height: 50,),
              ElevatedButton(onPressed: (){
                var e= _emailController.text;
                var p=_passwordController.text;
                var obj = MyHelper().signUp(e, p, context);
              }, child: const Text("Sign Up"),),
              const SizedBox(height: 10,),
              TextButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (_)=>const SignIn()));
              }, child: const Text("Already have an account?"),)


            ],
          ),
        ),
      ),
    );
  }
}