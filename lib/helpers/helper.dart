import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/sign_in.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../widget/covex_bar.dart';

class MyHelper {
  Future<void> signUp(String email, String password, String name, String phone, String age, String bloodGroup,
      String subDistrict, String district, BuildContext context) async {
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
          'phone': phone,
          'age': age,
          'blood_group': bloodGroup,
          'sub_district': subDistrict,
          'district': district,
          'role': 'user',
        });

        // Send verification email
        await credential.user!.sendEmailVerification();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SignIn(),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent. Please check your email.')),
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

      User user = credential.user!;
      if (user.emailVerified) {
        // Navigate to the home page or the main part of the app
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ConvexBarDemo(), // Replace with your home page
          ),
              (route) => false,
        );
      } else {
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email to log in.')),
        );
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

  Future<UserCredential> signInWithGoogle() async {
    // Sign out from GoogleSignIn to ensure the account selection prompt is shown
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Sign in to Firebase with the Google credential
    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Get the user details
    final User? user = userCredential.user;

    if (user != null) {
      // Reference to the Firestore collection
      final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

      // Check if the user document already exists
      final DocumentSnapshot userDoc = await usersCollection.doc(user.uid).get();

      if (!userDoc.exists) {
        // If the user document doesn't exist, create it with the user's information
        await usersCollection.doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'photoURL': user.photoURL,
          // Add any other fields you want to store
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // If the user document already exists, you might want to update some fields
        await usersCollection.doc(user.uid).update({
          'lastSignInAt': FieldValue.serverTimestamp(),
          // Update any other fields as needed
        });
      }
    }

    // Return the UserCredential
    return userCredential;
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
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      String currentUserId = currentUser.uid;

      // Clear the device_token field
      await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
        'device_token': FieldValue.delete(),
      });

      // Sign out the user
      await FirebaseAuth.instance.signOut();

      // Navigate to the sign-in page and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SignIn(),
        ),
            (route) => false,
      );
    }
  }
}
