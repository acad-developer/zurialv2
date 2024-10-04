import 'package:flutter/material.dart';
import '../tools/tools.dart';
import 'handler.dart';
import 'utils.dart';

class PdfData implements BaseModel {
  final String title;
  final int updated;
  final String filename;
  final String url;

  PdfData({
    required this.title,
    required this.updated,
    required this.filename,
    required this.url,
  });

  factory PdfData.fromJson(Map<String, dynamic> json) {
    return PdfData(
      title: json['title'],
      updated: int.parse(json['updated'].toString()),
      filename: json['filename'],
      url: json['url'],
    );
  }

  static List<TitleValue> getOrderTerms() {
    return [
      TitleValue(title: "DateTime", value: "updated"),
      TitleValue(title: "Title", value: "title"),
    ];
  }

  static checkitem() => "title";

  static List<String> getSearchTerm() {
    return ["title"];
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'updated': updated,
      'filename': filename,
      'url': url,
    };
  }
}

Widget pdfListTemplate(Map<String, dynamic> inputdata, BuildContext context,
    VoidCallback deletecallback) {
  PdfData data = PdfData.fromJson(inputdata);
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Card(
      child: ListTile(
        leading: Image.asset("assets/images/pdf.png"),
        contentPadding: const EdgeInsets.all(10),
        title: Text(data.title),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dateDDMMYYHHMMTimeFormatter(data.updated)),
          Text(data.filename),
        ]),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () => openUrlInBrowser(data.url),
                  icon: const Icon(Icons.download)),
              IconButton(
                  onPressed: deletecallback, icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ),
    ),
  );
}
