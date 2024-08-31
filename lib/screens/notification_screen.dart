import 'package:flutter/material.dart';
import 'package:sahayagi/widget/common_widget.dart';

class NotificationScreen extends StatefulWidget {

  final String id ;

  const NotificationScreen({super.key,required this.id});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.id}',style: appFontStyle(20,texColorLight),),
      ),
    );
  }
}
