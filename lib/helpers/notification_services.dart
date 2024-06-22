

import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationServices{
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void requestNotificationPermission()async{
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,

    );
    if(settings.authorizationStatus== AuthorizationStatus.authorized ){
       print("user granted permission");
    }else if(settings.authorizationStatus == AuthorizationStatus.provisional){
      print('user granted provisional permission');
    }else{
      AppSettings.openAppSettings();
      print("user denied permission");
    }
  }
  void initLocalNotifications(BuildContext context, RemoteMessage message)async{
    var androidInitializationSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    var iosInitializationSettings = DarwinInitializationSettings();

    var intializationSetting = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      intializationSetting,
      onDidReceiveNotificationResponse: (payload){}
    );
  }
  void firebaseInit(){
    FirebaseMessaging.onMessage.listen((message) {
      if(kDebugMode){
        print(message.notification!.title.toString());
        print(message.notification!.body.toString());
      }

     showNotification(message);
    });

  }
  Future<void> showNotification(RemoteMessage message)async{
    AndroidNotificationChannel channel = AndroidNotificationChannel(Random.secure().nextInt(100000).toString(), 'High Importance Notifications',importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(channel.id.toString(), channel.id.toString(),
     channelDescription:" channel description",
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker'
    );
   DarwinNotificationDetails darwinNotificationDetails =DarwinNotificationDetails(
     presentAlert: true,
     presentBadge: true,
     presentSound: true

   );

   NotificationDetails notificationDetails = NotificationDetails(
     android: androidNotificationDetails,
     iOS: darwinNotificationDetails,
   );
    Future.delayed(Duration.zero,(){
      _flutterLocalNotificationsPlugin.show(0,
          message.notification!.title.toString(),
          message.notification!.body.toString(), notificationDetails);

    });

  }
  Future<String> getDeviceToken()async{
    String? token = await messaging.getToken();
    return token!;
  }
 void getRefreshToken()async{
   messaging.onTokenRefresh.listen((event) {
       event.toString();
    });

  }
}
