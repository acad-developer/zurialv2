import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:zuriel/models/userprofile.dart';

bool containsTrue(List<bool> list) {
  for (final element in list) {
    if (element) {
      return true;
    }
  }
  return false;
}

Future<UserProfile> getUserData(String userId) async {
  // ignore: await_only_futures
  UserProfile userProfile;
  print(userId);
  DocumentSnapshot<Map<String, dynamic>> userProfileData =
      await FirebaseFirestore.instance
          .collection('userprofile')
          .doc(userId)
          .get();
  Map<String, dynamic>? profiledata = userProfileData.data();
  userProfile = UserProfile.fromJson(profiledata as Map<String, dynamic>);
  return userProfile;
}

Future<Map<String, dynamic>> getUsersInGroup(String groupId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch group document
  DocumentSnapshot groupDoc =
      await firestore.collection('chatgroupdata').doc(groupId).get();
  List<dynamic> participants = groupDoc['userList'];
  Map<String, dynamic> groupUsers = {};
  if (participants.length > 0) {
    // Fetch user details using whereIn
    QuerySnapshot userDocs = await firestore
        .collection('userprofile')
        .where(FieldPath.documentId, whereIn: participants)
        .get();

    // Extract user details
    userDocs.docs.map((doc) {
      groupUsers[doc['id']] = {
        'firstName': doc['fullname'],
        'imageUrl': doc['imageUrl'],
        'id': doc['id'],
      };
    }).toList();
  }
  return groupUsers;
}

class DeviceTemplate {
  static double formWidth() {
    late double defaltwidth = 400;
    if (kIsWeb) {
      print("Running on the web");
    } else if (Platform.isAndroid || Platform.isIOS) {
      print("Running on a mobile device");
      defaltwidth = double.infinity;
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      print("Running on a desktop");
    } else {
      print("Unknown platform");
    }
    return defaltwidth;
  }

  static double headerFontSize = 20;
}

AppBar customAppBar(String title, BuildContext context) {
  return AppBar(
    title: Text(title),
    actions: [
      IconButton(
          onPressed: () => Navigator.of(context).pushReplacementNamed("home"),
          icon: const Icon(Icons.home))
    ],
  );
}

BoxDecoration customeBoxShadow() {
  return BoxDecoration(
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
  );
}

void openUrlInBrowser(String url) async {
  try {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Handle the case where the launch failed
      throw 'Could not launch $url';
    }
  } catch (e) {
    // Handle other exceptions
    // print('Error launching URL: $e');
  }
}

void askToConfirm(BuildContext context, callbackfuntions) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Please Confirm'),
      content: const Text('Are you sure you want to add recored?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: callbackfuntions,
          child: const Text('Add Now'),
        ),
      ],
    ),
  );
}

void askDelete(BuildContext context, deleteaction) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: const Text('Are you sure you want to delete recored?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: deleteaction,
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

customDrawer(List<DrawerItem> drawerItems, BuildContext context) {
  return Drawer(
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
          child: Image.asset("logo.png"),
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
                // print(item.url);
                // Handle navigation or other actions based on item
                // Navigator.of(context).pushNamed(item.url);
                Navigator.pop(context);
              },
            )),
      ],
    ),
  );
}

class DrawerItem {
  final IconData icon;
  final String title;
  final String url;
  DrawerItem({required this.icon, required this.title, required this.url});
}

class DefaultTextField extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String? label;
  final double? width;
  final double? height;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool enabled;
  final int? maxLines;
  final TextInputType keyboardType;
  final String? initialValue;
  final bool disabled;
  const DefaultTextField(
      {super.key,
      this.onChanged,
      this.enabled = true,
      this.disabled = false,
      this.label,
      this.keyboardType = TextInputType.text,
      this.maxLines,
      this.focusNode,
      this.initialValue,
      this.onTap,
      this.width,
      this.obscureText = false,
      this.height,
      this.controller,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      readOnly: !enabled,
      enabled: !disabled,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: label,
        filled: disabled,
        fillColor: disabled ? Colors.grey[200] : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0.0),
            borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(0.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
        labelStyle: const TextStyle(color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: width ?? 450,
        ),
      ),
      controller: controller,
      obscureText: obscureText,
      initialValue: initialValue,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      inputFormatters: [
        if (keyboardType == TextInputType.number)
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
    );
  }
}

class SpacedColumn extends StatelessWidget {
  //Do not add screenUtil, Just pass double value
  double? verticalSpace;
  List<Widget> children;
  MainAxisAlignment? mainAxisAlignment;
  CrossAxisAlignment? crossAxisAlignment;
  MainAxisSize? mainAxisSize;
  final Color? dividerColor;
  final bool mergeDividerWithSpace;

  SpacedColumn(
      {super.key,
      this.verticalSpace = 0.0,
      required this.children,
      this.mergeDividerWithSpace = false,
      this.dividerColor,
      this.mainAxisSize = MainAxisSize.max,
      this.mainAxisAlignment = MainAxisAlignment.start,
      this.crossAxisAlignment = CrossAxisAlignment.center});

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    for (var element in children) {
      widgets.add(element);
      if (children.last == element) {
      } else {
        if (dividerColor != null) {
          if (mergeDividerWithSpace) {
            widgets.add(SizedBox(height: verticalSpace! / 2));
            widgets.add(Divider(color: dividerColor));
            widgets.add(SizedBox(height: verticalSpace! / 2));
          } else {
            widgets.add(Divider(color: dividerColor));
          }
        } else {
          widgets.add(SizedBox(height: verticalSpace!));
        }
      }
    }
    return Column(
      mainAxisAlignment: mainAxisAlignment!,
      crossAxisAlignment: crossAxisAlignment!,
      mainAxisSize: mainAxisSize!,
      children: widgets,
    );
  }
}

String epochToDateTime(int epochTime) {
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime);
  // Format the DateTime
  String formattedDate = DateFormat('dd/MM/yyyy - HH:mm:ss').format(dateTime);
  return (formattedDate.toString()); // Output: 01/10/2021 - 00:00:00
}

Future<void> sendNotificationToTopic(
    String title, String message, String topic, Map<String, dynamic> data) async {
  final url = 'https://sendnotificationtotopic-a7ohwrqwqq-uc.a.run.app';
  final dio = Dio(); // Initialize dio
  try {
    data["topic"]=topic;
    final response = await dio.post(
      url,
      options: Options(
        headers: {
          'content-type': 'application/json',
        },
      ),
      data: {
        'title': title,
        'message': message,
        'topic': topic,
        "data":data
      },
    );
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('An error occurred: $e');
  }
}
