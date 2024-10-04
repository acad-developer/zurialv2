import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zuriel/module/auth/updateuserprofile.dart';
import '../../home.dart';

class Authentication extends StatefulWidget {
  static const route_name = "login";

  const Authentication({super.key});

  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isNotLoggedIn = true;
  bool checkSignIn = false;
  bool checkSignUp = false;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    final User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      isNotLoggedIn = user.emailVerified ? false : false;
      print(user);
      // User is already logged in, navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileUpdate()),
      );
    } else {
      isNotLoggedIn = true;
    }
  }

  Future<Map<String, dynamic>> getUserStatus(String email) async {
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

        // Check if the user is disabled or blocked
        bool isDisabled = userData['disabled'] ?? false;
        bool isBlocked = userData['blocked'] ?? false;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isNotLoggedIn
          ? Center(
              child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              width: 400,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/logo.png",
                    height: 100,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(Icons.login),
                        onPressed: checkSignIn ? null : _signIn,
                        label: Text(checkSignIn ? "Processing..." : 'Sign In'),
                      ),
                     
                      ElevatedButton.icon(
                        icon: Icon(Icons.app_registration),
                        onPressed: checkSignUp ? null : _passwordReset,
                        label: Text(checkSignUp ? "Processing..." : 'Reset Password'),
                      ),
                    ],
                  ),
                ],
              ),
            ))
          : const Center(
              child: Text("Checking User..."),
            ),
    );
  }

  _errorHandling(error) {
    setState(() {
      checkSignIn = false;
      checkSignUp = false;
    });
    late String errorMessages = "Failed to sign in. Please try again.";
    List errorTxt = error.toString().split("]");
    if (errorTxt.length > 1) {
      errorMessages = errorTxt[1].toString().trim();
    }
    // Display an error message to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessages)),
    );
  }

  Future<void> _signIn() async {
    try {
      setState(() {
        checkSignIn = true;
      });

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

      bool isVerified = userCredential.user!.emailVerified;
      // Navigate to the home screen or another authorized page

      if (isVerified) {
      
        Navigator.of(context).pushReplacementNamed("home");
      } else {
        _errorHandling(
            "Error signing up: [firebase_auth/not-verified] Email address not verified, please check your email.");
      }
      setState(() {
        checkSignIn = false;
      });
    } catch (e) {
      // print('Error signing in: $e');
      _errorHandling(e);
    }
  }

  Future<void> _passwordReset() async {
    try {
      setState(() {
        checkSignUp = true;
      });
      final userCredential =
          await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      // print('Signed up successfully: ${userCredential.user}');

    
      setState(() {
        checkSignUp = false;
      });
      // Navigate to a verification screen or display a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password reset email sent. Please check your inbox.')),
      );
    } catch (e) {
      // print('Error signing up: $e');

      _errorHandling(e);
    }
  }
}
