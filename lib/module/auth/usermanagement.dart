import 'package:flutter/material.dart';
import 'package:zuriel/models/chatgroupdata.dart';
import 'package:zuriel/models/userprofile.dart';
import 'package:zuriel/models/utils.dart';
import '../../tools/tools.dart';
import '../../tools/blockList.dart';

class UserManagement extends StatefulWidget {
  static const route_name = "usermanagement";
  const UserManagement({super.key});
  @override
  _UserManagementState createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Users Management", context),
      body: DataListView(
        collectionname: "userprofile",
        searchTerm: UserProfile.getSearchTerm(),
        orderByItems: UserProfile.getOrderTerms(),
        template: userListTemplate,
        storageRef: "userprofileimage/",
      ),
    );
  }
}
