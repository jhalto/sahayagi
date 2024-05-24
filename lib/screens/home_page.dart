import 'package:flutter/material.dart';
import 'package:sahayagi/screens/app_drawer.dart';
import 'package:sahayagi/screens/sign_in.dart';
import '../models/events_model.dart';
import '../widget/common_widget.dart';
import 'message.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(

        toolbarHeight: 65,

        centerTitle: true,
        title: Column(
          children: [
            Text("Sahayagi",style: appFontStyle(30,texColorLight,FontWeight.bold),),
            Text("Volunteer BD",style: appFontStyle(15,texColorDark,FontWeight.w500,FontStyle.italic),)
          ],
        ),
        actions: [
          IconButton(onPressed: (){
                   Navigator.push(context, MaterialPageRoute(builder: (context) => const Messages(),));
          }, icon: const Icon(Icons.messenger_outline_outlined))
        ],
      ),
        body: Container(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: eventsList.length,
            itemBuilder: (context, index) => Card(
              child: Column(
                children: [
                  Text(eventsList[index].eventTitle,style: appFontStyle(20,texColorDark,FontWeight.bold),),
                  Text(eventsList[index].eventCategory),
                  Text("${eventsList[index].eventDetails}"),
                  Text("${eventsList[index].eventLocation},${eventsList[index].eventSubDistrict},${eventsList[index].eventDistrict}"),


                ],
              ),
            ),
          ),
        ),


    );
  }
}
