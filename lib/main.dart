import 'package:flutter/material.dart';
import 'package:zuriel/module/auth/usermanagement.dart';
import 'package:zuriel/module/auth/updateuserprofile.dart';
import 'package:zuriel/module/chat/groupList.dart';
import 'package:zuriel/module/chat/groupchat.dart';
import 'package:zuriel/module/chatgroup/groupmanagement.dart';
import 'package:zuriel/module/prayerRequest/prayer_request_management.dart';
import 'package:zuriel/module/prayerRequest/prayer_request_view.dart';
import 'package:zuriel/module/youtube/videomanagement.dart';
import 'home.dart';
import 'module/auth/authentication.dart';
import 'module/pdf/pdfmanagement.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zuriel Admin',
      color: Colors.red,
      theme: ThemeData(
        primaryColor: Colors.red,
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(color: Colors.white),
            color: Colors.red,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20)),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      initialRoute: "/",
      routes: {
        "/": (_) =>  Authentication(),
        Authentication.route_name: (_) => Authentication(),
        HomePage.route_name: (_) => HomePage(),
        PDFManagement.route_name: (_) => PDFManagement(),
        VideoManagement.route_name: (_) => VideoManagement(),
        PrayerRequestManagement.route_name: (_) => PrayerRequestManagement(),
        PrayerRequestView.route_name: (_) => PrayerRequestView(),
        ChatGroupManagement.route_name: (_) => ChatGroupManagement(),
        ProfileUpdate.route_name: (_) => ProfileUpdate(),
        UserManagement.route_name: (_) => UserManagement(),
        UserGroupChatList.route_name: (_) => UserGroupChatList(),
      },
    );
  }
}
