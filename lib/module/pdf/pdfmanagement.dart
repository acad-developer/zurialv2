import 'package:flutter/material.dart';
import '../../models/pdfdata.dart';
import '../../tools/tools.dart';
import 'addPdf.dart';
import '../../tools/blockList.dart';

class PDFManagement extends StatefulWidget {
  static const route_name = "pdfmanagement";
  const PDFManagement({super.key});
  @override
  _PDFManagementState createState() => _PDFManagementState();
}

class _PDFManagementState extends State<PDFManagement> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar("Pdf Management", context),
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
                content: const AddPdf(),
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
        collectionname: "pdfdata",
        searchTerm: PdfData.getSearchTerm(),
        orderByItems: PdfData.getOrderTerms(),
        template: pdfListTemplate,
      ),
    );
  }
}
