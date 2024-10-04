import 'package:intl/intl.dart';

class TitleValue {
  final String title;
  final String value;
  double cellwidth;
  bool filterable;
  TitleValue(
      {required this.title,
      required this.value,
      this.cellwidth = double.nan,
      this.filterable = false});
}

class TitleCheck {
  final String title;
  final String id;
  bool? checked;
  TitleCheck({
    required this.title,
    required this.id,
    required this.checked,
  });
}

class ImageAttr {
  late String imageURL;
  late String imageName;
  ImageAttr({required this.imageName, required this.imageURL});
}

class CharUserType {
  late String imageUrl;
  late String firstName;
  late String id;
  CharUserType(
      {required this.id, required this.imageUrl, required this.firstName});
}

void nullFunction() {}

String dateDDMMYYTimeFormatter(epochTime) {
 return DateFormat('dd-MMM-yy').format(DateTime.fromMillisecondsSinceEpoch(epochTime));
}

String dateDDMMYYHHMMTimeFormatter(epochTime) {
 return DateFormat('dd-MMM-yy HH:mm').format(DateTime.fromMillisecondsSinceEpoch(epochTime));
}
