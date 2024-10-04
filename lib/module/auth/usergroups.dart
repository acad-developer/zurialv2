// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zuriel/models/chatgroupdata.dart';
import 'package:zuriel/models/userprofile.dart';
import 'package:zuriel/models/utils.dart';
import 'package:zuriel/tools/blockList.dart';
import 'package:zuriel/tools/tools.dart';

class UserGroupConnect extends StatefulWidget {
  static const route_name = "usergroupconnect";
  final String userId;
  const UserGroupConnect({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserGroupConnect> createState() => _UserGroupConnectState();
}

class _UserGroupConnectState extends State<UserGroupConnect> {
  final _formKey = GlobalKey<FormState>();
  UserProfile? userProfile;
  bool loadingProfile = false;
  bool _isEditable = false;
  Map<String, TitleCheck> selectedGroupItems = {};
  final _searchController = TextEditingController();
  String searchText = "";
  List<String> searchTerm = ChatGroup.getSearchTerm();
  List<dynamic> userSelectedGroups = [];
  Map<String, TitleCheck> selectedItems = {};
  Map<String, TitleCheck> selectedGroupItemsFilterDb = {};
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
      loadingProfile = true;
      dbDataRefQuery = dbDataRef!.orderBy("updated", descending: true);
    });
    Map<String, TitleCheck> selectedItemsDB = {};
    UserProfile userProfileDb = await getUserData(widget.userId);
    if (userProfileDb.groupList.length > 0) {
      Query<Object?> dbGrouListQuery = dbDataRef!
          .orderBy("updated", descending: true)
          .where(FieldPath.documentId, whereIn: userProfileDb.groupList);
      QuerySnapshot querySnapshot = await dbGrouListQuery.get();
      // Process the documents

      querySnapshot.docs.forEach((doc) {
        selectedItemsDB[doc.id] =
            TitleCheck(title: doc.get("title"), id: doc.id, checked: true);
      });
    }
    setState(() {
      selectedGroupItemsFilterDb = selectedItemsDB;
      userProfile = userProfileDb;
      userSelectedGroups = userProfileDb.groupList;
      if (userSelectedGroups.length > 0) {
        dbDataRefQuery = dbDataRef!.orderBy("updated", descending: true).where(
            FieldPath.documentId,
            whereNotIn: userSelectedGroups as List<dynamic>);
      }
     
      loadingProfile = false;
    });
  }

  getSelectedItems(Map<String, TitleCheck> selectedItems) {
    setState(() {
      selectedGroupItems = selectedItems;
    });
  }

  updateListOfGoups(List<String> groupList, bool isDelete){
    groupList.forEach((String groupId) async {
      await updateGroupUser(groupId, isDelete);
    });
  }

  updateGroupUser(String groupId, bool isDelete) async {
    if (isDelete) {
      await FirebaseFirestore.instance
          .collection('chatgroupdata')
          .doc(groupId)
          .update({
        'userList': FieldValue.arrayRemove([widget.userId])
      });
    } else {
      await FirebaseFirestore.instance
          .collection('chatgroupdata')
          .doc(groupId)
          .update({
        'userList': FieldValue.arrayUnion([widget.userId])
      });
    }
  }

  updateUserGroup(List<String> grouplist) async {
    await FirebaseFirestore.instance
        .collection('userprofile')
        .doc(widget.userId)
        .update({"groupList": grouplist});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('User has been updated with selected group(s).')),
    );
  }

  confirmAddGroup() async {
    askToConfirm(context, () async {
      List<String> grouplist = selectedGroupItemsFilterDb.keys.toList();
      grouplist.addAll(selectedGroupItemsFilter.keys.toList());
      await updateUserGroup(grouplist);
      setState(() {
        if (grouplist.length > 0) {
          updateListOfGoups(grouplist, false);
          dbDataRefQuery = dbDataRef!
              .orderBy("updated", descending: true)
              .where(FieldPath.documentId,
                  whereNotIn: grouplist as List<dynamic>);
        } else {
          dbDataRefQuery = dbDataRef!.orderBy("updated", descending: true);
        }
      });
      Navigator.pop(context);
    });
  }

  removeGroupFromUser(groupId) async {
    askDelete(context, () async {
      setState(() {
        selectedGroupItemsFilterDb.remove(groupId);
        selectedGroupItemsFilter.remove(groupId);
      });
      List<String> grouplist = selectedGroupItemsFilterDb.keys.toList();
      grouplist.addAll(selectedGroupItemsFilter.keys.toList());

      await updateUserGroup(grouplist);
      setState(() {
        if (grouplist.length > 0) {
          updateListOfGoups(grouplist, true);
          dbDataRefQuery = dbDataRef!
              .orderBy("updated", descending: true)
              .where(FieldPath.documentId,
                  whereNotIn: grouplist as List<dynamic>);
        } else {
          dbDataRefQuery = dbDataRef!.orderBy("updated", descending: true);
        }
      });
      Navigator.pop(context);
    });
  }

  Map<String, TitleCheck> selectedGroupItemsFilter = {};
  checkedCallback(bool? checked, docid) {
    setState(() {
      selectedItems[docid]!.checked = checked;
    });
    Iterable<MapEntry<String, TitleCheck>> filterdSelected = selectedItems
        .entries
        .where((MapEntry<String, TitleCheck> obj) => obj.value.checked!);
    Map<String, TitleCheck> filterdSelectedItems = {};
    filterdSelected.forEach((MapEntry<String, TitleCheck> obj) {
      if (obj.value.checked!) {
        filterdSelectedItems[obj.key] = obj.value;
      }
    });
    setState(() {
      selectedGroupItemsFilter = filterdSelectedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("User Profile", context),
      body: loadingProfile
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Center(
                    child: Container(
                      width: DeviceTemplate.formWidth(),
                      margin: EdgeInsets.only(
                          top: 12, left: 12, right: 12, bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .secondary
                              .withOpacity(0.1),
                        ),
                      ),
                      child: Container(
                        child: Column(
                          children: [
                            Container(
                                width: 300,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    onBackgroundImageError: (Object exception,
                                        StackTrace? stackTrace) {},
                                    backgroundImage: NetworkImage(
                                      userProfile!.imageUrl,
                                    ),
                                  ),
                                  title: Text(userProfile!.fullname),
                                  subtitle: Text(userProfile!.email),
                                )),

                            //submit button

                            Container(
                              color: Colors.green.shade100,
                              child: ListTile(
                                title: Text(
                                  "Selected Groups",
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                              ),
                              child: Column(
                                  children: List.generate(
                                      selectedGroupItemsFilterDb.keys
                                          .toList()
                                          .length, (int index) {
                                List<String> keylist =
                                    selectedGroupItemsFilterDb.keys.toList();
                                String selectid = keylist[index];
                                TitleCheck? selectObj =
                                    selectedGroupItemsFilterDb[selectid];
                                return ListTile(
                                  title: Text(selectObj!.title),
                                  trailing: ElevatedButton(
                                    onPressed: () =>
                                        {removeGroupFromUser(selectObj!.id)},
                                    child: Icon(Icons.delete),
                                  ),
                                  // subtitle: Text(selectObj.id),
                                );
                              })),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                              ),
                              child: Column(
                                  children: List.generate(
                                      selectedGroupItemsFilter.keys
                                          .toList()
                                          .length, (int index) {
                                List<String> keylist =
                                    selectedGroupItemsFilter.keys.toList();
                                String selectid = keylist[index];
                                TitleCheck? selectObj =
                                    selectedGroupItemsFilter[selectid];
                                return ListTile(
                                  title: Text(selectObj!.title),

                                  // subtitle: Text(selectObj.id),
                                );
                              })),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            selectedGroupItemsFilter.entries.length > 0
                                ? ElevatedButton.icon(
                                    onPressed: confirmAddGroup,
                                    label: Text("Add Group(s)"),
                                    icon: Icon(Icons.add_reaction))
                                : SizedBox()
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 600,
                    child: groupListView(),
                  )
                ],
              ),
            ),
    );
  }

  Widget groupListView() {
    return Scaffold(
        body: Column(children: [
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
      Expanded(
        child: FirestoreListView(
          query: dbDataRefQuery!,
          itemBuilder: (context, document) {
            List<bool> searchList = [];
            searchTerm.forEach((String ele) {
              bool searchCheck = document
                  .get(ele)
                  .toLowerCase()
                  .contains(searchText.toLowerCase());
              searchList.add(searchCheck);
            });
            bool checkSearch = containsTrue(searchList);
            if (selectedItems.containsKey(document.id)) {
              selectedItems[document.id]!.checked =
                  selectedItems[document.id]!.checked;
            } else {
              selectedItems[document.id] = TitleCheck(
                  title: document.get("title"),
                  id: document.id,
                  checked: false);
            }
            return (checkSearch)
                ? chatGroupListTemplate(document.data() as Map<String, dynamic>,
                    context, nullFunction,
                    hideControl: true,
                    hideCheckBox: false,
                    checked: selectedItems[document.id]!.checked,
                    onchecked: checkedCallback)
                : const SizedBox(
                    height: 0,
                  );
          },
        ),
      )
    ]));
  }

  updateUserProfile(UserProfile profiledata) async {
    String userProfileId = FirebaseFirestore.instance
        .collection('userprofile')
        .doc(widget.userId)
        .id;
    await FirebaseFirestore.instance
        .collection('userprofile')
        .doc(userProfileId)
        .update(profiledata.toJson());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile has been updated.')),
    );
  }

  void _submit() async {
    UserProfile profiledata = UserProfile.init().copyWith();
    await updateUserProfile(profiledata);

    setState(() {
      userProfile = profiledata;
      _isEditable = false;
    });
  }
}
