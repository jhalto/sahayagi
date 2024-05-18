import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/sign_in.dart';

class MyHelper{
  Future signUp(email,password,context) async{
    try {
   final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
   if(credential.user!.uid.isNotEmpty){
     Navigator.push(context, MaterialPageRoute(builder: (context) => const SignIn(),));
   }
   else{
     print("Not Valid");
   }
    } on FirebaseAuthException catch (e){
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
  }
}
}
