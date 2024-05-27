import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/sign_in.dart';
import 'package:sahayagi/widget/covex_bar.dart';

class MyHelper {
  Future<void> signUp(String email, String password, String name, String number,String postOffice,String subDistrict,String district, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'number': number,
          'postOffice': postOffice,
          'subDistrict': subDistrict,
          'district': district,
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignIn(),
          ),
        );
      } else {
        print("Sign-up failed: user credential is null");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    }
  }

  Future<void> signIn(String email, String password, BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ConvexBarDemo(),
          ),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No user found')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wrong password')));
      }
    }
  }

  Future<String?> getUserName(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.get('name') as String?;
  }
  Future<String?> getUserEmail(String uid) async {
    DocumentSnapshot userEmail = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userEmail.get('email') as String?;
  }
  Future<String?> getUserNumber(String uid) async {
    DocumentSnapshot userNumber = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userNumber.get('number') as String?;
  }

  Future<String?> getUserPostOffice(String uid) async {
    DocumentSnapshot userPostOffice = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userPostOffice.get('postOffice') as String?;
  }
  Future<String?> getUserSubDistrict(String uid) async {
    DocumentSnapshot userSubDistrict = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userSubDistrict.get('subDistrict') as String?;
  }
  Future<String?> getUserDistrict(String uid) async {
    DocumentSnapshot userDistrict = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDistrict.get('district') as String?;
  }
  Future<String?> getUserSkill(String uid) async {
    DocumentSnapshot userSkill = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userSkill.get('skill') as String?;
  }
  Future<String?> getUserImageUrl(String uid) async {
    DocumentSnapshot userImageUrl = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userImageUrl.get('imageUrl') as String?;
  }

  Future<void> logOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => SignIn(),
      ),
          (route) => false,
    );
  }

}
