import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zuriel/tools/tools.dart';
import '../models/utils.dart';
import 'dart:collection';

class DataListView extends StatefulWidget {
  final String collectionname;
  final List<String> searchTerm;
  final List<TitleValue> orderByItems;
  final Function template;
  final String storageRef;
  const DataListView({
    required this.collectionname,
    required this.orderByItems,
    required this.searchTerm,
    required this.template,
    this.storageRef = "",
    super.key,
  });
  @override
  _DataListViewState createState() => _DataListViewState();
}

class _DataListViewState extends State<DataListView> {
  final _searchController = TextEditingController();
  CollectionReference? dbDataRef;
  late Query<Object?> querydata;
  List<String> searchTerm = [];
  String searchText = "";
  String orderBy = "";
  bool isDescending = true;
  List<TitleValue> orderByItems = [];
  Map<String, TitleCheck> selectedItems = {};

  Future<void> deleteDocument(String documentId) async {
    try {
      final docRef = dbDataRef!.doc(documentId);
      askDelete(context, () async {
        await docRef.delete();
        final storageRef = FirebaseStorage.instance.ref();
        if (widget.storageRef.isNotEmpty) {
          final fileRef =
              storageRef.child("${widget.storageRef}/${documentId}.jpg");
          await fileRef.delete();
        }
        Navigator.pop(context);
      });
      // print('Document deleted successfully!');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  @override
  void initState() {
    setState(() {
      dbDataRef = FirebaseFirestore.instance
          .collection(widget.collectionname.toString());

      querydata = dbDataRef!;
      searchTerm = widget.searchTerm;
      orderByItems = widget.orderByItems;
      orderBy = orderByItems[0].value;
    });

    super.initState();
  }

  searchData() {
    setState(() {
      searchText = _searchController.text;
    });
  }

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
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(
                  width: 50,
                ),
                Container(
                    child: Row(
                  children: [
                    const Text("Order By     "),
                    DropdownButton<String>(
                      value: orderBy,
                      hint: const Text('Select an item'),
                      items: orderByItems.map((item) {
                        return DropdownMenuItem<String>(
                          value: item.value,
                          child: Text(item.title.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          orderBy = value ?? "";
                        });
                      },
                    ),
                    IconButton(
                        onPressed: () => setState(() {
                              isDescending = !isDescending;
                            }),
                        icon: Icon(isDescending
                            ? Icons.arrow_downward
                            : Icons.arrow_upward))
                  ],
                ))
              ],
            )),
      ),
      const Divider(),
      Expanded(
        child: FirestoreListView(
          query: dbDataRef!.orderBy(orderBy, descending: isDescending),
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

            return (checkSearch)
                ? widget.template(
                    document.data(), context, () => deleteDocument(document.id))
                : const SizedBox(
                    height: 0,
                  );
          },
        ),
      )
    ]));
  }
}
