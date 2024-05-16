import 'package:flutter/material.dart';
import 'package:sahayagi/screens/sign_in.dart';
import 'package:sahayagi/widget/common_widget.dart';
import 'package:sahayagi/widget/covex_bar.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(
            color: iconColorWhite,
          ),
          color: appColorLight,
        ),
        scaffoldBackgroundColor: iconColorWhite,

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ConvexBarDemo(),
    );
  }
}
