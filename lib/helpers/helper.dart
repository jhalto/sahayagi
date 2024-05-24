import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:sahayagi/screens/home_page.dart';
import 'package:sahayagi/screens/message.dart';
import 'package:sahayagi/screens/sign_in.dart';
import 'package:sahayagi/screens/sign_up.dart';
import 'package:sahayagi/widget/covex_bar.dart';

// class SignUpHelper extends GetxController{
//   static SignUpHelper get instance => Get.find();
//   final email= TextEditingController();
//   final password= TextEditingController();
//   final fullName = TextEditingController();
//



class MyHelper {
  // static MyHelper get instance => Get.find();
  Future signUp(email,password,context) async{
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      if(credential.user!.uid.isNotEmpty){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn(),));

      }
      else{
        print("not valid");
      }
    } on FirebaseAuthException catch (e){
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
  }
  Future signIn(email,password,context) async{
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      if(credential.user!.uid.isNotEmpty){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => ConvexBarDemo(),), (route) => route.isCurrent);
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Not valid')));
      }
    } on FirebaseAuthException catch (e){
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user found')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('wrong password')));
      }
    }
}
  Future logOut() async => await FirebaseAuth.instance.signOut();
}