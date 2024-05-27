// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:sahayagi/helpers/helper.dart';
//
// class UpdateProfileScreen extends StatefulWidget {
//   @override
//   _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
// }
//
// class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _imageController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentUser();
//   }
//
//   void _loadCurrentUser() {
//     User? user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       _nameController.text = user.displayName ?? '';
//       _imageController.text = user.photoURL ?? '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Name',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             TextFormField(
//               controller: _imageController,
//               decoration: InputDecoration(
//                 labelText: 'Image URL',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 String name = _nameController.text;
//                 String imageUrl = _imageController.text;
//
//                 MyHelper().updateUserProfile(name, imageUrl, context);
//               },
//               child: Text('Update Profile'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }