import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:zuriel/models/prayerrequest.dart';
import 'package:zuriel/tools/tools.dart';
import '../models/utils.dart';

class TableListView extends StatefulWidget {
  final String collectionname;
  final List<String> searchTerm;
  final List<TitleValue> orderByItems;
  final Function template;
  static const route_name = "tableList";
  const TableListView({
    required this.collectionname,
    required this.orderByItems,
    required this.searchTerm,
    required this.template,
    super.key,
  });
  @override
  _TableListViewState createState() => _TableListViewState();
}

class _TableListViewState extends State<TableListView> {
  final _searchController = TextEditingController();
  CollectionReference? dbDataRef;
  late Query<Object?> querydata;
  List<String> searchTerm = [];
  String searchText = "";
  String orderBy = "";
  bool isDescending = true;
  List<TitleValue> orderByItems = [];

  Future<void> deleteDocument(String documentId) async {
    try {
      final docRef = dbDataRef!.doc(documentId);
      askDelete(context, () async => await docRef.delete());
      Navigator.pop(context);

      // print('Document deleted successfully!');
    } catch (e) {
      // print('Error deleting document: $e');
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
          child: FirestoreQueryBuilder(
        query: dbDataRef!.orderBy(orderBy, descending: isDescending),
        builder: (context, snapshot, _) {
          if (snapshot.isFetching) {
            return Center(
                child: Container(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator()));
          }
          if (snapshot.hasError) {
            return Text('error ${snapshot.error}');
          }

          if (snapshot.hasData) {
            List<PrayerRequestMd> prDataList = [];
            for (int i = 0; i < snapshot.docs.length; i++) {
              String docId = snapshot.docs[i].id;

              final PrayerRequestMd prData = PrayerRequestMd.fromJson(
                  snapshot.docs[i].data() as Map<String, dynamic>);
              List<bool> searchList = [];
              searchTerm.forEach((String ele) {
                bool searchCheck = snapshot.docs[i]
                    .get(ele)
                    .toLowerCase()
                    .contains(searchText.toLowerCase());
                searchList.add(searchCheck);
              });
              bool checkSearch = containsTrue(searchList);
              if (checkSearch) {
                prData.docID = docId;
                prDataList.add(prData);
              }
            }
            List<TitleValue> paylistkeyval = PrayerRequestMd.cellKeyValue();

            final growableList =
                List<GridColumn>.generate(paylistkeyval.length, (int index) {
              TitleValue praylistkv = paylistkeyval[index];

              return GridColumn(
                allowEditing: true,
                allowFiltering: true,
                columnWidthMode: ColumnWidthMode.fill,
                width: praylistkv.cellwidth,
                columnName: praylistkv.value,
                label: Container(
                  padding: EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  child: Text(
                    praylistkv.title,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }, growable: true);
            growableList.add(GridColumn(
              columnWidthMode: ColumnWidthMode.fill,
              width: 150,
              columnName: "action",
              label: Container(
                padding: EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: Text(
                  "View/Delete",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ));
            return SfDataGrid(
                allowSorting: true,
                allowEditing: true,
                source: PRSource(prDataList),
                columns: growableList);
          } else {
            return Center(
                child: Container(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator()));
          }
        },
      ))
    ]));
  }
}
