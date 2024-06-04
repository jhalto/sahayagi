import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sahayagi/helpers/helper.dart';
import 'package:sahayagi/screens/forgot_password.dart';
import 'package:sahayagi/screens/home_page.dart';
import 'package:sahayagi/screens/sign_up.dart';
import 'package:sahayagi/widget/covex_bar.dart';

import '../widget/common_widget.dart';


class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isObscure = true;


  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: texColorLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sahayagi",
                  style: appFontStyle(25, logoColor, FontWeight.bold),
                ),
                const SizedBox(height: 70),
                Text(
                  "Sign in",
                  style: appFontStyle(35, texColorDark, FontWeight.bold),
                ),
                 RichText(
                  text: TextSpan(
                    text: 'or ',
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Join Sahayagi',
                        style: const TextStyle(color: logoColor, fontSize: 20),
                      
                      ),
                    ],
                  ),
                ),
                MaterialButton(onPressed: (){}, child: Row(
                  children: [
                    Container(
                      height: 30,
                      width: 30,
                      child: Image.asset("lib/images/google.png"),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50)
                      ),
                    ),
                    SizedBox(width: 5,),
                    Text("by google account",style: appFontStyle(20),)
                    
                  ],
                ),),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text("or"),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Email or Phone",
                  style: appFontStyle(20),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                      hintText: "Please Enter Email",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
                const SizedBox(height: 10,),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                      hintText: "Please Enter Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      )
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(onPressed: (){
                      showModalBottomSheet(context: context, builder: (context) => Container(
                        child: Column(
                          children: [
                            GestureDetector(
                                onTap: (){
                                  Navigator.pop(context);
                                 Get.to(()=> ForgotPasswordScreen());
                                },child: Container(
                              height: 50,
                                  child: Row(
                                    children: [
                                  Icon(Icons.email),
                                  Text("Reset via Mail Verification"),
                                    ],
                                  ),
                                ),
                            ),
                            GestureDetector(
                              onTap: (){

                              },child: Row(
                              children: [
                                Icon(Icons.mobile_friendly),
                                Text("Reset via Phone Verification"),
                              ],
                            ),
                            ),
                          ],
                        ),
                      ),);
                    }, child: Text("Forgot Password"))),
                ElevatedButton(onPressed: (){
                  var e= _emailController.text;
                  var p=_passwordController.text;
                  var obj = MyHelper().signIn(e, p, context);

                }, child: const Text("Sign In"),),
                const SizedBox(height: 10,),
                TextButton(onPressed: (){
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>const SignUp( )));
                }, child: const Text("Don't have an account?"),)
              ],
            ),
          ),
        ),
      ),
    );
  }
}