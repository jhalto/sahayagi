import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/sign_in.dart';


import '../widget/covex_bar.dart';

class MyHelper {
  Future<void> signUp(String email, String password, String name, String phone,String age,String skill, String bloodGroup,
      String subDistrict, String district,
      BuildContext context) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(
            credential.user!.uid).set({
          'uid': credential.user!.uid,
          'email': email,
          'name': name,
          'phone': phone,
          'age': age,
          'skill': skill,
          'blood_group': bloodGroup,
          'sub_district': subDistrict,
          'district': district,
          'role': 'user',
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


  Future<void> signIn(String email, String password,
      BuildContext context) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid credentials')));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found')));
      } else if (e.code == 'wrong-password') {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong password')));
      }
    }
  }

  Future<String?> getUserName(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('name') as String?;
  }

  Future<String?> getUserEmail(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('email') as String?;
  }

  Future<String?> getUserNumber(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('phone') as String?;
  }


  Future<String?> getUserPostOffice(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('postOffice') as String?;
  }

  Future<String?> getUserSubDistrict(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('subDistrict') as String?;
  }

  Future<String?> getUserDistrict(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('district') as String?;
  }

  Future<String?> getUserSkill(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('skill') as String?;
  }

  Future<String?> getUserImageUrl(String uid) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
        'users').doc(uid).get();
    return userDoc.get('imageUrl') as String?;
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
class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> init() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? token = await _firebaseMessaging.getToken();
      print("FCM Token: $token");

      // Save the FCM token to Firestore or use it as needed
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && token != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcm_token': token});
      }
    } else {
      print('User declined or has not accepted permission');
    }
  }
}