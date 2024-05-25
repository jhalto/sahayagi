import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance.collection('users').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
        backgroundColor: appColorLight, // Change the AppBar color if desired
      ),
      backgroundColor:  texColorLight,// Set the background color of the Scaffold
      body: StreamBuilder<QuerySnapshot>(
        stream: _userStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView(
            padding: EdgeInsets.all(8.0),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                     title: Text(data['name'] ?? 'No Name',
                        style: appFontStyle(18),),
                       subtitle: Row(
                         children: [
                           Text(data['skill']?? 'Empty',style: appFontStyle(15),),
                           Text(","),
                           SizedBox(width: 5,),
                           Text(data['post_office']?? 'Empty',style: appFontStyle(15),),
                           Text(","),
                           SizedBox(width: 5,),
                           Text(data['sub_district']?? 'Empty',style: appFontStyle(15),),
                           Text(","),
                           SizedBox(width: 5,),
                           Text(data['district']?? 'Empty',style: appFontStyle(15),),

                         ],
                       ),
                        trailing: IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.add
                          ),

                        ),
                      ) // Add more user data here if needed
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}