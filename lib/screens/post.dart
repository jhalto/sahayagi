import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sahayagi/screens/blood_post.dart';
import 'package:sahayagi/screens/event_post.dart';
import 'package:sahayagi/widget/common_widget.dart';


class PostOption extends StatefulWidget {
  const PostOption({super.key});

  @override
  State<PostOption> createState() => _PostOptionState();
}

class _PostOptionState extends State<PostOption> {
  PageController ? pageController;
  int currentIndex = 0;
  @override
  void initState() {
    // TODO: implement initState
    pageController = PageController(
      initialPage: currentIndex,
    );

  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
            color: Colors.white,
            child: Column(
              children: [

                Expanded(child: PageView(
                  controller: pageController,
                  children: [
                    EventPost(),
                    BloodPost(),
                  ],
                )),
                Container(
                  height: 50,
                  color: appColorDark,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(

                        onPressed: (){
                          setState(() {
                            pageController!.jumpToPage(0);
                          });
                        },child: Text("Event Post",style: appFontStyle(20,texColorLight),),),
                      TextButton(

                        onPressed: (){
                          setState(() {
                            pageController!.jumpToPage(1);
                          });
                        },child: Text("Blood Post",style: appFontStyle(20,texColorLight)),),

                    ],
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}
