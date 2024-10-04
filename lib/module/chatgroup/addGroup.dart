import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zuriel/models/chatgroupdata.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class CreateGroupScreen extends StatefulWidget {
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  XFile? _image;
  Uint8List? fileBytes;
  String? fileName;
  bool isUploading = false;
  double _uploadProgress = 0;
  String imageUrl = "";
  Future<void> _pickImage() async {
    final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 500, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }

  uploadImage(String groupId) async {
    try {
      // Save group data to Firestore

      // Upload image to Firebase Storage

      if (_image != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('chatgroupimage/${groupId}.jpg');
        fileBytes = await _image!.readAsBytes();
        final uploadTask = storageRef.putData(fileBytes!);
        uploadTask.snapshotEvents.listen((event) {
          final progress = (event.bytesTransferred / event.totalBytes);

          setState(() {
            _uploadProgress = progress;
          });
        });

        final taskSnapshot = await uploadTask.whenComplete(() => null);

        final downloadURL = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadURL;
        });
      }

      setState(() {
        _uploadProgress = 0;
        fileBytes = null;
        fileName = null;
      });

      // Display a success message or navigate to another screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully!')),
      );
      setState(() {
        isUploading = false;
      });
    } catch (e) {
      print(e);
      // Display an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error uploading Image. Please try again.')),
      );
    }
  }

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final groupId =
          FirebaseFirestore.instance.collection('chatgroupdata').doc().id;
      await uploadImage(groupId);
     

      final chatGroup = ChatGroup(
          id: groupId,
          title: _title,
          description: _description,
          imageUrl: imageUrl,
          imageName: "${groupId}.jpg",
          userList: [],
          updated: DateTime.now().toIso8601String().toString());

      await FirebaseFirestore.instance
          .collection('chatgroupdata')
          .doc(groupId)
          .set(chatGroup.toMap());

      // Navigate back or show success message
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: 400,
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => _title = value!,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a description' : null,
              onSaved: (value) => _description = value!,
            ),
            SizedBox(height: 16),
            _image == null
                ? TextButton.icon(
                    icon: Icon(
                      Icons.image,
                      size: 75,
                    ),
                    label: Text('Pick Image'),
                    onPressed: _pickImage,
                  )
                : kIsWeb
                    ? Image.network(
                        _image!.path,
                        height: 75,
                      )
                    : Image.file(File(_image!.path)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createGroup,
              child: Text('Create Group'),
            ),
          ],
        ),
      ),
    );
  }
}
