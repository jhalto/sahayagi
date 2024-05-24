

import 'package:flutter/material.dart';
import 'package:sahayagi/helpers/helper.dart';
import 'package:sahayagi/screens/profile.dart';
import '../widget/common_widget.dart';
import 'applied_events.dart';
import 'message.dart';
import 'opportunities.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(

      backgroundColor: appColorLight,

      child: ListView(
        children: [
          DrawerHeader(


              decoration: const BoxDecoration(
                  color: appColorLight
              ),
              padding: EdgeInsets.zero,
              child: UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                    color: appColorLight
                ),
                currentAccountPicture: const CircleAvatar(
                  backgroundImage: NetworkImage(

                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTJ9ow8qnnd0mesESrc6VtBODm3bfE5cXhGTj8xPvlOyw&s"),
                ),
                accountEmail: Text("",style: appFontStyle(15),),
                accountName: Text("Md. Zobayer Arman Nadim",style: appFontStyle(17),),
              )),
          InkWell(
            onTap: (){

            },
            child: ListTile(

              title: Row(
                children: [
                  const Icon(Icons.account_circle),
                  const SizedBox(width: 10,),
                  Text("Profile",style: appFontStyle(18,texColorLight),)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Opportunities(),));
            },
            child: ListTile(

              title: Row(
                children: [
                  const Icon(Icons.ac_unit_sharp),
                  const SizedBox(width: 10,),
                  Text("Oportunities",style: appFontStyle(18,texColorLight),)
                ],
              ),
            ),
          ),
          InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AppliedEvents(),));
            },

            child: ListTile(

              title: Row(
                children: [
                  const Icon(Icons.event_available),
                  const SizedBox(width: 10,),
                  Text("Applied Events",style: appFontStyle(18,texColorLight),)
                ],
              ),
            ),
          ),
          InkWell(
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Messages(),));
            },
            child: ListTile(

              title: Row(
                children: [
                  const Icon(Icons.message),
                  const SizedBox(width: 10,),
                  Text("Message",style: appFontStyle(18,texColorLight),)
                ],
              ),
            ),
          ),
          TextButton(onPressed: (){
            MyHelper().logOut();
          }, child: Text("Log Out"))




        ],
      ),

    );
  }
}
