import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import 'package:sahayagi/screens/sign_in.dart';

import 'package:sahayagi/widget/common_widget.dart';
import 'package:sahayagi/widget/covex_bar.dart';



void main() async{
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
     options: FirebaseOptions(apiKey: 'AIzaSyBF89cJO521foKAYZ_F_a9sdwoeHcE-ycg', appId: '1:1063292408157:android:9095287c6f2a71a76058b4', messagingSenderId: '1063292408157', projectId: 'sahayagi-6f549',storageBucket: 'sahayagi-6f549.appspot.com')
 );
 FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
 runApp(const MyApp());

}
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
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
          color: appColorDark,
        ),
        scaffoldBackgroundColor: Colors.white12.withOpacity(.7),

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignIn(),
    );
  }
}




//
//
// _initializeFirebase()async{
//   await Firebase.initializeApp(
//       options: FirebaseOptions(apiKey: 'AIzaSyBF89cJO521foKAYZ_F_a9sdwoeHcE-ycg', appId: '1:1063292408157:android:9095287c6f2a71a76058b4', messagingSenderId: '1063292408157', projectId: 'sahayagi-6f549',storageBucket: 'sahayagi-6f549.appspot.com')
//   );
// }
//







