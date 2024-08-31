// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sahayagi/screens/sign_in.dart';
//
// class VerifyEmailScreen extends StatefulWidget {
//   final String email;
//   final String password;
//   final String name;
//   final String phone;
//   final String age;
//   final String bloodGroup;
//   final String subDistrict;
//   final String district;
//
//   VerifyEmailScreen({
//     required this.email,
//     required this.password,
//     required this.name,
//     required this.phone,
//     required this.age,
//     required this.bloodGroup,
//     required this.subDistrict,
//     required this.district,
//   });
//
//   @override
//   _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
// }
//
// class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
//   bool isEmailVerified = false;
//   late User user;
//   late Timer emailCheckTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     user = FirebaseAuth.instance.currentUser!;
//
//     _checkEmailVerification();
//     emailCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) {
//       _checkEmailVerification();
//     });
//   }
//
//   @override
//   void dispose() {
//     emailCheckTimer.cancel();
//     super.dispose();
//   }
//
//   void _checkEmailVerification() async {
//     await user.reload();
//     setState(() {
//       isEmailVerified = user.emailVerified;
//     });
//     if (isEmailVerified) {
//       await _createUserAccount();
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => SignIn()),
//       );
//     }
//   }
//
//   Future<void> _createUserAccount() async {
//     // Create user with email and password
//     final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: widget.email,
//       password: widget.password,
//     );
//
//     // Save user data to Firestore
//     await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
//       'uid': credential.user!.uid,
//       'email': widget.email,
//       'name': widget.name,
//       'phone': widget.phone,
//       'age': widget.age,
//       'blood_group': widget.bloodGroup,
//       'sub_district': widget.subDistrict,
//       'district': widget.district,
//       'role': 'user',
//     });
//
//     // Sign out anonymous user
//     await FirebaseAuth.instance.signOut();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Verify Email"),
//       ),
//       body: Center(
//         child: isEmailVerified
//             ? CircularProgressIndicator()
//             : Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('A verification email has been sent to ${widget.email}.'),
//             Text('Please verify to continue.'),
//             ElevatedButton(
//               onPressed: () async {
//                 await user.reload();
//                 setState(() {
//                   isEmailVerified = user.emailVerified;
//                 });
//                 if (isEmailVerified) {
//                   await _createUserAccount();
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignIn()),
//                   );
//                 }
//               },
//               child: Text('I have verified'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }