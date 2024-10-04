import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zuriel/home.dart';
import 'package:zuriel/module/auth/authentication.dart';

class AuthWrapper extends StatefulWidget {
  static const route_name = "login";

  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Future<Map<String, dynamic>> getUserStatus(String? email) async {
    try {
      // Reference to the Firestore collection
      CollectionReference users =
          FirebaseFirestore.instance.collection('userprofile');

      // Query the collection for the document with the specified email
      QuerySnapshot querySnapshot =
          await users.where('email', isEqualTo: email).get();

      // Check if the query returned any documents
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming email is unique)
        var userDoc = querySnapshot.docs.first;
        var userData = userDoc.data() as Map<String, dynamic>;
        String userStatus = userData["status"];
        // Check if the user is disabled or blocked
        bool isDisabled = userStatus == 'disabled' ?? false;
        bool isBlocked = userStatus == 'blocked' ?? false;

        if (isDisabled) {
          return {'status': 404, 'message': 'User is disabled.'};
        } else if (isBlocked) {
          print('User is blocked.');
          return {'status': 404, 'message': 'User is blocked.'};
        } else {
          return {'status': 200, 'message': 'User is Active.'};
        }
      } else {
        return {'status': 200, 'message': 'No user found with that email.'};
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return {'status': 200, 'message': 'Error fetching user data: $e'};
    }
  }

  moveToRoute() async {
    setState(() {
      authLooking = true;
    });
    User? authuser = await FirebaseAuth.instance.currentUser;

    if (authuser != null) {
      Map<String, dynamic> userStatus = await getUserStatus(authuser.email);
      setState(() {
        authLooking = false;
      });
      if (userStatus["status"] == 404) {
        setState(() {
          message = userStatus["message"];
        });
      } else {
        Navigator.of(context).pushReplacementNamed("home");
      }
    } else {
      setState(() {
        authLooking = false;
      });
    }
  }

  bool authLooking = false;
  String message = "Checking User....";
  bool invalidUser = false;

  void initState() {
    super.initState();
    moveToRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.none) {
          return CircularProgressIndicator();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasData) {
          return authLooking
              ? CircularProgressIndicator()
              : Center(
                  child: Text(message),
                );
        } else {
          return Authentication();
        }
      },
    )));
  }
}
