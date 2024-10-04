import 'package:flutter/material.dart';
import 'package:zuriel/models/prayerrequest.dart';
import 'package:zuriel/tools/tableList.dart';
import '../../tools/tools.dart';

class PrayerRequestManagement extends StatefulWidget {
  static const route_name = "prayrequestmanagement";
  const PrayerRequestManagement({super.key});
  @override
  _PrayerRequestManagementState createState() => _PrayerRequestManagementState();
}

class _PrayerRequestManagementState extends State<PrayerRequestManagement> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Prayer Request Management", context),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pushNamed("addprayerrequest");
          }),
      body: TableListView(
        collectionname: "prayerrequest",
        searchTerm: PrayerRequestMd.getSearchTerm(),
        orderByItems: PrayerRequestMd.getOrderTerms(),
        template: prListTemplate,
      ),
    );
  }
}
