import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';

class AllUsers extends StatefulWidget {
  const AllUsers({Key? key}) : super(key: key);

  @override
  State<AllUsers> createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  late Future<List<DocumentSnapshot>> _nonAdminUsers;

  @override
  void initState() {
    super.initState();
    _nonAdminUsers = _fetchNonAdminUsers();
  }

  Future<List<DocumentSnapshot>> _fetchNonAdminUsers() async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'user')
        .get();
    return usersSnapshot.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend', style: appFontStyle(25)),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: _nonAdminUsers,
        builder: (BuildContext context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(8.0),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = snapshot.data![index];
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(data['name'] ?? 'No Name', style: appFontStyle(18)),
                        subtitle: Row(
                          children: [
                            Text(data['skill'] ?? 'Empty', style: appFontStyle(15)),
                            Text(", "),
                            Text(data['postOffice'] ?? 'Empty', style: appFontStyle(15)),
                            Text(", "),
                            Text(data['subDistrict'] ?? 'Empty', style: appFontStyle(15)),
                            Text(", "),
                            Text(data['district'] ?? 'Empty', style: appFontStyle(15)),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}