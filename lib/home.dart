import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:zuriel/models/userprofile.dart';
import 'tools/tools.dart';

class HomePage extends StatefulWidget {
  static const route_name = "home";
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void initState() {
    initUser();
    super.initState();
  }

  UserProfile? userProfile;
  initUser() async {
    // User? userData = await FirebaseAuth.instance.currentUser;
    // UserProfile userProfileDb = await getUserData(userData!.uid);
    // setState(() {
    //   userProfile = userProfileDb;
    // });
  }

  final drawerItems = [
    DrawerItem(
        icon: Icons.picture_as_pdf,
        title: 'Pdf Management',
        url: 'pdfmanagement'),
    DrawerItem(
      icon: Icons.videocam,
      title: 'Video Management',
      url: 'videomanagement',
    ),
    DrawerItem(
      icon: FontAwesomeIcons.handsPraying,
      title: 'Pryer Request Management',
      url: 'prayrequestmanagement',
    ),
    DrawerItem(
      icon: FontAwesomeIcons.userGroup,
      title: 'Chat Group Management',
      url: 'chatGroupManagement',
    ),
    DrawerItem(
      icon: FontAwesomeIcons.user,
      title: 'User Management',
      url: 'usermanagement',
    ),
    DrawerItem(
      icon: Icons.chat,
      title: 'User Chat',
      url: 'userchatgrouplist',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Zuriel Admin"),
        actions: [
        
          ElevatedButton.icon(
            label: Text("Profile"),
            icon: const Icon(Icons.person_3),
            onPressed: () => Navigator.of(context).pushNamed("userprofile"),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        try {
                          await FirebaseAuth.instance.signOut();

                          // Navigate to the login screen or another appropriate page
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              "login", (route) => false);
                        } catch (e) {
                          // print('Error signing out: $e');
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.red,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0), bottomRight: Radius.circular(0)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.zero,
                color: Colors.white,
              ),
              child: Image.asset("assets/images/logo.png"),
            ),
            ...drawerItems.map((item) => ListTile(
                  leading: Icon(
                    item.icon,
                    color: Colors.white,
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    // Handle navigation or other actions based on item
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(item.url);
                  },
                )),
          ],
        ),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
