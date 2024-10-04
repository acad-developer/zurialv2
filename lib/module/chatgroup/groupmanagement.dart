import 'package:flutter/material.dart';
import 'package:zuriel/models/chatgroupdata.dart';
import '../../tools/tools.dart';
import 'addGroup.dart';
import '../../tools/blockList.dart';

class ChatGroupManagement extends StatefulWidget {
  static const route_name = "chatGroupManagement";
  const ChatGroupManagement({super.key});
  @override
  _ChatGroupManagementState createState() => _ChatGroupManagementState();
}

class _ChatGroupManagementState extends State<ChatGroupManagement> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Chat Group Management", context),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                content: CreateGroupScreen(),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            );
          }),
      body: DataListView(
        collectionname: "chatgroupdata",
        searchTerm: ChatGroup.getSearchTerm(),
        orderByItems: ChatGroup.getOrderTerms(),
        template: chatGroupListTemplate,
        storageRef: "chatgroupimage/",
      ),
    );
  }
}
