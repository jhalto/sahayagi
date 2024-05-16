import 'package:flutter/material.dart';
import '../models/events_model.dart';
import '../widget/common_widget.dart';

class Opportunities extends StatefulWidget {
  const Opportunities({super.key});

  @override
  State<Opportunities> createState() => _OpportunitiesState();
}

class _OpportunitiesState extends State<Opportunities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Opportunities"),
      ),
      body: ListView.builder(
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
      )

    );
  }
}
