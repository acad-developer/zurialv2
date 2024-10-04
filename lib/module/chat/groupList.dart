// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zuriel/models/chatgroupdata.dart';
import 'package:zuriel/models/userprofile.dart';
import 'package:zuriel/models/utils.dart';
import 'package:zuriel/module/chat/groupchat.dart';
import 'package:zuriel/tools/blockList.dart';
import 'package:zuriel/tools/tools.dart';

class UserGroupChatList extends StatefulWidget {
  static const route_name = "userchatgrouplist";
  const UserGroupChatList({Key? key}) : super(key: key);

  @override
  State<UserGroupChatList> createState() => _UserGroupChatListState();
}

class _UserGroupChatListState extends State<UserGroupChatList> {
  UserProfile? userProfile;
  bool loadingProfile = false;
  Map<String, TitleCheck> selectedGroupItems = {};
  final _searchController = TextEditingController();
  String searchText = "";
  List<String> searchTerm = ChatGroup.getSearchTerm();
  List<dynamic> userSelectedGroups = [];
  Map<String, TitleCheck> selectedItems = {};
  Map<String, TitleCheck> selectedGroupItemsFilterDb = {};
  bool loadingGroups = false;
  bool userHasGroup = true;
  @override
  void initState() {
    initUser();
    super.initState();
  }

  CollectionReference? dbDataRef =
      FirebaseFirestore.instance.collection("chatgroupdata");
  Query<Object?>? dbDataRefQuery;

  initUser() async {
    setState(() {
      loadingGroups = true;
      loadingProfile = true;
    });
    User? user = await FirebaseAuth.instance.currentUser;
    UserProfile userProfileDb = await getUserData(user!.uid);
    setState(() {
      userProfile = userProfileDb;
      userSelectedGroups = userProfileDb.groupList;
      if (userSelectedGroups.length > 0) {
        loadingProfile = true;
        dbDataRefQuery = dbDataRef!.orderBy("updated", descending: true).where(
            FieldPath.documentId,
            whereIn: userSelectedGroups as List<dynamic>);
        getCollectionData();
      } else {
        userHasGroup = false;
      }

      loadingProfile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("User Chat", context),
      body: loadingProfile
          ? Center(child: CircularProgressIndicator())
          : groupListView(),
    );
  }

  Future<Map<String, String>> getLastText(String groupId) async {
    Query<Map<String, dynamic>> querySnapshot = await dbDataRef!
        .doc(groupId)
        .collection("messages")
        .orderBy('createdAt', descending: true);

    QuerySnapshot<Map<String, dynamic>> queryDb = await querySnapshot.get();
    if (queryDb.docs.length > 0) {
      Map<String, dynamic> dbData = queryDb.docs.first.data();
      print(dbData);
      if (dbData["type"] == "image") {
        return {
          "description": "Image",
          "updated": epochToDateTime(dbData["createdAt"])
        };
      } else {
        return {
          "description": dbData["text"],
          "updated": epochToDateTime(dbData["createdAt"])
        };
      }
    } else {
      return {"description": "", "updated": ""};
    }
  }

  List<Map<String, dynamic>> groupListData = [];
  Map<String, dynamic> groupListDataObj = {};

  getCollectionData() async {
    // Get all documents from the specified collection
    QuerySnapshot querySnapshot = await dbDataRefQuery!.get();

    // Convert the documents to a list of maps
    List<Map<String, dynamic>> documents = querySnapshot.docs.map((doc) {
      Map<String, dynamic> groupobj = doc.data() as Map<String, dynamic>;
      return groupobj;
    }).toList();

    Map<String, dynamic> groupListDataObjTemp = {};
    documents.forEach((Map<String, dynamic> gobj) {
      groupListDataObjTemp[gobj['id']] = gobj;
    });
    setState(() {
      groupListDataObj = groupListDataObjTemp;
      groupListData = documents;
      loadingGroups = false;
    });
    updateRecentText();
  }

  updateRecentText() {
    groupListData.forEach((Map<String, dynamic> gobj) async {
      Map<String, String> recentMessage = await getLastText(gobj["id"]);
      setState(() {
        groupListDataObj[gobj['id']]["description"] =
            recentMessage["description"];
        groupListDataObj[gobj['id']]["updated"] = recentMessage["updated"];
      });
    });
  }

  Widget groupListView() {
    return Scaffold(
        body: !userHasGroup
            ? Center(
                child: Text("No group membership found for you."),
              )
            : Column(children: [
                Container(
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 200,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: const InputDecoration(
                                      hintText: 'Search',
                                    ),
                                    // onChanged: _onSearchChanged,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => setState(() {
                                    searchText = _searchController.text;
                                  }),
                                  child: const Text("Search"),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      searchText = "";
                                      _searchController.text = "";
                                    });
                                  },
                                  child: const Icon(Icons.clear),
                                )
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                const Divider(),
                loadingGroups
                    ? CircularProgressIndicator()
                    : Expanded(
                        child: ListView.builder(
                          itemCount: groupListData
                              .length, // Number of items in the list
                          itemBuilder: (context, index) {
                            Map<String, dynamic> groupObjData =
                                groupListData[index];
                            bool searchCheck = groupObjData["title"]
                                .toLowerCase()
                                .contains(searchText.toLowerCase());
                            return (searchCheck)
                                ? chatGroupListTemplate(
                                    groupObjData, context, nullFunction,
                                    hideControl: true, ontileTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GroupChatScreen(
                                          groupId: groupObjData["id"],
                                        ),
                                      ),
                                    );
                                    updateRecentText();
                                  })
                                : const SizedBox(
                                    height: 0,
                                  );
                          },
                        ),
                      )
              ]));
  }
}
