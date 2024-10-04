import 'package:zuriel/models/utils.dart';
import 'package:zuriel/module/auth/usergroups.dart';
import 'package:zuriel/tools/helpers.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

final class UserProfile {
  String id;
  final String fullname;
  final String contactNo;
  final String email;
  final String country;
  final String state;
  final String city;
  final String date;
  String imageUrl;
  String imageName;
  String userType;
  List<dynamic> groupList;
  final String status;

  UserProfile({
    required this.id,
    required this.fullname,
    required this.contactNo,
    required this.email,
    required this.country,
    required this.state,
    required this.city,
    required this.date,
    required this.imageName,
    required this.imageUrl,
    required this.userType,
    required this.groupList,
    required this.status,
  });

  //from json
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json.containsKey('id') ? json['id'] : "",
        fullname: json.containsKey('fullname') ? json['fullname'] : "",
        contactNo: json.containsKey('contactNo') ? json['contactNo'] : "",
        email: json["email"],
        country: json.containsKey('country') ? json['country'] : "",
        state: json.containsKey('state') ? json['state'] : "",
        city: json.containsKey('city') ? json['city'] : "",
        date: json.containsKey('date') ? json['date'] : "",
        imageUrl: json.containsKey('imageUrl') ? json['imageUrl'] : "",
        imageName: json.containsKey('imageName') ? json['imageName'] : "",
        userType: json.containsKey('userType') ? json['userType'] : "",
        groupList: json.containsKey('groupList') ? json['groupList'] : [],
        status:  json["status"],
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
        "date": date,
        'imageUrl': imageUrl,
        'imageName': imageName,
        'userType': userType,
        'groupList': groupList,
        'status':status
      };

  //copy with
  UserProfile copyWith({
    String? id,
    String? fullname,
    String? contactNo,
    String? email,
    String? country,
    String? state,
    String? city,
    String? imageUrl,
    String? imageName,
    String? userType,
    List<dynamic>? groupList,
    String? date,
    String? status,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      contactNo: contactNo ?? this.contactNo,
      email: email ?? this.email,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      date: date ?? this.date,
      imageName: imageName ?? this.imageName,
      imageUrl: imageUrl ?? this.imageUrl,
      userType: userType ?? this.userType,
      groupList: groupList ?? this.groupList,
      status:state??this.status
    );
  }

  static List<TitleValue> getOrderTerms() {
    return [
      TitleValue(title: "DateTime", value: "date"),
      TitleValue(title: "Country", value: "country"),
      TitleValue(title: "Full Name", value: "fullname"),
      TitleValue(title: "User Type", value: "userType"),
    ];
  }

  static List<String> getSearchTerm() {
    return ["email", "fullname"];
  }

  static checkitem() => "fullname";
  //init
  factory UserProfile.init() => UserProfile(
        id: "",
        fullname: "",
        contactNo: "",
        email: "",
        country: "",
        state: "",
        city: "",
        date: DateTime.now().toIso8601String().toString(),
        imageName: "",
        imageUrl: "",
        userType: "",
        groupList: [],
        status: "",
      );
}

Widget userListTemplate(
  Map<String, dynamic> inputdata,
  BuildContext context,
  VoidCallback deletecallback,
) {
  UserProfile data = UserProfile.fromJson(inputdata);
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Card(
      child: ListTile(
        leading: Container(
          height: 70,
          width: 70,
          child: CircleAvatar(
            onBackgroundImageError:
                (Object exception, StackTrace? stackTrace) {},
            backgroundImage: NetworkImage(
              data.imageUrl,
            ),
          ),
        ),
        contentPadding: const EdgeInsets.all(10),
        title: Text(data.fullname),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.email),

          Text("Particiepnt in groups: ${data.groupList.length}"),
        ]),
        trailing: Container(
          width: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserGroupConnect(
                            userId: data.id,
                          ),
                        ),
                      ),
                  label: Text("Manage Group")),
              IconButton(
                  onPressed: deletecallback, icon: const Icon(Icons.delete))
            ],
          ),
        ),
      ),
    ),
  );
}
