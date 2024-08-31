import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sahayagi/widget/covex_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    Timer(
      Duration(
        seconds: 3
      ),(){
        Navigator.push(context, MaterialPageRoute(builder: (context) => ConvexBarDemo(),));
    });
    return Scaffold();
  }
}
