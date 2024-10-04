import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuriel/models/userprofile.dart';
import 'package:zuriel/models/utils.dart';
import 'package:zuriel/tools/tools.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class GroupChatScreen extends StatefulWidget {
  static const route_name = "chatgroup";
  final String groupId;
  const GroupChatScreen({Key? key, required this.groupId}) : super(key: key);
  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  Map<String, dynamic> defaultUser = {
    "id": "0000",
    "firstName": "Farmer User",
    "imageUrl":
        "gs://zuriel-app.appspot.com/assets/png-clipart-user-profile-2018-in-sight-user-conference-expo-business-default-business-angle-service-thumbnail.png"
  };
  List<types.Message> _messages = [
    types.ImageMessage(
                author: types.User(
                    id: "",
                    firstName: "",
                    imageUrl: ""),
              
                id: "111",
                name: "",
                size: 50,
                uri: "https://media.tenor.com/6DR9HRfOFu8AAAAC/typing-loading.gif",
              )
  ];
  UserProfile? userProfile;
  bool loadingProfile = false;
  var _user = types.User(id: 'user1');
  Map<String, dynamic> groupUserList = {};
  String groupId = "";

  CollectionReference? collectionRef;
  @override
  void initState() {
    super.initState();
    initUser();
  }

  initUser() async {
    setState(() {
      groupId = widget.groupId;
    });
    final CollectionReference collectionRefdb = await FirebaseFirestore.instance
        .collection('chatgroupdata')
        .doc(groupId)
        .collection("messages");
    setState(() {
      collectionRef = collectionRefdb;
      loadingProfile = true;
    });
    // ignore: await_only_futures
    User? user = await FirebaseAuth.instance.currentUser;
    DocumentSnapshot<Map<String, dynamic>> userProfileData =
        await FirebaseFirestore.instance
            .collection('userprofile')
            .doc(user!.uid)
            .get();
    Map<String, dynamic>? profiledata = userProfileData.data();

    Map<String, dynamic> usergropulisttemp = await getUsersInGroup(groupId);
    _loadMessages();
    setState(() {
      groupUserList = usergropulisttemp;
      if (profiledata != null) {
        userProfile = UserProfile.fromJson(profiledata as Map<String, dynamic>);
      } else {
        userProfile = UserProfile.init();
        userProfile!.id = user.uid;
      }
      _user = types.User(
          id: userProfile!.id,
          imageUrl: userProfile!.imageUrl,
          firstName: userProfile!.fullname);
      loadingProfile = false;
    });
  }

  CharUserType getTypeUser(String userId) {
    Map<String, dynamic> gropupObj =
        groupUserList.containsKey(userId) ? groupUserList[userId] : defaultUser;
    String firstName =
        gropupObj.containsKey("firstName") ? gropupObj["firstName"] : "";
    String imageUrl =
        gropupObj.containsKey("imageUrl") ? gropupObj["imageUrl"] : "";
    ;
    return CharUserType(id: userId, firstName: firstName, imageUrl: imageUrl);
  }

  void _loadMessages() async {
    FirebaseFirestore.instance
        .collection('chatgroupdata')
        .doc(groupId)
        .collection("messages")
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      final messages = snapshot.docs
          .map((doc) {
            final data = doc.data();
            CharUserType chatuser = getTypeUser(data["authorId"]);
            if (data['type'] == 'text') {
              return types.TextMessage(
                author: types.User(
                    id: chatuser.id,
                    firstName: chatuser.firstName,
                    imageUrl: chatuser.imageUrl),
                createdAt: data['createdAt'],
                id: doc.id,
                text: data['text'],
              );
            } else if (data['type'] == 'image') {
              return types.ImageMessage(
                author: types.User(
                    id: chatuser.id,
                    firstName: chatuser.firstName,
                    imageUrl: chatuser.imageUrl),
                createdAt: data['createdAt'],
                id: doc.id,
                name: data['name'],
                size: data['size'],
                uri: data['uri'],
              );
            }
            return null;
          })
          .where((message) => message != null)
          .toList();
      setState(() {
        _messages = [];
        messages.forEach((msg) {
          _messages.add(msg!);
        });
        // _messages.addAll(messages);
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: 'text_${_messages.length}',
      text: message.text,
    );

    collectionRef!.add({
      'type': 'text',
      'authorId': _user.id,
      'createdAt': textMessage.createdAt,
      'text': textMessage.text,
    });

    setState(() {
      _messages.insert(0, textMessage);
    });
  }

  void _handleImageSelection() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, imageQuality: 50);

    if (pickedFile != null) {
      final fileLength = await pickedFile.length();

      final imageMessage = types.ImageMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: 'image_${_messages.length}',
        name: pickedFile.name,
        size: fileLength,
        uri: pickedFile.path,
      );
      setState(() {
        _messages.insert(0, imageMessage);
      });

      String chatId = collectionRef!.doc().id;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("chatimages")
          .child("${groupId}/${chatId}.jpg");
      Uint8List fileBytes = await pickedFile.readAsBytes();

      final uploadTask = storageRef.putData(fileBytes);
      final taskSnapshot = await uploadTask.whenComplete(() => null);

      final downloadURL = await taskSnapshot.ref.getDownloadURL();
      await collectionRef!.doc(chatId).set({
        'type': 'image',
        'authorId': _user.id,
        'createdAt': imageMessage.createdAt,
        'name': imageMessage.name,
        'size': imageMessage.size,
        'uri': downloadURL,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Chat(
        showUserAvatars: true,
        showUserNames: true,
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        onAttachmentPressed: _handleImageSelection,
      ),
    );
  }
}
