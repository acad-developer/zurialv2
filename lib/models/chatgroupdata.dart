import 'package:flutter/material.dart';
import 'package:zuriel/module/chat/groupchat.dart';
import 'handler.dart';
import 'utils.dart';

class ChatGroup implements BaseModel {
  String id;
  String title;
  String description;
  String imageUrl;
  String imageName;
  String updated;
  List<dynamic> userList;

  ChatGroup(
      {required this.id,
      required this.title,
      required this.description,
      required this.imageUrl,
      required this.imageName,
      required this.updated,
      required this.userList});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'imageName': imageName,
      'updated': updated,
      'userList': userList
    };
  }

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      id: json['id'],
      updated: json['updated'],
      userList: json.containsKey('userList') ? json['userList'] : [],
      imageName: json.containsKey('imageName') ? json['imageName'] : "",
    );
  }

  static List<TitleValue> getOrderTerms() {
    return [
      TitleValue(title: "DateTime", value: "updated"),
      TitleValue(title: "Title", value: "title"),
    ];
  }

  static List<String> getSearchTerm() {
    return ["title"];
  }

  static checkitem() => "title";

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'updated': updated,
      'description': description,
      'imageUrl': imageUrl,
      'imageName': imageName,
      'id': id,
      'userList': userList
    };
  }
}

Widget chatGroupListTemplate(Map<String, dynamic> inputdata,
    BuildContext context, VoidCallback deletecallback,
    {bool? hideControl = false,
    bool? checked = false,
    Function(bool?, String)? onchecked,
    bool? hideCheckBox,
    GestureTapCallback? ontileTap = null
    }) {
  ChatGroup data = ChatGroup.fromJson(inputdata);
  bool hideCheckBoxB = hideCheckBox ?? true;
  return Container(
    padding: const EdgeInsets.only(left: 10, right: 10),
    child: Card(
      child: ListTile(
        onTap: ontileTap,
        leading: Container(
            height: 70,
            width: hideCheckBoxB ? 70 : 110,
            child: Row(
              children: [
                hideCheckBoxB
                    ? SizedBox()
                    : Checkbox(
                        value: checked,
                        onChanged: (bool? newValue) {
                          onchecked!(newValue, data.id);
                        },
                      ),
                Container(
                  height: 70,
                  width: 70,
                  child: CircleAvatar(
                    onBackgroundImageError:
                        (Object exception, StackTrace? stackTrace) {},
                    backgroundImage: NetworkImage(
                      data.imageUrl,
                    ),
                  ),
                )
              ],
            )),
        contentPadding: const EdgeInsets.all(10),
        title: Text(data.title),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(data.description),
          Text(data.updated),
          // Text(data.id),
        ]),
        trailing: Container(
          width: 200,
          child: hideControl!
              ? null
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                        icon: Icon(Icons.chat),
                        onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GroupChatScreen(
                                  groupId: data.id,
                                ),
                              ),
                            ),
                        label: Text("View Chat")),
                    IconButton(
                        onPressed: deletecallback,
                        icon: const Icon(Icons.delete))
                  ],
                ),
        ),
      ),
    ),
  );
}
