import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
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
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Navigate to sign-up page
                        },
                    ),
                  ],
                ),
              ),
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Email can't be null";
                          }
                          if (value.length < 10) {
                            return "Invalid email";
                          }
                          if (!value.contains('@')) {
                            return "Not valid";
                          }
                          return null;
                        },
                        cursorColor: Colors.blue,
                        controller: _emailController,
                        decoration: InputDecoration(
                          fillColor: Colors.blue.withOpacity(.1),
                          filled: true,
                          focusColor: Colors.blue,
                          prefixIcon: const Icon(Icons.email, color: Colors.blue),
                          hintText: "Enter your email",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Password can't be null";
                          }
                          if (value.length < 8) {
                            return "Password can't be less than 8 characters";
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'Uppercase letter is missing';
                          }
                          if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'Lowercase letter is missing';
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'Digit is missing';
                          }
                          if (!value.contains(RegExp(r'[_!@#%^&*(),.?":{}|<>]'))) {
                            return 'Special character is missing';
                          }
                          return null;
                        },
                        obscureText: isObscure,
                        cursorColor: Colors.blue,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.lightBlueAccent.withOpacity(.1),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isObscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                          ),
                          focusColor: Colors.blue,
                          prefixIcon: const Icon(Icons.lock, color: Colors.blue),
                          hintText: "Enter your password",
                          hintStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.black54,
                          ),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          // Navigate to forget password page
                        },
                        child: const Text("Forget Password?"),
                      ),
                    ),
                    const SizedBox(height: 20),
                    MaterialButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          print("successful");
                        }
                      },
                      minWidth: 200,
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text("Sign in"),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: RichText(
                        text: TextSpan(
                          text: "If you don't have an account ",
                          style: const TextStyle(color: Colors.black54, fontSize: 12),
                          children: [
                            TextSpan(
                              text: "Sign up",
                              style: const TextStyle(color: Colors.blue, fontSize: 15),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Navigate to sign-up page
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}