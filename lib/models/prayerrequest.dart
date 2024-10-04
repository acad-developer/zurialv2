import 'package:zuriel/models/utils.dart';
import 'package:zuriel/tools/helpers.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final class PrayerRequestMd {
  final String id;
  final String fullname;
  final String contactNo;
  final String email;
  final String country;
  final String state;
  final String city;
  final int prayerFor;
  String get prayerRequestName => prayerRequestTypes[prayerFor] ?? "";
  final String message;
  final String date;
  final bool isReviewedByAdmin;
  String docID;

  PrayerRequestMd(
      {required this.id,
      required this.fullname,
      required this.contactNo,
      required this.email,
      required this.country,
      required this.state,
      required this.city,
      required this.prayerFor,
      required this.message,
      required this.date,
      this.isReviewedByAdmin = false,
      this.docID = ""});

  //from json
  factory PrayerRequestMd.fromJson(Map<String, dynamic> json) =>
      PrayerRequestMd(
        id: json["id"],
        fullname: json["fullname"],
        contactNo: json["contactNo"],
        email: json["email"],
        country: json["country"],
        state: json["state"],
        city: json["city"],
        prayerFor: json["prayerFor"] is String ? 0 : json["prayerFor"],
        message: json["message"],
        isReviewedByAdmin: json["isReviewedByAdmin"],
        date: json["date"],
      );

  //to json
  Map<String, dynamic> toJson() => {
        "id": id,
        "fullname": fullname,
        "contactNo": contactNo,
        "email": email,
        "country": country,
        "state": state,
        "city": city,
        "prayerFor": prayerFor,
        "message": message,
        "isReviewedByAdmin": isReviewedByAdmin,
        "date": date,
      };

  //copy with
  PrayerRequestMd copyWith({
    String? fullname,
    String? contactNo,
    String? email,
    String? country,
    String? state,
    String? city,
    int? prayerFor,
    String? message,
    bool? isReviewedByAdmin,
  }) {
    return PrayerRequestMd(
      id: id,
      fullname: fullname ?? this.fullname,
      contactNo: contactNo ?? this.contactNo,
      email: email ?? this.email,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      prayerFor: prayerFor ?? this.prayerFor,
      message: message ?? this.message,
      isReviewedByAdmin: isReviewedByAdmin ?? this.isReviewedByAdmin,
      date: date,
    );
  }

  static List<TitleValue> getOrderTerms() {
    return [
      TitleValue(title: "DateTime", value: "date"),
      TitleValue(title: "Country", value: "country"),
      TitleValue(title: "Full Name", value: "fullname"),
    ];
  }

  static List<String> getSearchTerm() {
    return ["fullname"];
  }

  static checkitem() => "fullname";
  //init
  factory PrayerRequestMd.init() => PrayerRequestMd(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fullname: "",
        contactNo: "",
        email: "",
        country: "",
        state: "",
        city: "",
        prayerFor: 0,
        message: "",
        date: DateTime.now().toIso8601String(),
      );

  static List<TitleValue> keyValue() => [
        TitleValue(
            title: "Full Name",
            value: "fullname",
            cellwidth: 200,
            filterable: true),
        TitleValue(
            title: "Contact No.",
            value: "contactNo",
            cellwidth: 150,
            filterable: true),
        TitleValue(
            title: "Email", value: "email", cellwidth: 200, filterable: true),
        TitleValue(
            title: "Country",
            value: "country",
            cellwidth: 130,
            filterable: true),
        TitleValue(
          title: "State",
          value: "state",
          cellwidth: 100,
        ),
        TitleValue(title: "City", value: "city", cellwidth: 100),
        TitleValue(
            title: "Prayer For",
            value: "prayerFor",
            cellwidth: 160,
            filterable: true),
        TitleValue(title: "Message", value: "message", cellwidth: 200),
        TitleValue(
            title: "Date Time",
            value: "date",
            cellwidth: 180,
            filterable: true),
      ];

  static List<TitleValue> cellKeyValue() => PrayerRequestMd.keyValue()
      .where((TitleValue ptv) => ptv.filterable)
      .toList();
}

class PRSource extends DataGridSource {
  PRSource(this.prData) {
    _buildDataRow();
  }

  List<DataGridRow> _prData = [];
  List<PrayerRequestMd> prData;

  void _buildDataRow() {
    _prData = prData.map<DataGridRow>((prd) {
      Map prdjson = prd.toJson();
      List<TitleValue> listkv = PrayerRequestMd.cellKeyValue();
      final List<DataGridCell<dynamic>> dataGridCellList =
          List<DataGridCell<dynamic>>.generate(listkv.length, (int index) {
        TitleValue prtv = listkv[index];
        late String cellvalue =
            (prdjson.containsKey(prtv.value) ? prdjson[prtv.value] : "")
                .toString();
        if (prtv.value == "prayerFor") {
          cellvalue = prayerRequestTypes[int.parse(cellvalue)].toString();
        }

        return DataGridCell<dynamic>(
          columnName: prtv.title,
          value: cellvalue,
        );
      });
      dataGridCellList
          .add(DataGridCell(columnName: "action", value: prd.docID));
      return DataGridRow(cells: dataGridCellList);
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _prData;

  @override
  DataGridRowAdapter buildRow(
    DataGridRow row,
  ) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: e.columnName == "action"
            ? Container(
                child: Row(
                  children: [
                    ElevatedButton(onPressed: () => {}, child: Text("View")),
                    CircleAvatar(
                        child: IconButton(
                      color: Colors.red,
                      onPressed: () => {},
                      icon: Icon(
                        Icons.delete,
                        size: 20,
                      ),
                    ))
                  ],
                ),
              )
            : Text(e.value.toString()),
      );
    }).toList());
  }
}

Widget prListTemplate(Map<String, dynamic> inputdata, BuildContext context,
    VoidCallback deletecallback) {
  return Container();
}
