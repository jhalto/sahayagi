import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:sahayagi/widget/common_widget.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Please give your email to Continue",style: appFontStyle(20),),
              SizedBox(height: 50,),
              Form(
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: "Please Enter Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
              ),
              TextButton(onPressed: (){
                // Get.to(() => OTPScreen());
              }, child: Text("Next"))
            ],
          ),
        ),
      ),
    );
  }
}
