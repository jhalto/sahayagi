import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/event_post.dart';

import '../widget/common_widget.dart';

class AllEvents extends StatefulWidget {
  const AllEvents({super.key});

  @override
  State<AllEvents> createState() => _AllEventsState();
}

class _AllEventsState extends State<AllEvents> {
  final Stream<QuerySnapshot> _eventStream = FirebaseFirestore.instance.collection('events').snapshots();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EventPost(),));
          }, icon: Icon(Icons.add_card_outlined))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _eventStream,
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
                      Card(
                        child: Column(
                          children: [
                            Text(data['title']?? 'Empty',style: appFontStyle(15),),

                            Text(data['skill']?? 'Empty',style: appFontStyle(15),),


                            Text(data['post_office']?? 'Empty',style: appFontStyle(15),),


                            Text(data['sub_district']?? 'Empty',style: appFontStyle(15),),

                            Text(data['district']?? 'Empty',style: appFontStyle(15),),

                          ],
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
